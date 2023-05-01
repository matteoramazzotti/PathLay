
=====
Usage
=====

.. _usage_account:

----------------
Account Managing
----------------

.. _usage_account_new:

^^^^^^^^^^^^^^^^^^^^^^
Register a New Account
^^^^^^^^^^^^^^^^^^^^^^

.. _usage_account_login:

^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Login to an Existing Account
^^^^^^^^^^^^^^^^^^^^^^^^^^^^


.. _usage_specs:

------------------
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

^^^^^^^^^^^^^^^^^^
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

^^^^^^^^^^^^^^
Datasets Files
^^^^^^^^^^^^^^

Each dataset file (i.e. .mrna, .prot, .mirna, .meta and .meth files) is a tab separated file that can have any number of columns but at least one, two or three, depending on the Analysis Mode you will choose for PathLay (see more in Configuration Page section). An "ID Only" analysis just requires an ID list in your dataset file, an "ID + DE" analysis requires an ID list with Expression Values associated and a "Full" analysis requires all the above plus a list of p-values associated to each ID.

.. note::
	Datasets can be copied and pasted in their related text areas in your Home Page. Once the "Save" button is clicked the dataset file will be created in your home folder and named after the experiment.


.. _usage_specs_ids:

^^^^^^^^^^^^^
Supported IDs
^^^^^^^^^^^^^

.. csv-table:: Compatible IDs to use in your Datasets
   :file: ./tables/table_exp_package_3.csv
   :widths: 50, 50
   :header-rows: 1


.. _usage_home:

------------
Home Manager
------------

Once an account is registered the Home Page becomes available, while for an already registered account it is accessible by clicking the "Manage Home" button in the login page. In the Home Page you can create, load and modify an Experiment Package with a more intuitive approach.

.. _usage_home_create:

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Creating an Experiment Package
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To create an Experiment Package from scratch the first thing to do is to click the "Add New" button and then assign it a name in the "Experiment Title" text box, you can also comment it in the "Comments" text box located below.
You can now proceed to load your datasets on PathLay. Data types supported may come from Transcriptomic (Genes), miRNomic (miRNAs), Metabolomic (Metabolites), Methylomic (Methylations) and Proteomic (Proteins) experiments. Each of the aforementioned data types have a coloured and manually resizable text box in which is possible to copy and paste a tab separated dataset (see "Dataset Files"):

*	Genes datasets can be loaded in the light blue text box
*	miRNAs datasets can be loaded in the red text box
*	Metabolites datasets can be loaded in the yellow text box
*	Methylations datasets can be loaded in the green text box
*	Proteins datasets can be loaded in the purple text box

Only one text box is displayed at a time, to change this simply click on the dropdown menu "Data Type" and select one of the five data types.
When a dataset is displayed, its configuration becomes available for you to see and set up. 
This setup requires you the following:

*	Mark the column number of the dataset that stores the IDs using the "ID Column" text box
*	Select the type of differential expression values stored in the dataset using the dropdown menu, "logFC", "FC" and "Raw" are your currently available options
*	Mark the column number of the dataset that stores the differential expression values using the text box next to the aforementioned dropdown menu
*	Select which differential expression values should be kept during the analysis selecting  ">", "<", "<>" or "><" from the dropdown menu and writing a threshold
*	Mark the column number of the dataset that stores p-values and write a threshold for them

.. note::
	Depending on the Analysis you will setup later for PathLay, not all of the above configurations must be performed:



Once the configuration is done you can click the "Save" button and the Experiment Package will be created. The "Save" button will of course also save any modification you will submit to PathLay when you will reload this Experiment Package in the future.

.. _usage_home_load:

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Loading an Experiment Package
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To load an existing Experiment Package from your home folder, select its name from the dropdown menu in the top left corner and hit the "Load" button. Datasets and configurations will be displayed in their relative fields.
If you have a zipped Experiment Package and you want to load it on PathLay, simply click the "Browse" button in the top right corner and select the zipped archive, then click the "Upload" button and load it.

.. _usage_home_ont:

^^^^^^^^^^^^^^^
Gene Ontologies
^^^^^^^^^^^^^^^

Your Home Page also provides a list of cellular compartments that are nothing less than Gene Ontologies. Each one of the entries represents a gene list of Entrez Gene IDs and you can select the ones you are more interested in by clicking the "+" button located on the right side of each box. Gene Ontologies of interest will be added to the other list alongside the preselected ones: Nucleus, Cytoplasm, Mitochondrion, Lysosome, Endoplasmic Reticulum, Golgi Apparatus, Cytoskeleton, Membrane. You can of course remove them by clicking the "-" button in the selected boxes.
Cellular compartments selected will be found in a dropdown menu after PathLay has completed the analysis and it's ready to show the results on functional pathways. Once a cellular compartment is chosen, only genes and proteins localized in that compartment will remain displayed on the pathways (see more "Pathway Explorer").

.. note::
	The selection of Gene Ontologies is as well part of your configuration for the Experiment Package, so any change you provide will be saved with the "Save" button.



.. _usage_home_download:

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Downloading an Experiment Package
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The "Download" button allows you to package the currently loaded datasets and configurations in a zip archive and export it from PathLay for other uses, for instance, this archive can be uploaded as a new Experiment Package into another PathLay account.
You can also download the entirety of your home folder (i.e. all the datasets and configurations of all the experiments) with the "Download Home" button.  

.. _usage_access:

------------------
Configuration Page
------------------

The Configuration Page is accessible from the Login Page by clicking "Access PathLay" once you input your credentials. From this page you will be able to run PathLay's analysis on an Experiment Package.
First thing to do is select an Experiment Package and load it using the dropdown menu and the "Load" button.

.. _usage_access_mapdb:

^^^^^^^^^^^^^^
Maps Databases
^^^^^^^^^^^^^^

The "Maps Database" section allows you to choose which database will be used to load pathways from, it currently provides two possibilities, both for Homo sapiens pathways: KEGG and WikiPathways.

.. _usage_access_stat:

^^^^^^^^^^^^^^^^^^^^^^^^^^
Maps Restriction Procedure
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. _usage_access_data:

^^^^^^^^^^^^^^
Data Selection
^^^^^^^^^^^^^^

The "Select Maps using" section allows to select the datasets you want to use by simply check the boxes you are interested in between "Genes", "Proteins", "miRNAs", "Methylations", "Chromatin Status" and "Metabolites".

.. warning::
	Whenever a checkbox is disabled, it means that either the dataset was not found available or that the setup in the Home page was not performed accordingly (i.e. the content of the columns was not pointed out correctly).


.. _usage_data_types:

^^^^^^^^^^^^^^^^^^^^^
Configuring a Dataset
^^^^^^^^^^^^^^^^^^^^^

Under the "Select Maps using" section is located a selector that allows to switch between the configurations available for each dataset.
Some of these configurations are common to every data type, while others, related to the Transcription Factors (TFs) and the Non Differentially Expressed components (NoDE), are peculiar to a few of them. 


.. _usage_data_filters:

^^^^^^^^^^^^^^^^^
Filtering Options
^^^^^^^^^^^^^^^^^

There are three filters available for each data type, which can be enabled by checking the respective box and requires a threshold value to be written in the input field next to it. These three filters are summarized below:
	* Effect Size < : filters out all the components with an Effect Size value greater than the threshold selected
	* Effect Size > : filters out all the components with an Effect Size value smaller than the threshold selected
	* p-value < : filters out all the components with a p-value value greater than the threshold

.. warning::
	Whenever a threshold field displays a red background, it means that the aforementioned threshold is not valid and contains a typing error. In this situation if the related filter checkbox remains enabled, the submit button will disappear until this error is either fixed by changing the threshold value or by disabling the filter.

.. _usage_data_id_only:

^^^^^^^^^^^^^^^
ID Preservation
^^^^^^^^^^^^^^^

ID Preservation can be enabled for every data type by checking the "Preserve non DE IDs" checkbox. This feature will not let PathLay to discard IDs found in the dataset without an Effect Size value. These "ID Only" components will be represented with a different palette of colors since they do not provide any information regarding their differential expression, but they will be still integrated with the other datasets.



.. _usage_access_nodeg:

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Non Differentially Expressed IDs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Whenever a miRNomic or a Methylomic dataset is in use, miRNas and methylations will be represented alongside the related genes. PathLays's approach is to integrate the information held within different datasets whenever is possible, hence when a Transcriptomic dataset is provided together with a miRNomic or/and a Methylomic one, the standard procedure adopted is to represent only miRNas and methylations related to the genes provided in the Transcriptomic dataset. It is possible to represent miRNas or methylations despite them being related to genes in a Transcriptomic dataset, by checking "miRNAs" or/and "Methylations" in the "Load NODEGs from:" section. This feature allows PathLay to display miRnas and methylations as grey indicators that represent a non-differentially expressed gene (i.e. a gene not provided in other datasets).


.. _usage_access_tfs:

^^^^^^^^^^^^^^^^^^^^^^^
Transcription Factors
^^^^^^^^^^^^^^^^^^^^^^^

PathLay also supports GTRD as a database and can display transcription factors (TFs) that interacts with genes coming from a Transcriptomic dataset and as well recognize if those gene IDs actually refers directly to a transcription factor. Transcription factors contained in GTRD database will be loaded and linked to the gene IDs in the Transcriptomic dataset, if a transcription factor is found in the Transcriptomic dataset it will also be linked to any related gene in the dataset. An option for TFs is present in the "Load NODEGs from:" section alongside miRNAs and methylations, when enabled it allows any transcription factor found in the transcriptomic dataset to be linked to any ID not included in the dataset with the same approach as miRNAs and methylations.


.. _usage_results:

----------------
Pathway Explorer
----------------

The "Analysis Results" page will be displayed after the configuration and the submitting of an analysis on an Experiment Package in your home. IDs coming from your datasets will be portrayed as different indicators on pathways depending on the Analysis Mode chosen (see more "Selecting an Analysis Mode"). This page allows you to:

	* Display your datasets on pathways
	* Filter pathways by selecting a specific gene/protein/miRNA/TF ID or by multiple IDs
	* Select a cellular compartment and display only the IDs localized in it
	* Select indicators and display their infos on the clipboard
	* Save indicators of interest and download them as a tab-separated text file
	* Filter pathways by selecting an "Agreement" between Gene/Proteins and Methylation, miRNAs or TFs

.. warning::
	The "Analysis Results" page is directly accessible after you hit the "Submit" button allowing you to navigate through pathways right away but depending on how much data PathLay needs to process, some indicators may not be displayed correctly from the go and require more time.

.. _usage_results_mapsel:

^^^^^^^^^^^^^^^^^^
Pathway Navigation
^^^^^^^^^^^^^^^^^^

Pathways available are listed in alphabetical order in the dropdown menu on the top left corner. The pathway name and ID are displayed and the numbers between round parenthesis give you information on how many indicators are loaded on the pathway. Selecting one pathway from this menu will instantly display it with its the indicators.

.. note::
	The pathway selector will display all the pathways available only when no other selections have been performed. Whenever an ID/Agreement/Cellular compartment based selection is performed, this dropdown menu will provide only those pathways that satisfies the parameters of the selection. To return at the initial, default state, simply reset your selections. 

.. _usage_results_legend:

^^^^^^^^^^
Indicators
^^^^^^^^^^

.. _usage_results_highlight:

^^^^^^^^^^^^^^^^^^^^
Highlighting Feature
^^^^^^^^^^^^^^^^^^^^

Two more dropdown menus are located next to the pathway selection dropdown menu and provides an indicator highligthing feature depending on your analysis configuration and the datasets loaded. The combination of these two selectors allows to choose a data type between Genes, Proteins, miRNAs, Metabolites, TFs and Ontologies and display the list of IDs of that data type. Selecting one ID will fill the pathway selector only with the pathway IDs that contains an indicator that represents the ID chosen. For instance, if you are interested in the pathways that displays an indicator for the COX1 gene (which was included in your transcriptomic dataset), simply select "Genes" and then select "COX1": the pathway selector will now list only those pathways. The behaviour is a little different when selecting a cellular compartment from the Ontologies section, since it will also hide those indicators that do not belong in the cellular compartment. To reset anyone of these selectors simply select the first option provided by them. 

.. _usage_results_clipboard:

^^^^^^^^^^^^^
The Clipboard
^^^^^^^^^^^^^

The Clipboard is a freely movable window that will be displayed as soon as the "Analysis Results" page is loaded. It is composed by two boxes, the "Info" box and the "Selected" box. The "Info" box will display the information related to a clicked indicator, this includes every ID that the indicator is portaying, with their differential expression values and other IDs eventually linked. Cliking on the IDs in the "Info" box will open up a page in the online database of reference for that data type:

	* NCBI for genes 
	* UniProtKB for proteins 
	* Mirtarbase for miRNAs
	* pippo for TFs.

Once you have clicked an indicator on a pathway and its information is displayed on the Clipboard, you can click the "Add" button below the "Info" box and save the indicator inside the Clipboard's "Selected" box. It will be listed as a smaller indicator under the name of the pathway from where the selction has been performed. Selecting this smaller indicator in the box will also display its information in the "Info" box and if the "Remove" button is clicked, the indicator will be removed from the "Selected" box. If instead, the "Select" button under the "Selected" box is clicked, the pathway selector will only list pathways that portray the indicator selected. The last feature provided by the Clipboard is the "Download" button which allows to download a tab separated text document listing all the information regarding selected indicators currently populating the "Selected" box.

.. note::
	Closing the Clipboard by clicking the "X" on the top right corner will not delete any selected indicator from the "Selected" box.

.. _usage_results_logical:

^^^^^^^^^^^^^^^^^^^
The Logical Section
^^^^^^^^^^^^^^^^^^^

This section in the "Analysis Results" page will be displayed when clicking the "Show Logicals" in the top right corner and allows to perform more sophisticate selections either by IDs or by "Agreement".

.. _usage_results_logical_byids:

"""""""""""""
Select by IDs
"""""""""""""

The first row in the Logical Section is composed by a selector that allows the selection of a data type between "Gene", "Protein", "miRNA" and "Metabolite", depending on your analysis configuration. Selecting one data type will pop up another selector with a list of IDs of the data type chosen. Once an ID is selected, it can be added to the selection pool "IDs Selected" positioned on the right of the Logical Section. Every ID added to the pool is represented as a colored box and can be removed from the pool by clicking the "X" button on the right. Colors are assigned considering the data type:

	* Light blue for genes
	* Purple for proteins
	* Red for miRNAs
	* Yellow for Metabolites
	
The "Select" button will perform a pathway selection using the pool content as criteria: only those pathways portraying all the IDs in the pool will be displayed in the pathway selector.
The "Reset" button will empty the selection pool and restore the selectors at their default state.

.. warning::
	It is possible that loaded pathways cannot satisfy the requirements for the selection made. In this case the pathway selector will become empty. Resetting the selection with the "Reset" button will restore the pathway selector at its default state.

.. _usage_results_logical_byagreement:

"""""""""""""""""""
Select by Agreement
"""""""""""""""""""

The second row in the Logical Section is composed by a series of selectors that allows the setup of the so called "Agreement" which is a feature that lets you select two related data types and select what type of correlation you are interested in. The main data type can be selected with the first selector which provides a choice between "Gene" and "Protein", and the second data type can be selected with the other selector which allows a choice between "Gene" or "Protein" (depending on your main data type of choice), "miRNA", "Methylation" or "TF". After the two data types are selected, the last step to do is to choose a "Positive Agreement" or a "Negative Agreement" with the last selector and hit the "Add" button. The configured agreement will be displayed in the "Agreements Selected" pool positioned under the "IDs Selected" pool. Once the select button is clicked, indicators that don't satisfy the requirements of the agreement will be hidden, thus if a pathway doesn't have visible indicators it will not be included in the pathway selector. Multiple agreements can be added to the pool to make the selection more stringent. How various agreements work is reported in the following table:  

.. csv-table:: Types of Agreement
   :file: ./tables/table_usage_results_1.csv
   :widths: 20, 40,40
   :header-rows: 1

As an example, let's suppose we want to examine only the indicators including a gene and a miRNA in a positive agreement: it is only necessary to select “Gene”, “miRNA” and “Positive” from the selectors provided in the Logical section. A positive agreement between a gene and a miRNA is based on a negative correlation, so the indicators highlighted will either have an up-regulated gene and a down-regulated miRNA or a down-regulated gene and an up-regulated miRNA. As a next step, we could also be looking at methylations: easily enough, agreement selections can be stacked so we could also select “Gene”, “Methylation”, “Positive” and highlight only those indicators that satisfy both the agreements.
As before, to remove it the "X" button on the right or the "Reset" button must be clicked.

.. _usage_results_settings:

^^^^^^^^
Settings
^^^^^^^^

The settings section in the "Analysis Results" page will be displayed when clicking the "Show Settings" button and allows to change some graphical parameters for the indicators like size and transparency values.

.. _usage_results_settings_transparencyandsize:

"""""""""""""""""""""
Transparency and Size
""""""""""""""""""""" 

Transparency and size of the indicators can be increased and decreased with the "Transparency Up","Size Up" and "Transparency Down","Size Down" buttons respectively.

.. _usage_results_settings_screenshot:

""""""""""
Screenshot
""""""""""

It is possible to take a shot of the currently displayed pathway by clicking the "Open as image (to save..)" button.

.. warning::
	Depending on your browser compatibility this feature can behave differently.


