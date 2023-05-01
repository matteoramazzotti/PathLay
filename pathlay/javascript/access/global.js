var dataTypes = [
    "gene",
    "prot",
    "meta",
    "meth",
    "chroma",
    "urna"
];


var prettyTypes = {
    "gene":"Genes",
    "meta":"Metabolites",
    "urna":"miRNAs",
    "meth":"Methylations",
    "chroma":"Chromatin",
    "prot":"Proteins"
}


var validIdTypes = {
    "gene": {
        "entrez":{},
        "ensembl":{},
        "symbol":{}
    },
    "prot": {
        "entrez":{},
        "entry":{},
        "symbol":{}
    },
    "meta": {
        "keggcompound":{},
        "name":{}
    },
    "meth": {
        "entrez":{},
        "ensembl":{},
        "symbol":{} 
    },
    "chroma": {
        "entrez":{},
        "ensembl":{},
        "symbol":{}
    },
    "urna": {
        "mirbase":{}
    }
}

var mrna_text;
var mrna_url;
var prot_text;
var prot_url;
var urna_text;
var urna_url;
var meth_text;
var meth_url;
var meta_text;
var meta_url;
var onto_text;
var onto_url;
var chroma_text;
var chroma_url;
var dataSets;

var host = location.host;

var expConf = new ExpConf();
var lastConf = new LastConf();
var currentConf = new CurrentConf();
var checksOnConf = new ChecksOnConf();
var checksOnCurrent = new ChecksOnCurrent();
var currentPreview = new Preview();