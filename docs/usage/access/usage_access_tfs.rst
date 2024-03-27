.. _usage_access_tfs:

^^^^^^^^^^^^^^^^^^^^^
Transcription Factors
^^^^^^^^^^^^^^^^^^^^^

PathLay also supports GTRD as a database and can display transcription factors (TFs) that interacts with genes coming from a Transcriptomic or Proteomic dataset and as well recognize if those gene/protein IDs actually refers directly to a transcription factor.
Transcription factors will be loaded and linked to the gene IDs in the Transcriptomic dataset if the "Enable TFs" feature is enabled. The same goes for the proteomic dataset which has its own "Enable TFs" feature.
If a transcription factor is found in the Transcriptomic dataset it will be linked to any related gene also present in the dataset.
Whenever Transcriptomic and Proteomic datasets are enabled together and the "Enable TFs" feature is enabled for at least one of them, once a TF is recognized, its targets will be looked for both in the Transcriptomic and Proteomic dataset to guarantee an high level degree of integration. 
