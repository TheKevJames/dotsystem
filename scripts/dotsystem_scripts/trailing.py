"""
Move the comment lines that ruamel hangs off a node's last leaf.

ruamel keeps a comment between two blocks on the last leaf of the first, so
dropping, replacing, or extending that block would drop or misplace the
comment. Text moved here is the lines after a leaf, led by the newline ending
the leaf's own line, or empty.
"""

from ruamel.yaml import comments
from ruamel.yaml import error
from ruamel.yaml import tokens

Container = comments.CommentedMap | comments.CommentedSeq


def join(head: str, tail: str) -> str:
    return head + tail[1:] if head and tail else head or tail


def _split(value: str) -> tuple[str, str]:
    """Split a ruamel post-item comment into end-of-line and following."""
    own = ''
    if not value.startswith('\n'):
        own, _, rest = value.partition('\n')
        own += '\n'
        value = f'\n{rest}' if rest else ''
    return own, value if len(value) > 1 else ''


def _last_entry(node: object) -> tuple[Container, object, int] | None:
    """
    `node`'s last entry: the node, its key, and that key's post-comment slot.

    None for scalars and empty or flow-style containers, which hold no
    comment lines of their own.
    """
    if not isinstance(node, Container) or node.fa.flow_style() or not node:
        return None
    if isinstance(node, comments.CommentedMap):
        return node, list(node)[-1], 2
    return node, len(node) - 1, 0


def _child(node: Container, key: object) -> object:
    if isinstance(node, comments.CommentedMap):
        return node[key]
    return node[key] if isinstance(key, int) else None


def pop(node: object) -> str:
    """
    Detach the comment lines that follow `node`, e.g. a repo block.

    A comment on the last leaf's own line belongs to the leaf and stays.
    """
    last = _last_entry(node)
    if last is None:
        return ''
    container, key, pos = last
    text = pop(_child(container, key))
    entry = container.ca.items.get(key)
    if entry and entry[pos] is not None:
        own, following = _split(entry[pos].value)
        text = join(text, following)
        if own:
            entry[pos].value = own
        else:
            entry[pos] = None
    if container.ca.end:
        ended = ''.join(token.value for token in container.ca.end)
        text = join(text, _split(f'\n{ended}')[1])
        container.ca.end = None
    return text


def push(node: object, text: str) -> None:
    """Hang comment lines from `pop` after `node`."""
    last = _last_entry(node)
    if not text or last is None:
        return
    container, key, pos = last
    child = _child(container, key)
    if _last_entry(child) is not None:
        push(child, text)
        return
    entry = container.ca.items.setdefault(key, [None, None, None, None])
    if entry[pos] is None:
        entry[pos] = tokens.CommentToken(text, error.CommentMark(0), None)
    else:
        entry[pos].value += text[1:]
