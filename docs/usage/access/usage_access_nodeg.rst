.. _usage_access_nodeg:

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Non Differentially Expressed IDs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Whenever a miRNa, Methylation or Chromatin status dataset is enabled, miRNas, methylations and chromatin statuses will be represented alongside the related genes.
PathLays's approach is to integrate the information held within different datasets whenever is possible, hence when a Transcriptomic or Proteomic dataset is provided and enabled alongside the afromentioned ones, the standard procedure adopted is to represent an integration of these informations using genes and proteins provided as a scaffold on which miRNAs, methylations and chromatin statuses impact.
Anyway It is possible to represent miRNas, methylations or chromatin statuses despite the absence of their related genes in the Transcriptomic dataset, by checking the "No DE Loading" feature in their respective configurations.
This feature allows PathLay to display miRnas, methylations and chromatin statuses on grey indicators that represent a non-differentially expressed gene (i.e. a gene not provided in other datasets).
This feature specifically works with the IDs of miRNAs, methylations and chromatin statuses linked to an Effect Size value, while the IDs without an Effect Size value will be only linked and represented alongside those genes or proteins that are effectively provided by their respectiv datasets, unless the "No DE Loading From Preserved IDs" feature is enabled.
By doing this, ID only components coming from these thre datasets will also be able to call out Non DE genes and proteins.
Graphically speaking this is translated into grey indicators surrounded by smaller circles and squares coloured in orange.
