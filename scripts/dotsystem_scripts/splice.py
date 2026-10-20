"""
Swap hooks in a pre-commit config's repo blocks, keeping their comments.

A block emptied of its hooks stays behind as a hole, holding its place and the
comment lines that followed it, until new blocks fill it or it is dropped.
"""

from ruamel.yaml import comments

from . import trailing


def take_hooks(
    blocks: comments.CommentedSeq, owned: set[str]
) -> dict[int, str]:
    """
    Remove the `owned` hooks from `blocks`, emptied blocks staying as holes.

    Returns each hole's index with the comment lines that followed it.
    """
    holes: dict[int, str] = {}
    for idx, block in enumerate(blocks):
        hooks = block.get('hooks', [])
        taken = [pos for pos, h in enumerate(hooks) if h.get('id') in owned]
        if not taken:
            continue
        following = trailing.pop(block) if taken[-1] == len(hooks) - 1 else ''
        for pos in reversed(taken):
            del hooks[pos]
        if hooks:
            trailing.push(block, following)
        else:
            holes[idx] = following
    return holes


def place_blocks(
    blocks: comments.CommentedSeq,
    holes: dict[int, str],
    new: list[comments.CommentedMap],
) -> None:
    """
    Put `new` blocks into `blocks`, then drop the holes left unfilled.

    A new block fills the next hole with its repo URL in place, and otherwise
    goes where the first hole was, or after the last block placed.
    """
    cursor = min(holes, default=len(blocks))
    for block in new:
        hole = next(
            (
                idx
                for idx in sorted(holes)
                if idx >= cursor and blocks[idx].get('repo') == block['repo']
            ),
            None,
        )
        if hole is None:
            blocks.insert(cursor, block)
            holes = {i + (i >= cursor): text for i, text in holes.items()}
            cursor += 1
            continue
        following = holes.pop(hole)
        blocks[hole].update(block)
        trailing.push(blocks[hole], following)
        cursor = hole + 1
    for idx in sorted(holes, reverse=True):
        following = holes.pop(idx)
        del blocks[idx]
        if idx - 1 in holes:
            holes[idx - 1] = trailing.join(holes[idx - 1], following)
        elif idx:
            trailing.push(blocks[idx - 1], following)
