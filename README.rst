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

- irssi. Open PR here: `irssi XDG PR`_.
- ngrok. See `ngrok Config Location`_. TODO: fix this be setting ``-config`` explicitly.
- sqlite. My `sqlite XDG Hack`_ "fixes" this.

.. _XDG Base Directory Spec: https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
.. _irssi XDG PR: https://github.com/irssi/irssi/pull/511
.. _ngrok Config Location: https://ngrok.com/docs#config-location
.. _sqlite XDG Hack: https://github.com/TheKevJames/dotsystem/blob/master/root/~/.config/oh-my-zsh-custom/xdg.zsh#L9-L17
