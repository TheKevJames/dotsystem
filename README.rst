dotsystem
=========

Usage
-----

Clone and run. To update configuration, pull and run. Changes will prompt you.

::

    git clone https://github.com/thekevjames/dotsystem.git
    ./dotsystem/sync [--skip-packages]

Secrets
-------

Secrets are interpolated into configuration files with ``m4``. They should be stored in ``${XDG_DATA_HOME}/dotsystem/secrets.m4``. ``dotsystem`` will run even if that file does not exist or is missing secrets, some things may just be misconfigured. Updating the secrets file and re-running ``sync`` will insert the updated secrets into your configuration.

Sample ``secrets.m4``::

.. literalinclude:: secrets.m4.sample

XDG Wall of Shame
-----------------

I am a huge fan of the `XDG Base Directory Spec`_. The following configured apps don't follow that spec. Note that this list includes both apps that may eventually accept be fixed as well as apps that have decided they're `special snowflakes`_ and are thus above needing to implement the XDG spec.

- cargo. `cargo is a snowflake`_. Partial support by setting ``$CARGO_HOME`` and adding ``${CARGO_HOME}/bin`` to your ``$PATH``.
- cpan. Partial support with ``-j`` flag and setting values in your ``Config.pm`` to XDG-compliant ones.
- docker. Support by setting ``$DOCKER_CONFIG``. In-progress real support: `docker XDG issue`_ and `docker XDG PR`_.
- gnupg. `gnupg is a snowflake`_. Partial support by setting ``$GNUPGHOME``.
- irb. Partial support by setting ``$IRBRC``.
- irssi. Partial support with ``--home`` flag.
- less. Support by setting ``$LESSHISTFILE``.
- libice. Partial support by setting ``$ICEAUTHORITY``.
- lmms. No support. In 1.2.0 (pre-release), will have partial support with ``--home`` flag.
- mysql. Support by setting ``$MYSQL_HISTFILE``.
- ngrok. Support with ``--config`` flag. Because this flag has some restrictions, see my `ngrok XDG hack`_ for a "fix".
- postgres. Support by setting ``$PSQLRC``.
- pulseaudio. No support. Only an issue if the ``module-esound-protocol-unix.so`` module is loaded.
- python. Technical support by setting ``$PYTHONSTARTUP`` to a script which modifies your history file location (note: for both python2 and python3). See my `python XDG hack`_.
- readline. Support by setting ``$INPUTRC``.
- redis. Support by setting ``$REDISCLI_HISTFILE``.
- rustup. `rustup is a snowflake`_. Partial support by setting ``$RUSTUP_HOME``.
- sqlite. Support for config file with ``-init`` flag. History file is hardcoded. See my `sqlite XDG hack`_.
- zsh. Partial support by setting ``$ZDOTDIR`` and ``$HISTFILE``. Your ``~/.zshenv`` file is effectively hardcoded.

.. _XDG Base Directory Spec: https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
.. _cargo is a snowflake: https://github.com/rust-lang/rfcs/pull/1615
.. _docker XDG issue: https://github.com/docker/docker/issues/20693
.. _docker XDG PR: https://github.com/docker/docker/pull/30025
.. _gnupg is a snowflake: https://bugs.gnupg.org/gnupg/issue1456
.. _ngrok XDG hack: https://github.com/TheKevJames/dotsystem/blob/master/root/~/.config/oh-my-zsh-custom/xdg.zsh#L14-L23
.. _rustup is a snowflake: https://github.com/rust-lang-nursery/rustup.rs/issues/247
.. _special snowflakes: https://github.com/rust-lang-nursery/rustup.rs/issues/247#issuecomment-219213895
.. _python XDG hack: https://github.com/TheKevJames/dotsystem/blob/master/root/etc/pythonstart
.. _sqlite XDG hack: https://github.com/TheKevJames/dotsystem/blob/master/root/~/.config/oh-my-zsh-custom/xdg.zsh#L25-L30
