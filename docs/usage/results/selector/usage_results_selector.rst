.. _usage_results_logical:

^^^^^^^^^^^^^^^^^^^^^
The Selectors Section
^^^^^^^^^^^^^^^^^^^^^

.. toctree::
	:hidden:

	usage_results_select_by_ids
	usage_results_select_by_agreement


This section contains the main query system of the "PathLay - MAPS" page allowing to perform a more sophisticate three level selection by:
	* IDs
	* Agreement between two components
	* Ontology (Cellular Compartments)

These selections can be performed by adding a query tag using one of the three selectors and clicking the respective "Add" button. 
Once all the query tags you are interested in are added to the pool on the right, the query can be performed by clicking the "Select" button.

A brief summary of the rationale behind the query is the following:
	* The IDs provided are rounded up and only those maps that contains indicators representing them are allowed to proceed in the query. Is important to note that this step works with an "AND" approach so, whenever a map does not represent even one of the IDs provided, it is discarded and thus removed from the selector.
	* The Agreements provided are rounded up and the indicators that are currently displayable or that passed the previous step of the query, are checked for all the Agreements. Whenever an agreement is not satisfied, the indicator is hidden and if all the indicators in a specific map don't satisfy the agreements, the map is discarded and removed from the selector.
	* The Ontologies provided are rounded up and the indicators that are currently displayable or that passed the previous step of the query, are checked for components that refers to the cellular compartments selected. Whenever an indicator doesn't refer to one of the compartments selected, it is hidden and if all the indicators in a specific map don't refer to the cellular compartments, the map is discarded and removed from the map selector.

To reset the interface to its default state simply click the "Reset" button next to it.
Details on each type of query tag are provided below.


.. include:: usage_results_select_by_ids.rst
.. include:: usage_results_select_by_agreement.rst