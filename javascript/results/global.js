var active_complex_id = "";
var active_complex_title = "";
var active_complex_src = "";
var active_complex_obj;


var typeRegex = new RegExp(/type:(.+?)$/);
var idRegex = new RegExp(/id:(.+?)$/);
var nameRegex = new RegExp(/name:(.+?)$/);
var mirtRegex = new RegExp(/mirt:(.+?)$/);
var devRegex = new RegExp(/dev:(.+?)$/);
var methRegex = new RegExp(/meth:(.+?)$/);
var protRegex = new RegExp(/prot:(.+?)$/);
var subpoolRegex = new RegExp(/(.+?)_subpool$/);


var pathwayObjs = {};
var complexObjs = {};
// var meth2comp = {};
// var meth2name = {};
// var tf2comp = {};
// var tf2name = {};
// var chroma2comp = {};
// var chroma2name = {};
// var gene2comp = {};
// var gene2name = {};
// var prot2comp = {};
// var prot2name = {};
// var urna2comp = {};
// var urna2name = {};
// var meta2comp = {};
// var meta2name = {};
var entrez2symbol = {};
var entrez2protID = {};

var containerForDrag;
var dragTarget;
var imgToDrag;
var isDragging = false;
var startX, startY, offsetX = 0, offsetY = 0;

var referenceTable = {
    gene : {
        aliasForIDSelector : "Gene",
        aliasForTypeSelector : "Genes",
        ids : {} 
    },
    prot : {
        aliasForIDSelector : "Protein",
        aliasForTypeSelector : "Proteins",
        ids : {} 
    },
    meta : {
        aliasForIDSelector : "Metabolite",
        aliasForTypeSelector : "Metabolites",
        ids : {}
    },
    urna : {
        aliasForIDSelector : "miRNA",
        aliasForTypeSelector : "miRNAs",
        ids : {}
    },
    chroma : {
        aliasForIDSelector : "Chromatin",
        aliasForTypeSelector : "Chromatin",
        ids : {}
    },
    meth : {
        aliasForIDSelector : "Methylation",
        aliasForTypeSelector : "Methylations",
        ids : {}
    },
    tf : {
        aliasForIDSelector : "TF",
        aliasForTypeSelector : "TFs",
        ids : {}
    },
    nodeg : {
        ids: {}
    }
}

referenceTable.deg = referenceTable.gene;
// referenceTable.meth.ids = referenceTable.gene.ids;
// referenceTable.chroma.ids = referenceTable.gene.ids;
// referenceTable.nodeg = referenceTable.gene;
// referenceTable.chroma.ids = {};
// referenceTable.meth.ids = {};

var changeEvent = new Event('change');

//var active_logical_selected_element = {id:undefined,name:undefined,type:undefined};
//var logical_pool_content = {content:0};

var dataTypesTot = [
    'gene',
    'prot',
    'urna',
    'tf',
    'meta',
    'meth',
    'chroma'
];


var geneRightThreshold = 0;
var geneLeftThreshold = 0;
var protRightThreshold = 0;
var protLeftThreshold = 0;
var urnaRightThreshold = 0;
var urnaLeftThreshold = 0;
var metaRightThreshold = 0;
var metaLeftThreshold = 0;
var methRightThreshold = 0;
var methLeftThreshold = 0;
var chromaRightThreshold = 0;
var chromaLeftThreshold = 0;



var active_selector_number;