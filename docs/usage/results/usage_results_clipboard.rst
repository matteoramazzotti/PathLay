.. _usage_results_clipboard:

^^^^^^^^^^^^^
The Clipboard
^^^^^^^^^^^^^

The Clipboard is a freely movable window that will be displayed as soon as the "Clipboard" writing is clicked in the menu.
It is composed by two boxes, the "Info" box and the "Selected" box.
The "Info" box will display the information related to a clicked indicator, this includes every ID that the indicator is portaying, with their differential expression values and other IDs eventually linked.
Cliking on the IDs in the "Info" box will open up a page in the online database of reference for that data type:

	* NCBI for genes 
	* UniProtKB for proteins 
	* Mirtarbase for miRNAs
	* gsea-msigdb for TFs.

Once you have clicked an indicator on a pathway and its information is displayed on the Clipboard, you can click the "Add" button below the "Info" box and save the indicator inside the Clipboard's "Selected" box.
It will be listed as a smaller indicator under the name of the pathway from where the selction has been performed.
Selecting this smaller indicator in the box will also display its information in the "Info" box and if the "Remove" button is clicked, the indicator will be removed from the "Selected" box.
The "Select" button under the "Selected" box on the Clipboard performs the same operations as the highlight button in the Highlight Section, thus applying a dotted magenta border on the indicators of interest and disabling maps not containing them in the map selector.
The last feature provided by the Clipboard is the "Download" button which allows to download a tab separated text document listing all the information regarding selected indicators currently populating the "Selected" box.

.. note::
	Closing the Clipboard by clicking the "X" on the top right corner will not delete any selected indicator from the "Selected" box.
