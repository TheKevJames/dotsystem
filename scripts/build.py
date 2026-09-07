import subprocess


def build(setup_kwargs: dict[str, object]) -> dict[str, object]:
    subprocess.run(['make'], check=True)
    return setup_kwargs


build({})
