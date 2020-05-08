dotsystem
=========

Usage
-----

Clone and run. To update configuration, pull and run. Changes will prompt you.

.. code-block:: console

    git clone https://github.com/thekevjames/dotsystem.git
    cd ./dotsystem
    ./sync [--force] [--secrets] [--skip-packages]

New Machines
------------

If you're provisioning a new machine from scratch, there's some extra steps
that have to be done outside of ``./sync`` to make your machine entirely
bootstrap-able:

.. code-block:: console

    # OSX only: disable SIP by booting into recovery mode (hold cmd-r on boot)
    csrutil disable

    # clone the dotsystem repo and do the initial sync
    git clone https://github.com/thekevjames/dotsystem.git ~/src/personal/dotsystem
    cd ~/src/personal/dotsystem
    ./sync --force
    ./sync --force --secrets

    # Settings > Keyboard > Modifier Keys > "Caps Lock -> Escape"
    # Settings > Keyboard > Customize Touch Bar
    # TODO: figure out if this can be done from the CLI

    # configure bugwarrior-pull as cron job:
    # https://bugwarrior.readthedocs.io/en/latest/using.html#cron
    # TODO: install crontab from ./sync

    # install youtube-viewer:
    # https://github.com/trizen/youtube-viewer
    # TODO: after Homebrew/homebrew-core#43254, add youtube-viewer to packages

    # OSX TODOs:
    # configure Amphetamine
    # switch workspace switch hotkeys to cmd+ctrl arrows (not ctrl-arrows)
    # switch screenshot hotkeys
    # enable two-finger-touch as right click

Old Machines
------------

When sunsetting a machine, there's not much that needs to be done:

.. code-block:: console

    # invalidate your ssh key (https://github.com/settings/keys)
    curl \
        -XDELETE \
        -su "thekevjames:$(lpass show --note dotsystem/github-token)" \
        "https://api.github.com/user/keys/$(curl \
            -su "thekevjames:$(lpass show --note dotsystem/github-token)" \
            https://api.github.com/user/keys | jq '.[] | select(.title == "'"$(hostname)"'").id')"

    # revoke personal access tokens (https://github.com/settings/tokens)
    # TODO: these are somewhat manually provisioned (in secrets.m4) -- it'd be
    # great to have ``./sync --secrets`` generate them on-the-fly, then include
    # a ``./sync --revoke``.

    # nuke your homedir
    sudo rm -Prf ~

Secrets
-------

Secrets are interpolated into configuration files with ``m4``. They should be
stored in ``${XDG_DATA_HOME}/dotsystem/secrets.m4``, which ``./sync --secrets``
will pull from LastPass (configurable key name: ``dotsystem/secrets``).

``dotsystem`` will run even if that file does not exist or is missing secrets,
but any configurations expecting secrets will be sorely disappointed.

You can find a `sample secrets file`_ in this repo.

.. _sample secrets file: secrets.m4.sample

XDG Wall of Shame
-----------------

I am a huge fan of the `XDG Base Directory Spec`_. The following configured
apps don't follow that spec. Note that this list includes both apps that may
eventually accept be fixed as well as apps that have decided they're
`special snowflakes`_ and are thus above needing to implement the XDG spec.

- arc. Support with ``--arcrc-file`` flag.
- cargo. `cargo is a snowflake`_. Partial support by setting ``$CARGO_HOME``
  and adding ``${CARGO_HOME}/bin`` to your ``$PATH``. Update: the old
  maintainer who was ardently in favor of keeping cargo's snowflake status is
  taking a break from cargo development. Looks like the `cargo XDG RFC`_ is
  going through in the meantime!
- cpan. Partial support with ``-j`` flag and setting values in your
  ``Config.pm`` to XDG-compliant ones.
- docker. Support by setting ``$DOCKER_CONFIG``. In-progress real support:
  `docker XDG issue`_ (including a couple failed `docker XDG PR`_ s).
- gnupg. `gnupg is a snowflake`_. Partial support by setting ``$GNUPGHOME``.
- gmailctl. Support with ``--config`` flag.
- go. Support by setting ``$GOPATH``.
- helm. Support by setting ``$HELM_HOME``.
- irb. Partial support by setting ``$IRBRC``.
- irssi. Partial support with ``--home`` flag.
- jira. But `at least jira has a TODO`_.
- julia. Support by setting ``$JULIA_PKGDIR`` and ``$JULIA_HISTORY``.
- kubectl. Partial suport by setting ``$KUBECONFIG`` and with the
  ``--cache-dir`` flag. They have a second cachedir at ``~/.kube/cache``. But
  `at least kubectl has a TODO`_ for that one.
- less. Support by setting ``$LESSHISTFILE``.
- libice. Partial support by setting ``$ICEAUTHORITY``.
- lmms. Partial support with ``--config`` flag.
- mysql. Support by setting ``$MYSQL_HISTFILE``.
- ngrok. Support with ``--config`` flag. Because this flag has some
  restrictions, see my `ngrok XDG hack`_ for a "fix".
- npm. Support by setting ``$NPM_CONFIG_USERCONFIG``, then setting ``cache`` in
  that file.
- postgres. Support by setting ``$PSQLRC``.
- pulseaudio. No support. Only an issue if the
  ``module-esound-protocol-unix.so`` module is loaded.
- pyenv. Support by setting ``$PYENV_ROOT``.
- pylint. Support by setting ``$PYLINTHOME``.
- python. Technical support by setting ``$PYTHONSTARTUP`` to a script which
  modifies your history file location (note: for both python2 and python3). See
  my `python XDG hack`_.
- readline. Support by setting ``$INPUTRC``.
- redis. Support by setting ``$REDISCLI_HISTFILE``.
- rustup. `rustup is a snowflake`_. Partial support by setting
  ``$RUSTUP_HOME``. Update: the old maintainer who was ardently in favor of
  keeping rustup's snowflake status is taking a break from rustup development.
  Looks like the `cargo XDG RFC`_ is going through in the meantime!
- sqlite. Support for config file with ``-init`` flag. History file is
  hardcoded. See my `sqlite XDG hack`_.
- taskwarrior. Support by setting ``$TASKRC`` and ``$TASKDATA``.
- theano. Support by setting ``$THEANORC`` and including ``base_compiledir`` in ``$THEANO_FLAGS``.
- tmux. Support with ``-f`` flag.
- wget. Support with ``--hsts-file`` flag.
- wine. Support by setting ``$WINEPREFIX``.
- zsh. Partial support by setting ``$ZDOTDIR`` and ``$HISTFILE``. Your
  ``~/.zshenv`` file is effectively hardcoded.

.. _at least jira has a TODO: https://github.com/go-jira/jira/issues/235
.. _at least kubectl has a TODO: https://github.com/kubernetes/client-go/commit/a0e8687452a46a2f67a9a1bf457521dc1cf89960b
.. _cargo is a snowflake: https://github.com/rust-lang/rfcs/pull/1615
.. _cargo XDG RFC: https://github.com/rust-lang/rfcs/pull/1615#issuecomment-323556940
.. _docker XDG issue: https://github.com/docker/docker/issues/20693
.. _docker XDG PR: https://github.com/docker/docker/pull/30025
.. _gnupg is a snowflake: https://bugs.gnupg.org/gnupg/issue1456
.. _ngrok XDG hack: https://github.com/TheKevJames/dotsystem/blob/e28041fbd3ddf68bdc951ca41cca03d325b7f6df/root/~/.config/oh-my-zsh-custom/xdg.zsh#L22-L31
.. _python XDG hack: https://github.com/TheKevJames/dotsystem/blob/master/root/etc/pythonstart
.. _rustup is a snowflake: https://github.com/rust-lang-nursery/rustup.rs/issues/247
.. _special snowflakes: https://github.com/rust-lang-nursery/rustup.rs/issues/247#issuecomment-219213895
.. _sqlite XDG hack: https://github.com/TheKevJames/dotsystem/blob/e28041fbd3ddf68bdc951ca41cca03d325b7f6df/root/~/.config/oh-my-zsh-custom/xdg.zsh#L33-L38
.. _XDG Base Directory Spec: https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
