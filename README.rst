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
