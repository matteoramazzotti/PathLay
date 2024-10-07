.. _usage_access_stat:


Maps Restriction Procedure
==========================

.. toctree::
   :hidden:

   usage_access_stat_pool
   usage_access_stat_intersect




It is possible to perform a selection of maps to display in the PathLay - MAPS page by enabling Fisher's Exact Test for desired datasets.
Maps are selected with a statistical approach based on the Fisher's Exact Test and since PathLay integrates different datasets, it is also possible to select which dataset will contribute on the map selection.
By default the test is performed on each dataset enabled and it will produce a list of maps considered of importance, all the lists produced are then joined into one.
There are two tweaks available that can change the result of this step: the Intersect option and the Pooling option.


.. figure:: /usage/access/img/stat.png
   :alt: access
   :width: 50%
   :align: center

   Screenshot of the Configuration interface.



.. warning::
	To perform the test you need to provide a dataset that holds a p-value column. 


.. include:: /usage/access/stat/usage_access_stat_pool.rst
.. include:: /usage/access/stat/usage_access_stat_intersect.rst



