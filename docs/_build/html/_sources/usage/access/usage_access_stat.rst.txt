.. _usage_access_stat:

^^^^^^^^^^^^^^^^^^^^^^^^^^
Maps Restriction Procedure
^^^^^^^^^^^^^^^^^^^^^^^^^^

It is possible to perform a selection of maps to display in the PathLay - MAPS page by selecting FET from the Map Restriction Procedure selector.
Maps are selected with a statistical approach based on the Fisher's Exact Test and since PathLay integrates different datasets, it is also possible to select which dataset will contribute on the map selection.
To allow this, the "FET Enabled" option should be checked for each dataset that should contribute.
By default the test is performed on each dataset enabled and it will produce a list of maps considered of importance, all the lists produced are then joined into one.
There are two tweaks available that can change the result of this step: the Intersect option and the Pooling option.

Pooling
-------

Eabling the Pooling option will affect how the Transcriptomic, Proteomic, miRNomic, Methylomic and Cromatin Status datasets are treated when enabled for the test.
When enabled, the IDs of the above datasets will be merged and the test is performed on that single list.

Intersect
---------

Enabling the Intersect option will affect which maps will be selected after the test has been performed. 
By default map lists are joined into one, meaning that even if a map has been found relevant in relation to just one of the datasets, it will be kept and indicators will be plotted on it.
With the Intersect feature enabled, only maps that are considered relevant for all the datasets enabled are kept (i.e. the ones that appear in every map list coming from the tests performed).


