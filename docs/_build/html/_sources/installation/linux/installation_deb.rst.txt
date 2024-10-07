.. _installation_deb:


Installation with .deb package
==============================

You can install PathLay from the deb package on Ubuntu-based distributions (tested on Ubuntu 22.04 and Mint Virginia):

#. Go to the directory where the deb file is located and execute the following:

   .. code-block:: bash

      sudo dpkg -i pathlay_0.1.0-alpha.4_Ubuntu-jammy_amd64.deb

#. If the installer reports missing dependencies, run the following command in the same terminal to install them:

   .. code-block:: bash

      sudo apt-get -f install
