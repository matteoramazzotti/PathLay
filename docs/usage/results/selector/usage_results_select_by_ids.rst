.. _usage_results_logical_byids:

Select by IDs
-------------

The first row in the Logical Section is composed by a selector that allows the selection of a data type between "Gene", "Protein", TFs, "miRNA", "Methylation", "Chromatin" and "Metabolite", depending on your analysis configuration.
Selecting one data type will pop up another selector with a list of IDs of the data type chosen, in a similar fashion of the HighLight section.
Once an ID is selected, it can be added to the query pool "IDs Selected".
Every ID added to the pool will be represented as a query tag and can be removed from the pool by clicking the "X" button on the right.
IDs' query tag have colors are assigned considering the data type:

	* Light blue for genes
	* Purple for proteins
	* Red for miRNAs
	* Yellow for Metabolites
	* Grey for TFs, Methylations and Chromatin Statuses
	
The "Select" button will perform a pathway selection using the pool content as criteria: considering a strictly ID based query, only those pathways portraying all the IDs in the pool will be displayed in the pathway selector and kept available.

.. warning::
	It is possible that loaded pathways cannot satisfy the requirements for the selection made. In this case the pathway selector will become empty. Resetting the selection with the "Reset" button will restore the pathway selector at its default state.
