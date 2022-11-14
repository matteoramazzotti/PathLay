.. PathLay documentation master file, created by
   sphinx-quickstart on Mon Nov 14 12:42:19 2022.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to PathLay's documentation!
===================================

.. toctree::
   :maxdepth: 2
   :caption: Contents:


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
* :ref:`Features <features>`
* :ref:`Requirements <requirements>`
	* :ref:`For Building the Docker Image <requirements_docker>`
	* :ref:`For the Apache Server Installation <requirements_apache>`
* :ref:`Installation <installation>`
	* :ref:`Building the Docker Image <installation_docker>`
	* :ref:`Apache Server Installation <installation_apache>`
* :ref:`How to Run<howto>`
	* :ref:`Run PathLay as Localhost <howto_docker_local>`
	* :ref:`Run PathLay as Server <howto_docker_server>`
* :ref:`Usage <usage>`
	* :ref:`Account Managing <usage_account>`
		* :ref:`Register a New Account <usage_account_new>`
		* :ref:`Login to an Existing Account <usage_account_login>`
	* :ref:`Experiment Package <usage_specs>`
		* :ref:`Configuration File <usage_specs_conf>`
		* :ref:`Datasets Files <usage_specs_data>`
	* :ref:`Home Manager <usage_home>`
	* :ref:`Configuration Page <usage_access>`
	* :ref:`Pathway Explorer <usage_results>`
* :ref:`Contribute <contribute>`
* :ref:`Support <support>`
* :ref:`License <license>`


.. _features:

Features
========

.. _requirements:

Requirements
============
	
.. _requirements_docker:
	
For Building the Docker Image (Recommended)
-------------------------------------------
	
* Docker: https://docs.docker.com/get-docker/

.. _requirements_apache:

For the Apache Server Installation
----------------------------------

* Apache: https://httpd.apache.org/download.cgi

.. _installation:

Installation
============

.. _installation_docker:

Building the Docker Image (Recommended)
---------------------------------------

.. code-block::
	:caption: Navigate to the directory with the downloaded DockerFile

	cd directory
	
.. code-block::
	:caption: Build image from DockerFile
	
	docker build -t pathlay .

.. _installation_apache:

Apache Server Installation
--------------------------

.. _howto:

How to run
==========

.. _howto_docker_local:

Run PathLay as Localhost
------------------------

.. code-block::

	docker run --name pathlay_local -d -p 80:80 pathlay


You can check that the container is running with the following:

.. code-block::

	docker ps -a


To access PathLay simply connect to http://localhost/pathlay_2/pathlay_home.html 

.. _howto_docker_server:

Run PathLay as Server
---------------------

.. code-block::

	docker run --name pathlay_server -d -p 80:80 -p 143:143 --network network pathlay


You can check that the container is running on your host machine with the following:

.. code-block::
 
	docker ps -a

Check the IP address of your host machine:

.. code-block::

	hostname -I


To access PathLay from your host machine simply connect to http://localhost/pathlay_2/pathlay_home.html

To access PathLay from a client machine in the same network simply connect to http://host_ip_address/pathlay_2/pathlay_home.html


.. _usage:

Usage
=====

.. _usage_account:

Account Managing
----------------

.. _usage_account_new:

Register a New Account
^^^^^^^^^^^^^^^^^^^^^^

.. _usage_account_login:

Login to an Existing Account
^^^^^^^^^^^^^^^^^^^^^^^^^^^^


.. _usage_specs:

Experiment Package
------------------

In the following section, the structure of a zipped Experiment Package will be explained. Please note that each and avery file listed below can be created and modified from your Home Page direclty, with no need to manually adjust them from outside PathLay.
Each Experiment Package is defined from up to 7 different text files with different extensions:


.. csv-table:: Experiment Package Content
   :file: ./tables/table_exp_package_1.csv
   :widths: 30, 70
   :header-rows: 1

Every experiment created in your Home Page has a name like "exp1,2,3..." automatically assigned. If you want to manually configure an experiment from scratch you have to name your files with this convention in mind (i.e exp1.conf, exp1.mrna, exp1.meta etc...).

.. _usage_specs_conf:

Configuration File
++++++++++++++++++



.. _usage_specs_data:

Datasets Files
++++++++++++++

.. _usage_home:

Home Manager
------------

.. _usage_access:

Configuration Page
------------------


.. _usage_results:

Pathway Explorer
----------------


.. _contribute:

Contribute
==========

.. _support:

Support
=======

.. _license:

License
=======


