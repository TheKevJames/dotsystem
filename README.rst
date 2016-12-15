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
