dotsystem
=========

Usage
-----

Clone and run. To update configuration, pull and run. Changes will prompt you.

.. code-block:: console

    git clone https://github.com/thekevjames/dotsystem.git ~/src/personal/dotsystem
    cd ~/src/personal/dotsystem
    ./sync [--force] [--skip-packages]

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
