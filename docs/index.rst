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
		* :ref:`Supported IDs <usage_specs_ids>`
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

Every experiment created in your Home Page has a name like "exp1,2,3..." automatically assigned. If you want to manually configure an experiment from scratch you have to name your files with this convention in mind (i.e. exp1.conf, exp1.mrna, exp1.meta etc...).

.. _usage_specs_conf:

Configuration File
^^^^^^^^^^^^^^^^^^

The configuration file for the Experiment Package is structured as a series of tag and value pairs, separated by a "=" character, with each line of the file holding one pair.

.. csv-table:: Configuration File Tags
   :file: ./tables/table_exp_package_2.csv
   :widths: 15, 50, 30
   :header-rows: 1

An example of a fully configured .conf file is displayed below:

.. code-block:: 
	:caption: Structure of a .conf file of an Experiment Package with Transcriptomic, Proteomic, miRNomic, Methylomic and Metabolomic datasets associated

	expname=LTED vs MCF7+
	comments=ANOVA adj.p + Tukey
	idcol=8
	datacol=6
	datatype=logFC
	datadir=out
	datathr=1
	pcol=5
	pthr=0.05
	midcol=1
	mdatacol=6
	mdatatype=logFC
	mdatadir=out
	mdatathr=1
	mpcol=5
	mpthr=0.05
	metidcol=8
	metdatacol=6
	metdatatype=logFC
	metdatadir=out
	metdatathr=1
	metpcol=5
	metpthr=0.05
	methidcol=8
	methdatacol=6
	methdatatype=logFC
	methdatadir=out
	methdatathr=1
	methpcol=5
	methpthr=0.05
	protidcol=1
	protdatacol=4
	protdatatype=logFC
	protdatadir=out
	protdatathr=1
	protpcol=3
	protpthr=0.05

The experiment Package is named "LTED vs MCF7+" and we can see it has all the -omics datasets currently supported by PathLay associated to it, and we can read their configurations as it follows:

*	The Transcriptomic datataset has its IDs stored in the 8th column, logFC values stored in the 6th column and p-values stored in the 5th column. IDs with a p-value minor than 0.05 and logFC minor or major than 1 will be kept during PathLay's analysis.

*	The miRNomic datataset has its IDs stored in the 1st column, logFC values stored in the 6th column and p-values stored in the 5th column. IDs with a p-value minor than 0.05 and logFC minor or major than 1 will be kept during PathLay's analysis.

*	The Metabolomic datataset has its IDs stored in the 8th column, logFC values stored in the 6th column and p-values stored in the 5th column. IDs with a p-value minor than 0.05 and logFC minor or major than 1 will be kept during PathLay's analysis.

*	The Methylomic datataset has its IDs stored in the 8th column, logFC values stored in the 6th column and p-values stored in the 5th column. IDs with a p-value minor than 0.05 and logFC minor or major than 1 will be kept during PathLay's analysis.

*	The Proteomic datataset has its IDs stored in the 1st column, logFC values stored in the 4th column and p-values stored in the 3rd column. IDs with a p-value minor than 0.05 and logFC minor or major than 1 will be kept during PathLay's analysis.

.. note::
	Experiment Packages can be created and configured in your Home Page with a more intuitive approach. Once the "Save" button is clicked the .conf file will be automatically generated and saved in your home folder.


.. _usage_specs_data:

Datasets Files
^^^^^^^^^^^^^^

Each dataset file (i.e. .mrna, .prot, .mirna, .meta and .meth files) is a tab separated file that can have any number of columns but at least one, two or three, depending on the Analysis Mode you will choose for PathLay (see more in Configuration Page section). An "ID Only" analysis just requires an ID list in your dataset file, an "ID + DE" analysis requires an ID list with Expression Values associated and a "Full" analysis requires all the above plus a list of p-values associated to each ID.

.. note::
	Datasets can be copied and pasted in their related text areas in your Home Page. Once the "Save" button is clicked the dataset file will be created in your home folder and named after the experiment.


.. _usage_specs_ids:

Supported IDs
^^^^^^^^^^^^^

.. csv-table:: Compatible IDs to use in your Datasets
   :file: ./tables/table_exp_package_3.csv
   :widths: 50, 50
   :header-rows: 1


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


