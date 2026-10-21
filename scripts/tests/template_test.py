import tomllib

from dotsystem_scripts import template


def test_feature_declarations_are_in_sync() -> None:
    """
    The Feature enum, features/ subdirs, and config.toml tables must agree.

    Each feature is defined in three places; drift between them silently breaks
    install/detection, so a single source going missing should fail loudly.
    """
    enum_values = {feature.value for feature in template.Feature}

    features_root = template.source_dir() / template.FEATURES_DIRNAME
    dir_names = {
        path.name for path in features_root.iterdir() if path.is_dir()
    }

    tables = tomllib.loads(
        (template.source_dir() / template.CONFIG_NAME).read_text()
    ).get(template.FEATURES_DIRNAME, {})
    table_names = set(tables)

    assert enum_values == dir_names == table_names
    # `placement` is mandatory and drives install/detect; an unknown or missing
    # value must fail loudly rather than silently defaulting.
    for spec in tables.values():
        template.Placement(spec['placement'])


def test_zizmor_ships_with_its_config() -> None:
    """
    The zizmor hook and the config that opts in to its audits ship together.

    Without .github/zizmor.yml, zizmor runs every audit it knows, so syncing
    the hook alone would turn templated repos' lint red.
    """
    source = template.source_dir()
    precommit = template.yaml.load(source / template.PRECOMMIT_CONFIG)
    hook_ids = {
        hook['id'] for repo in precommit['repos'] for hook in repo['hooks']
    }
    assert 'zizmor' in hook_ids

    rules = template.yaml.load(source / '.github' / 'zizmor.yml')['rules']
    enabled = {'artipacked', 'dangerous-triggers', 'excessive-permissions'}
    assert enabled.isdisjoint(rules)
    assert all(rule == {'disable': True} for rule in rules.values())
