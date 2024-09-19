.. _requirements_apache:

----------------------------------
For the Apache Server Installation
----------------------------------

#. Install main dependencies:
	On Debian based distros you can install dependencies with the following:

	.. code-block::

		apt install apache2 apache2-utils cpanminus libcanberra-gtk-module:amd64 libexpat1-dev:amd64 libgd-dev:amd64 libgtk2.0-0:amd64 liblocal-lib-perl libssl-dev:amd64 packagekit-gtk3-module tar tcl zip



#. Install perl modules:
	Using cpanminus:

	.. code-block::

		cpanm CGI ExtUtils::PkgConfig Bio::FdrFet Statistics::Distributions  GD Archive::Zip