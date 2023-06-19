dotsystem
=========

Usage
-----

Clone and run. To update configuration, pull and run. Changes will prompt you.

.. code-block:: console

    git clone https://github.com/thekevjames/dotsystem.git
    cd ./dotsystem
    ./sync [--force] [--skip-packages]

New Machines
------------

If you're provisioning a new machine from scratch, there's some extra steps
that have to be done outside of ``./sync`` to make your machine entirely
bootstrap-able:

.. code-block:: console

    # OSX only: disable SIP by booting into recovery mode (intel: hold cmd-r on boot, m1: hold power button)
    csrutil disable

    # clone the dotsystem repo and do the initial sync
    git clone https://github.com/thekevjames/dotsystem.git ~/src/personal/dotsystem
    cd ~/src/personal/dotsystem
    ./sync --force

Old Machines
------------

When sunsetting a machine, there's not much that needs to be done:

.. code-block:: console

    # check for anything which needs backing up
    ./discover

    # check for unpushed branches
    cd ~/src/*
    git-wips

    # invalidate your ssh key (https://github.com/settings/keys)
    gh ssh-key delete $(hostname)

    # nuke your homedir
    sudo rm -Prf ~

XDG
---

I am a huge fan of the `XDG Base Directory Spec`_. Unfortunately, many apps
don't follow that spec unless they're coerced into it via env vars, CLI flags,
etc. Some don't support it env then.

I generally go through and try to keep things as clean as possible.
`xdg-ninja`_ is a fantastic tool for this and has a great database of fixes.
The following are some extra fixes that I worked out before coming across
``xdg-ninja``... at some point, I'll open some PRs and move 'em over.

- arc. Support with ``--arcrc-file`` flag.
- cpan. Partial support with ``-j`` flag and setting values in your
  ``Config.pm`` to XDG-compliant ones.
- gmailctl. Support with ``--config`` flag.
- helm. Support by setting ``$HELM_HOME``.
- irb. Partial support by setting ``$IRBRC``.
- jira. But `at least jira has a TODO`_.
- julia. Support by setting ``$JULIA_PKGDIR`` and ``$JULIA_HISTORY``.
- kubectl. Suport by setting ``$KUBECONFIG`` and ``$KUBECACHEDIR``
- theano. Support by setting ``$THEANORC`` and including ``base_compiledir`` in ``$THEANO_FLAGS``.
- zsh. Partial support by setting ``$ZDOTDIR`` and ``$HISTFILE``. Your
  ``~/.zshenv`` file is effectively hardcoded.

.. _XDG Base Directory Spec: https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
.. _at least jira has a TODO: https://github.com/go-jira/jira/issues/235
.. _xdg-ninja: https://github.com/b3nj5m1n/xdg-ninja
