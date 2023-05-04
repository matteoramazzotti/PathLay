.. _usage_home_create:

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Creating an Experiment Package
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To create an Experiment Package from scratch the first thing to do is to click the "Add New" button and then assign it a name in the "Experiment Title" text box, you can also comment it in the "Comments" text box located below.
Next, you should assign it an organism between hsa and mmu from the Organism selector. 
You can now proceed to load your datasets on PathLay. 
Data types supported may come from Transcriptomic (Genes), miRNomic (miRNAs), Metabolomic (Metabolites), Methylomic (Methylations), Proteomic (Proteins) and Chromatin Status experiments.
Each of the aforementioned data types have a coloured and manually resizable text box in which is possible to copy and paste a tab separated dataset (see "Dataset Files"):

*	Genes datasets can be loaded in the light blue text box
*	miRNAs datasets can be loaded in the red text box
*	Metabolites datasets can be loaded in the yellow text box
*	Methylations datasets can be loaded in the green text box
*	Proteins datasets can be loaded in the purple text box
*	Chromatin Status datasets can be loaded in the purple text box

Only one text box is displayed at a time, to change this simply click on the dropdown menu "Data Type" and select one of the six data types.
When a dataset is displayed, its configuration becomes available for you to see and set up. 
This setup requires you the following:

*	Select the ID Type you are submitting from the "ID Type" selector, each data type has its own suppported IDs
*	Mark the column number of the dataset that stores the IDs using the "ID Column" text box
*	Mark the column number of the dataset that stores the differential expression values using the text box next to the aforementioned dropdown menu
*	Mark the column number of the dataset that stores p-values and write a threshold for them

.. note::
	Depending on the Analysis you will setup later for PathLay, not all of the above configurations must be performed, onle the ID Type and the ID Column are mandatory.



Once the configuration is done you can click the "Save" button and the Experiment Package will be created. 
The "Save" button will of course also save any modification you will submit to PathLay when you will reload this Experiment Package in the future.
