.. _usage_specs_conf:


Configuration File
==================

The configuration file for the Experiment Package is structured as a series of tag and value pairs, separated by a "=" character, with each line of the file holding one pair.

.. csv-table:: Configuration File Tags
   :file: ./tables/usage_exp_package_conf_table_1.csv
   :widths: 15, 50, 30
   :header-rows: 1

An example of a fully configured .conf file is displayed below:

.. code-block:: 
	:caption: Structure of a .conf file of an Experiment Package with Transcriptomic, Proteomic, miRNomic, Methylomic and Metabolomic datasets associated

	expname=LTED vs MCF7+
	comments=ANOVA adj.p + Tukey
	organism=hsa
	geneIdType=entrez
	gene_id_column=8
	gene_dev_column=6
	gene_pvalue_column=5
	protIdType=entry
	prot_id_column=1
	prot_dev_column=4
	prot_pvalue_column=3
	urnaIdType=mirbase
	urna_id_column=1
	urna_dev_column=6
	urna_pvalue_column=5
	methIdType=entrez
	meth_id_column=8
	meth_dev_column=6
	meth_pvalue_column=5
	metaIdType=keggcompound
	meta_id_column=8
	meta_dev_column=6
	meta_pvalue_column=5
	chromaIdType=entrez
	chroma_id_column=8
	chroma_dev_column=6
	chroma_pvalue_column=5

The experiment Package is named "LTED vs MCF7+" and it's related to an experiment involving Homo sapiens cells, it has all the -omics datasets currently supported by PathLay associated to it.
We can read its configuration as it follows:

*	The Transcriptomic datataset has its Entrez IDs stored in the 8th column, Effect Size values stored in the 6th column and p-values stored in the 5th column.

*	The miRNomic datataset has its mirbase IDs stored in the 1st column, Effect Size values stored in the 6th column and p-values stored in the 5th column.

*	The Metabolomic datataset has its Kegg Compound IDs stored in the 8th column, Effect Size values stored in the 6th column and p-values stored in the 5th column.

*	The Methylomic datataset has its Entrez IDs stored in the 8th column, Effect Size values stored in the 6th column and p-values stored in the 5th column.

*	The Chromatin Status dataset has its Entrez IDs stored in the 8th column, Effect Size values stored in the 6th column and p-values stored in the 5th column.

*	The Proteomic datataset has its Uniprot Entry IDs stored in the 1st column, Effect Size values stored in the 4th column and p-values stored in the 3rd column.

.. note::
	Experiment Packages can be created and configured in your Home Page with a more intuitive approach. Once the "Save" button is clicked the .conf file will be automatically generated and saved in your home folder.
