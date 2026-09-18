import subprocess

from hatchling.builders import config
from hatchling.builders.hooks.plugin import interface
from hatchling.plugin import manager


class CustomBuildHook(
    interface.BuildHookInterface[
        config.BuilderConfig[manager.PluginManager], manager.PluginManager
    ]
):
    def initialize(self, version: str, build_data: dict[str, object]) -> None:  # pylint: disable=unused-argument
        subprocess.run(['make'], check=True, cwd=self.root)
