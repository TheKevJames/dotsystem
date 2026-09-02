#!/usr/bin/env python3
# pylint: disable=too-many-lines
"""Control plane for the pi bakery extension.

Talks to per-session control sockets under the bakery directory:
$PI_CODING_AGENT_BAKERY_DIR if set, else $PI_CODING_AGENT_DIR/bakery,
else ~/.pi/agent/bakery.
"""
import argparse
import json
import operator
import os
import pathlib
import shutil
import socket
import sys
import time
from collections.abc import Callable


WAIT_POLL_INTERVAL = 0.25
SOCKET_SUFFIX = '.sock'
ALIAS_SUFFIX = '.alias'
STATE_COLORS = {'idle': 32, 'working': 33, 'blocked': 31, 'dead': 90}


def bakery_dir() -> pathlib.Path:
    override = os.getenv('PI_CODING_AGENT_BAKERY_DIR', '').strip()
    if override:
        return pathlib.Path(override).resolve()
    config = os.getenv('PI_CODING_AGENT_DIR', '').strip()
    base = (
        pathlib.Path(config) if config
        else pathlib.Path.home() / '.pi' / 'agent'
    )
    return (base / 'bakery').resolve()


def is_safe_name(name: str) -> bool:
    if not name:
        return False
    return not any(bad in name for bad in ('/', '\\', '..'))


def alias_map(base: pathlib.Path) -> dict[str, list[str]]:
    """Map each socket path to the alias names symlinked at it."""
    result: dict[str, list[str]] = {}
    for alias_path in base.glob(f'*{ALIAS_SUFFIX}'):
        if not alias_path.is_symlink():
            continue
        target = os.path.normpath(base / os.readlink(alias_path))
        name = alias_path.name[: -len(ALIAS_SUFFIX)]
        result.setdefault(target, []).append(name)
    return result


def resolve_socket(session: str) -> pathlib.Path:
    if not is_safe_name(session):
        sys.exit(f'invalid session: {session}')
    base = bakery_dir()
    alias = base / f'{session}{ALIAS_SUFFIX}'
    if alias.is_symlink():
        return pathlib.Path(os.path.normpath(base / os.readlink(alias)))
    return base / f'{session}{SOCKET_SUFFIX}'


def sessions_dir() -> pathlib.Path:
    state = os.getenv('XDG_STATE_HOME', '').strip()
    base = (
        pathlib.Path(state) if state
        else pathlib.Path.home() / '.local' / 'state'
    )
    return (base / 'pi' / 'sessions').resolve()


def top_level_sessions() -> list[pathlib.Path]:
    # Top-level sessions are `<TIMESTAMP>_<uuid>.jsonl`; subagent sidecar
    # files live under `<TIMESTAMP>_<uuid>/` subdirs.
    store = sessions_dir()
    if not store.is_dir():
        return []
    return [s for s in store.glob('*.jsonl') if '_' in s.name]


def path_to_id(path: pathlib.Path) -> str:
    return path.name.split('_')[1].split('.')[0]


def read_session(path: pathlib.Path) -> tuple[str, str, str | None] | None:
    """Parse (session_id, cwd, name) from a session file, else None.

    name is the latest `session_info` entry's name, i.e. the session's /name.
    """
    try:
        lines = path.read_text().splitlines()
        header = json.loads(lines[0])
    except (OSError, ValueError, IndexError):
        return None
    cwd = header.get('cwd')
    if not isinstance(cwd, str):
        return None
    name: str | None = None
    for line in lines:
        if 'session_info' not in line:
            continue
        try:
            entry = json.loads(line)
        except ValueError:
            continue
        entry_name = entry.get('name')
        if entry.get('type') == 'session_info' and isinstance(entry_name, str):
            name = entry_name
    return (path_to_id(path), cwd, name)


SessionRecord = tuple[str, str, str | None]


def session_records() -> list[tuple[pathlib.Path, SessionRecord]]:
    pairs = []
    for path in top_level_sessions():
        record = read_session(path)
        if record is not None:
            pairs.append((path, record))
    return pairs


def newest_record(
    pairs: list[tuple[pathlib.Path, SessionRecord]],
) -> SessionRecord:
    return max(pairs, key=lambda pr: pr[0].stat().st_ctime)[1]


def disk_session_by_ref(session: str) -> SessionRecord | None:
    """Resolve a session by id or /name from the on-disk store."""
    pairs = session_records()
    matches = [pr for pr in pairs if pr[1][0] == session]
    matches = matches or [pr for pr in pairs if pr[1][2] == session]
    return newest_record(matches) if matches else None


def find_session(session: str | None) -> SessionRecord:
    """Resolve a session by id or /name, else infer it from the cwd."""
    if session:
        record = disk_session_by_ref(session)
        if record is None:
            sys.exit(f'session not found: {session}')
        return record

    cwd = str(pathlib.Path.cwd().resolve())
    here = [pr for pr in session_records() if pr[1][1] == cwd]
    if not here:
        sys.exit(f'no session found for {cwd}')
    return newest_record(here)


def cwd_for_id(session_id: str) -> str | None:
    for path in top_level_sessions():
        if path_to_id(path) == session_id:
            record = read_session(path)
            if record is not None:
                return record[1]
    return None


def rpc(
    socket_path: pathlib.Path,
    command: dict[str, object],
    timeout: float,
) -> dict[str, object]:
    """Send one JSON-RPC command and return its response.

    Raises OSError if the socket cannot be reached or returns no response.
    """
    buffer = ''
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
        sock.settimeout(timeout)
        sock.connect(str(socket_path))
        sock.sendall((json.dumps(command) + '\n').encode())
        while '\n' not in buffer:
            chunk = sock.recv(65536)
            if not chunk:
                break
            buffer += chunk.decode()

    line = buffer.split('\n', 1)[0].strip()
    if not line:
        raise OSError('no response from session')
    response: dict[str, object] = json.loads(line)
    return response


def query_status(
    socket_path: pathlib.Path,
    timeout: float = 0.5,
) -> str | None:
    """Return a live session's status, or None if the socket is dead."""
    try:
        response = rpc(socket_path, {'type': 'get_status'}, timeout)
    except (OSError, ValueError):
        return None
    data = response.get('data')
    if isinstance(data, dict):
        status = data.get('status')
        if isinstance(status, str):
            return status
    return 'unknown'


def state_dot(status: str) -> str:
    """A filled circle coloured by state (gray for anything unrecognised)."""
    color = STATE_COLORS.get(status, 90)
    return f'\033[{color}m\u25cf\033[0m'


def live_session_ids() -> set[str]:
    base = bakery_dir()
    ids: set[str] = set()
    for socket_path in base.glob(f'*{SOCKET_SUFFIX}') if base.is_dir() else []:
        if query_status(socket_path) is None:
            continue
        session_id = socket_path.name[: -len(SOCKET_SUFFIX)]
        if is_safe_name(session_id):
            ids.add(session_id)
    return ids


def list_entries() -> list[tuple[str, bool, str]]:
    """Return (name, pinned, status) for live and pinned sessions."""
    base = bakery_dir()
    aliases = alias_map(base) if base.is_dir() else {}

    live_status: dict[str, str] = {}
    live_name: dict[str, str] = {}
    for socket_path in base.glob(f'*{SOCKET_SUFFIX}') if base.is_dir() else []:
        status = query_status(socket_path)
        if status is None:
            continue
        session_id = socket_path.name[: -len(SOCKET_SUFFIX)]
        if not is_safe_name(session_id):
            continue
        live_status[session_id] = status
        names = aliases.get(str(socket_path), [])
        live_name[session_id] = names[0] if names else session_id

    # Pinned sessions are shown by their pin name (live or dead).
    entries: list[tuple[str, bool, str]] = []
    pinned_ids: set[str] = set()
    for name, info in read_pins().items():
        sid = info.get('sessionId')
        if isinstance(sid, str):
            pinned_ids.add(sid)
            status = live_status.get(sid, 'dead')
        else:
            status = 'dead'
        entries.append((name, True, status))

    for sid, status in live_status.items():
        if sid not in pinned_ids:
            entries.append((live_name[sid], False, status))
    return entries


def do_list(args: argparse.Namespace) -> int:
    _ = args
    entries = sorted(list_entries(), key=operator.itemgetter(0))
    rows = [
        (f'{name}{"*" if pinned else ""} ', status)
        for name, pinned, status in entries
    ]
    width = max((len(label) for label, _ in rows), default=0)
    for label, status in rows:
        print(f'{label:<{width}} {state_dot(status)} {status}')
    return 0


def status_for_id(session_id: str) -> str:
    if not session_id:
        return 'dead'
    status = query_status(bakery_dir() / f'{session_id}{SOCKET_SUFFIX}')
    return status if status is not None else 'dead'


ShowRecord = tuple[str, str, str | None, str]


def show_record(session: str) -> ShowRecord | None:
    """Resolve (id, name, cwd, state) for a live/pinned/dead session."""
    pins = read_pins()
    if session in pins:
        info = pins[session]
        sid = info.get('sessionId', '')
        return (sid, session, info.get('cwd'), status_for_id(sid))

    base = bakery_dir()
    if is_safe_name(session):
        socket_path = resolve_socket(session)
        status = query_status(socket_path)
        if status is not None:
            sid = socket_path.name[: -len(SOCKET_SUFFIX)]
            names = alias_map(base).get(str(socket_path), [])
            alias_name = names[0] if names else '(none)'
            return (sid, alias_name, cwd_for_id(sid), status)

    record = disk_session_by_ref(session)
    if record is not None:
        sid, cwd, name = record
        return (sid, name or '(none)', cwd, status_for_id(sid))
    return None


def do_show(args: argparse.Namespace) -> int:
    record = show_record(args.session)
    if record is None:
        sys.exit(f'session not found: {args.session}')
    session_id, name, cwd, state = record
    rows = [
        ('ID', session_id),
        ('Name', name),
        ('Working Directory', cwd or '(unknown)'),
        ('State', f'{state_dot(state)} {state}'),
    ]
    width = max(len(label) for label, _ in rows)
    for label, value in rows:
        print(f'{label:<{width}}  {value}')
    return 0


def message_content(payload: object) -> str | None:
    content = payload.get('content') if isinstance(payload, dict) else None
    return content if isinstance(content, str) else None


def blockquote(text: str) -> str:
    return '\n'.join(f'> {line}' for line in text.splitlines())


def working_sections(data: dict[str, object]) -> list[str]:
    """Prior agent reply, the current prompt, then agent replies since it."""
    sections: list[str] = []
    prior = message_content(data.get('priorAgent'))
    if prior:
        sections.append(prior)
    prompt = message_content(data.get('prompt'))
    if prompt:
        sections.append(blockquote(prompt))
    agents = data.get('agentsSince')
    if isinstance(agents, list):
        for item in agents:
            content = message_content(item)
            if content:
                sections.append(content)
    sections.append('(agent is working...)')
    return sections


def do_read(args: argparse.Namespace) -> int:
    command: dict[str, object] = {'type': 'get_message'}
    try:
        response = rpc(resolve_socket(args.session), command, timeout=5.0)
    except (OSError, ValueError) as error:
        sys.exit(f'cannot reach session: {error}')
    if not response.get('success'):
        sys.exit(f'failed: {response.get("error") or "unknown error"}')
    data = response.get('data')
    data = data if isinstance(data, dict) else {}

    if data.get('status') == 'working':
        print('\n\n'.join(working_sections(data)))
        return 0

    content = message_content(data.get('message'))
    if content is not None:
        print(content)
    return 0


def do_wait(args: argparse.Namespace) -> int:
    """Block until the session is idle or blocked (terminal), not working."""
    socket_path = resolve_socket(args.session)
    deadline = time.monotonic() + args.timeout if args.timeout > 0 else None
    while True:
        status = query_status(socket_path)
        if status in ('idle', 'blocked'):
            return 0
        if status is None:
            return 1
        if deadline is None:
            time.sleep(WAIT_POLL_INTERVAL)
            continue
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            return 1
        time.sleep(min(WAIT_POLL_INTERVAL, remaining))


def do_kill(args: argparse.Namespace) -> int:
    command: dict[str, object] = {'type': 'shutdown', 'force': args.force}
    try:
        response = rpc(resolve_socket(args.session), command, timeout=5.0)
    except (OSError, ValueError) as error:
        sys.exit(f'cannot reach session: {error}')
    if not response.get('success'):
        sys.exit(f'failed: {response.get("error") or "unknown error"}')
    print(f'killed {args.session}')
    return 0


def do_send(args: argparse.Namespace) -> int:
    command: dict[str, object] = {
        'type': 'send',
        'message': args.message,
        'mode': args.mode,
    }
    try:
        response = rpc(resolve_socket(args.session), command, timeout=5.0)
    except (OSError, ValueError) as error:
        sys.exit(f'cannot reach session: {error}')
    if not response.get('success'):
        sys.exit(f'failed: {response.get("error") or "unknown error"}')
    print(f'sent to {args.session}')
    return 0


def pins_file() -> pathlib.Path:
    return bakery_dir() / 'pins'


def read_pins() -> dict[str, dict[str, str]]:
    path = pins_file()
    if not path.exists():
        return {}
    try:
        data = json.loads(path.read_text())
    except (OSError, ValueError):
        return {}
    result: dict[str, dict[str, str]] = data if isinstance(data, dict) else {}
    return result


def write_pins(pins: dict[str, dict[str, str]]) -> None:
    path = pins_file()
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(pins, indent=2) + '\n')


def do_pin(args: argparse.Namespace) -> int:
    session_id, cwd, name = find_session(args.session)
    key = args.alias or name
    if not key:
        sys.exit('session has no /name; pass --alias to name the pin')
    pins = read_pins()
    pins[key] = {'sessionId': session_id, 'cwd': cwd}
    write_pins(pins)
    print(f'pinned {key}')
    return 0


def do_unpin(args: argparse.Namespace) -> int:
    pins = read_pins()
    removed = [
        name for name, info in pins.items()
        if args.session in (name, info.get('sessionId'))
    ]
    if not removed:
        sys.exit(f'no pin found: {args.session}')
    for name in removed:
        del pins[name]
    write_pins(pins)
    for name in removed:
        print(f'unpinned {name}')
    return 0


def protected_session_ids() -> set[str]:
    ids = live_session_ids()
    for info in read_pins().values():
        sid = info.get('sessionId')
        if isinstance(sid, str):
            ids.add(sid)
    return ids


def gc_targets() -> list[pathlib.Path]:
    """Stale session files plus their `<TIMESTAMP>_<uuid>/` sidecar dirs."""
    protected = protected_session_ids()
    targets: list[pathlib.Path] = []
    for path in top_level_sessions():
        if path_to_id(path) in protected:
            continue
        targets.append(path)
        sidecar = path.with_suffix('')
        if sidecar.is_dir():
            targets.append(sidecar)
    return targets


def confirm(prompt: str) -> bool:
    try:
        return input(prompt).strip().lower() in ('y', 'yes')
    except EOFError:
        return False


def do_gc(args: argparse.Namespace) -> int:
    targets = gc_targets()
    if not targets:
        print('nothing to collect')
        return 0
    for target in targets:
        print(target)
    prompt = f'delete {len(targets)} path(s)? [y/N] '
    if not args.force and not confirm(prompt):
        print('aborted')
        return 0
    for target in targets:
        if target.is_dir():
            shutil.rmtree(target)
        else:
            target.unlink()
    print(f'deleted {len(targets)} path(s)')
    return 0


def attach_target(session: str) -> tuple[str, str | None] | None:
    """Resolve (session_id, cwd) for a pinned or live session."""
    for name, info in read_pins().items():
        if session in (name, info.get('sessionId')):
            return (info.get('sessionId', ''), info.get('cwd'))
    if is_safe_name(session):
        socket_path = resolve_socket(session)
        if query_status(socket_path) is not None:
            sid = socket_path.name[: -len(SOCKET_SUFFIX)]
            return (sid, cwd_for_id(sid))
    return None


def do_attach(args: argparse.Namespace) -> int:
    target = attach_target(args.session)
    if target is None:
        sys.exit(f'session not found: {args.session}')
    session_id, cwd = target
    if not session_id:
        sys.exit(f'session has no id: {args.session}')
    if cwd:
        os.chdir(pathlib.Path(cwd).expanduser())
    os.execvp('pi', ('pi', '--session-id', session_id))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog='bakery', description=__doc__)
    sub = parser.add_subparsers(dest='command')

    sub.add_parser(
        'list', help='list live sessions',
    ).set_defaults(func=do_list)

    show = sub.add_parser('show', help='show a session id, name, and state')
    show.add_argument('session', help='session id or name')
    show.set_defaults(func=do_show)

    read = sub.add_parser(
        'read', help='print the most recent assistant message',
    )
    read.add_argument('session', help='session id or name')
    read.set_defaults(func=do_read)

    wait = sub.add_parser(
        'wait', help='wait until a session is idle or blocked',
    )
    wait.add_argument('session', help='session id or name')
    wait.add_argument(
        '--timeout',
        type=float,
        default=0.0,
        help='seconds to wait before failing (0 = no timeout)',
    )
    wait.set_defaults(func=do_wait)

    kill = sub.add_parser(
        'kill', help='gracefully shut down an idle session',
    )
    kill.add_argument('session', help='session id or name')
    kill.add_argument(
        '--force',
        action='store_true',
        help='also kill working or blocked (non-idle) sessions',
    )
    kill.set_defaults(func=do_kill)

    send = sub.add_parser('send', help='send a message to a session')
    send.add_argument('session', help='session id or name')
    send.add_argument('message', help='message text')
    send.add_argument(
        '--mode',
        choices=('steer', 'follow_up'),
        default='steer',
        help='delivery mode when the session is busy (default: steer)',
    )
    send.set_defaults(func=do_send)

    pin = sub.add_parser(
        'pin', help='pin a session under its /name',
    )
    pin.add_argument(
        'session',
        nargs='?',
        help='session id or /name (default: infer from current directory)',
    )
    pin.add_argument(
        '--alias',
        help='pin under this name instead of the session /name',
    )
    pin.set_defaults(func=do_pin)

    unpin = sub.add_parser('unpin', help='remove a pinned session')
    unpin.add_argument('session', help='pin name or session id')
    unpin.set_defaults(func=do_unpin)

    gc = sub.add_parser(
        'gc', help='delete session files that are neither live nor pinned',
    )
    gc.add_argument(
        '--force', action='store_true', help='delete without prompting',
    )
    gc.set_defaults(func=do_gc)

    attach = sub.add_parser(
        'attach', help='attach to a live or pinned session',
    )
    attach.add_argument(
        'session', help='pin name, live alias, or session id',
    )
    attach.set_defaults(func=do_attach)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    handler: Callable[[argparse.Namespace], int] | None = getattr(
        args, 'func', None,
    )
    if handler is None:
        parser.print_help()
        return 0
    return handler(args)


if __name__ == '__main__':
    sys.exit(main())
