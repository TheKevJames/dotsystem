dotsystem
=========

Usage
-----

Clone and run. To update configuration, pull and run. Changes will prompt you.

::

    git clone https://github.com/thekevjames/dotsystem.git
    ./dotsystem/sync

Secrets
-------

Secrets are interpolated into configuration files with ``m4``. They should be stored in ``${XDG_DATA_HOME}/dotsystem/secrets.m4``. ``dotsystem`` will run even if that file does not exist or is missing secrets, some things may just be misconfigured. Updating the secrets file and re-running ``sync`` will insert the updated secrets into your configuration.

Sample ``secrets.m4``::

    divert(-1)
    define(`IRC_PASSWORD', `my-password')
    define(`M4_HOMEBREW_GITHUB_API_TOKEN', `my-github-token')
    define(`NGROK_AUTHTOKEN', `my-ngrok-token')
    define(`TRANSMISSION_PASSWORD', `my-rpc-password')
    define(`TRANSMISSION_USERNAME', `my-rpc-username')
    divert(0)dnl

XDG Wall of Shame
-----------------

I am a huge fan of the `XDG Base Directory Spec`_. The following configured apps don't follow that spec:

- irb. Setting ``$IRBRC`` works around this.
- irssi. My `irssi XDG alias`_ works around this.
- less. Setting ``$LESSHISTFILE`` somewhat works around this.
- lmms. In 1.2.0 can be solved with ``--home``, but that's still a pre-release.
- mysql. Setting ``$MYSQL_HISTFILE`` somewhat works around this.
- ngrok. Can be overriden with ``--config``... but only for some commands. These ``--config`` arguments are applied in order. My `ngrok XDG hack`_ tries to deal with this.
- postgres. Setting ``$PSQLRC`` fixes this.
- python. Setting ``$PYTHONSTARTUP`` works around this.
- readline. Setting ``$INPUTRC`` fixes this.
- redis. Setting ``$REDISCLI_HISTFILE`` somewhat works around this.
- sqlite. My `sqlite XDG hack`_ "fixes" this.

.. _XDG Base Directory Spec: https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
.. _irssi XDG alias: https://github.com/TheKevJames/dotsystem/blob/master/root/~/.config/oh-my-zsh-custom/xdg.zsh#L27
.. _ngrok XDG hack: https://github.com/TheKevJames/dotsystem/blob/master/root/~/.config/oh-my-zsh-custom/xdg.zsh#L8-L17
.. _sqlite XDG hack: https://github.com/TheKevJames/dotsystem/blob/master/root/~/.config/oh-my-zsh-custom/xdg.zsh#L19-L25
