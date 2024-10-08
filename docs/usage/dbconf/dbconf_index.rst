.. _usage_dbconf:


Database Configuration
**********************

.. toctree::
	:hidden:

	dbconf_org_selection
	dbconf_interactions
	dbconf_pathways
	dbconf_backup_repo


.. figure:: /usage/dbconf/img/welcome_settings.png
   :alt: access
   :width: 100%
   :align: center

   


Database configuration is accessible only from the host machine where PathLay is installed, this is due to avoid that many users in parallel can run it.
It is a crucial step to be performed to make PathLay usable and it articulates as follows:

#. Select the organism to Configure

#. Check for files regarding components interactions

#. Check for pathway files

.. warning::
	There could be problems during the installation.
	If that happens please refer to the :ref:`dbconf_backup_repo` section.

.. include:: /usage/dbconf/dbconf_org_selection.rst
.. include:: /usage/dbconf/dbconf_interactions.rst
.. include:: /usage/dbconf/dbconf_pathways.rst
.. include:: /usage/dbconf/dbconf_backup_repo.rst

