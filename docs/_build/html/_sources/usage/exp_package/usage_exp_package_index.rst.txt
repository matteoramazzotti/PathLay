.. _usage_specs:


Experiment Package
******************

.. toctree::
	:hidden:

	usage_exp_package_conf
	usage_exp_package_specs_data
	usage_exp_package_specs_ids

In the following section, the structure of a zipped Experiment Package will be explained. Please note that each and avery file listed below can be created and modified from your Home Page direclty, with no need to manually adjust them from outside PathLay.
Each Experiment Package is defined from up to 7 different text files with different extensions:


.. csv-table:: Experiment Package Content
   :file: ./tables/usage_exp_package_table_1.csv
   :widths: 30, 70
   :header-rows: 1

Every experiment created in your Home Page has a name like "exp1,2,3..." automatically assigned. If you want to manually configure an experiment from scratch you have to name your files with this convention in mind (i.e. exp1.conf, exp1.mrna, exp1.meta etc...).

.. include:: usage_exp_package_conf.rst
.. include:: usage_exp_package_specs_data.rst
.. include:: usage_exp_package_specs_ids.rst	