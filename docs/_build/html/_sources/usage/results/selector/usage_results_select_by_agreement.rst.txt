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
