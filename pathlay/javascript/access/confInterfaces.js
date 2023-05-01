class ExpConf {
    constructor(id,name,comment) {
        this.id = id;
        this.name = name;
        this.comment = comment;
        this.kegg = undefined;
        this.wikipathways = undefined;
        this.organism = undefined;
        this.geneIdType = undefined;
        this.protIdType = undefined;
        this.metaIdType = undefined;
        this.urnaIdType = undefined;
        this.methIdType = undefined;
        this.chromaIdType = undefined;
        this.gene_id_column = undefined;
        this.gene_dev_column = undefined;
        this.gene_pvalue_column = undefined;
        this.prot_id_column = undefined;
        this.prot_dev_column = undefined;
        this.prot_pvalue_column = undefined;
        this.meta_id_column = undefined;
        this.meta_dev_column = undefined;
        this.meta_pvalue_column = undefined;
        this.urna_id_column = undefined;
        this.urna_dev_column = undefined;
        this.urna_pvalue_column = undefined;
        this.meth_id_column = undefined;
        this.meth_dev_column = undefined;
        this.meth_pvalue_column = undefined;
        this.chroma_id_column = undefined;
        this.chroma_dev_column = undefined;
        this.chroma_pvalue_column = undefined;

    }
    load = function(expID) {
        this.reset();
        this.id = expID;
        this.name = exp_confs[expID].exp_name_input_text;
        this.comment = exp_confs[expID].exp_comment_input_text;
        for (let dataType of dataTypes) {
            if (exp_confs[expID][`${dataType}IdType`]) {
                this[`${dataType}IdType`] = exp_confs[expID][`${dataType}IdType`];
            }
            if (exp_confs[expID][`${dataType}_id_column`]) {
                this[`${dataType}_id_column`] = exp_confs[expID][`${dataType}_id_column`];
            }
            if (exp_confs[expID][`${dataType}_dev_column`]) {
                this[`${dataType}_dev_column`] = exp_confs[expID][`${dataType}_dev_column`];
            }
            if (exp_confs[expID][`${dataType}_pvalue_column`]) {
                this[`${dataType}_pvalue_column`] = exp_confs[expID][`${dataType}_pvalue_column`];
            }
        }
        if (exp_confs[expID].kegg == 1) {
            this.kegg = true;
        } else {
            this.kegg = false;
        }
        if (exp_confs[expID].wikipathways == 1) {
            this.wikipathways = true;
        } else {
            this.wikipathways = false;
        }
        
        this.organism = exp_confs[expID].organism;
    }
    reset = function() {
        for (let key in this) {
            if (this[key] instanceof Function) {
                continue;
            }
            this[key] = undefined;
        }
    }
}

class LastConf {
    constructor(id) {
        this.expLoadedId = id;
        this.expLoadedTitle = undefined;
        this.expLoadedComments = undefined;
        this.expLoadedOrganism = undefined;
        this.maps_db_select = undefined;
        this.statisticProcedure = undefined;
        
        this.gene = {
            enabled : undefined,
            //leftThreshold : undefined,
            //rightThreshold : undefined,
            pValThreshold : undefined,
            pValEnabled: undefined,
            //leftEnabled: undefined,
            //rightEnabled: undefined,
            IdOnlyCheck: undefined,
            //idOnly: undefined,
            tfEnabled: undefined,
            noDeFromTfEnabled: undefined
        }
        this.prot = {
            enabled : undefined,
            //leftThreshold : undefined,
            //rightThreshold : undefined,
            pValThreshold : undefined,
            pValEnabled: undefined,
            //leftEnabled: undefined,
            //rightEnabled: undefined,
            IdOnlyCheck: undefined,
            //idOnly: undefined,
            tfEnabled: undefined,
            noDeFromTfEnabled: undefined
        }
        this.meta = {
            enabled : undefined,
            //leftThreshold : undefined,
            //rightThreshold : undefined,
            pValThreshold : undefined,
            pValEnabled: undefined,
            //leftEnabled: undefined,
            //rightEnabled: undefined,
            IdOnlyCheck: undefined,
            //idOnly: undefined,
            noDeEnabled: undefined
            
        }
        this.urna = {
            enabled : undefined,
            LeftThreshold : undefined,
            RightThreshold : undefined,
            pValThreshold : undefined,
            pValEnabled: undefined,
            //leftEnabled: undefined,
            //rightEnabled: undefined,
            IdOnlyCheck: undefined,
            //noDeEnabled: undefined,
            noDeIdEnabled: undefined
        }
        this.meth = {
            enabled : undefined,
            //leftThreshold : undefined,
            //rightThreshold : undefined,
            pValThreshold : undefined,
            pValEnabled: undefined,
            //leftEnabled: undefined,
            //rightEnabled: undefined,
            IdOnlyCheck: undefined,
            //idOnly: undefined,
            noDeEnabled: undefined,
            noDeIdEnabled: undefined
        }
        this.chroma = {
            enabled : undefined,
            //leftThreshold : undefined,
            //rightThreshold : undefined,
            pValThreshold : undefined,
            pValEnabled: undefined,
            //leftEnabled: undefined,
            //rightEnabled: undefined,
            IdOnlyCheck: undefined,
            //idOnly: undefined,
            noDeEnabled: undefined,
            noDeIdEnabled: undefined
        }
    }
    load = function(expID) {
        this.reset();
        for (let dataType of dataTypes) {
            
            this.loadEnableCheck(expID,dataType);
            this.loadESChecks(expID,dataType);
            this.loadESThresholds(expID,dataType);
            this.loadpValCheck(expID,dataType);
            this.loadpValThreshold(expID,dataType);
            this.loadIdOnlyCheck(expID,dataType);
            this.loadNoDeChecks(expID,dataType);
            this.loadTFsChecks(expID,dataType);
        }
        this.maps_db_select = exp_last[expID].maps_db_select;
        //this.statisticProcedure = exp_last[expID].statisticProcedure;
        
    }
    loadEnableCheck = function(expID,dataType) {
        if (exp_last[expID][`enable${dataType}`] == 1) {
            this[dataType].enabled = true;
        } else {
            this[dataType].enabled = false;
        }
    }
    loadESChecks = function(expID,dataType) {
        if (exp_last[expID][`${dataType}RightEffectSizeCheck`] == 1) {
            this[dataType][`RightEnabled`] = true;
        } else {
            this[dataType][`RightEnabled`] = false;
        }
        if (exp_last[expID][`${dataType}LeftEffectSizeCheck`] == 1) {
            this[dataType][`LeftEnabled`] = true;
        } else {
            this[dataType][`LeftEnabled`] = false;
        }
    }
    loadESThresholds = function(expID,dataType) {
        if (exp_last[expID][`${dataType}LeftThreshold`]) {
            this[dataType][`LeftThreshold`] = exp_last[expID][`${dataType}LeftThreshold`];
        }
        if (exp_last[expID][`${dataType}RightThreshold`]) {
            this[dataType][`RightThreshold`] = exp_last[expID][`${dataType}RightThreshold`];
        }
    }
    loadpValCheck = function(expID,dataType) {
        if (exp_last[expID][`${dataType}pValCheck`] == 1) {
            this[dataType][`pValEnabled`] = true;
        } else {
            this[dataType][`pValEnabled`] = false;
        }
    }
    loadpValThreshold = function(expID,dataType) {
        if (exp_last[expID][`${dataType}pValThreshold`]) {
            this[dataType][`pValThreshold`] = exp_last[expID][`${dataType}pValThreshold`];
        }
    }
    loadIdOnlyCheck = function(expID,dataType) {
        if (exp_last[expID][`${dataType}IdOnlyCheck`] == 1) {
            this[dataType][`IdOnlyCheck`] = true;
        } else {
            this[dataType][`IdOnlyCheck`] = false;
        }
    }
    loadNoDeChecks = function(expID,dataType) {
        if (exp_last[expID][`nodeg_select_${dataType}`] == 1) {
            this[dataType][`nodeg_select`] = true;
        } else {
            this[dataType][`nodeg_select`] = false;
        }
        if (exp_last[expID][`${dataType}NoDEFromIdOnlyCheck`] == 1) {
            this[dataType][`NoDEFromIdOnlyCheck`] = true;
        } else {
            this[dataType][`${dataType}NoDEFromIdOnlyCheck`] = false;
        }
    }
    loadTFsChecks = function(expID,dataType) {
        if (exp_last[expID][`enabletfs_${dataType}`] == 1) {
            this[dataType][`tfEnabled`] = true;
        } else {
            this[dataType][`tfEnabled`] = false;
        }
        if (exp_last[expID][`nodeg_select_tf_${dataType}`] == 1) {
            this[dataType][`noDeFromTfEnabled`] = true;
        } else {
            this[dataType][`noDeFromTfEnabled`] = false;
        }
        if (exp_last[expID][`enabletfsIdOnly_${dataType}`] == 1) {
            this[dataType][`tfsIdOnlyCheck`] = true;
        } else {
            this[dataType][`tfsIdOnlyCheck`] = false;
        }
        if (exp_last[expID][`tfsNoDEFromIdOnlyCheck_${dataType}`] == 1) {
            this[dataType][`tfsNoDEFromIdOnlyCheck`] = true;
        } else {
            this[dataType][`tfsNoDEFromIdOnlyCheck`] = false;
        }
    }
    reset = function() {
        for (let key1 in this) {
            if (this[key1] instanceof Function) {
                continue;
            }
            if (key1 === "gene" || key1 === "prot" || key1 === "meta" || key1 === "chroma" || key1 === "meth" || key1 === "urna") {
                for (let key2 in this[key1]) {
                    this[key1][key2] = undefined
                }
            } else {
                this[key1] = undefined;
            } 
        }
    }
}

class CurrentConf {
    constructor() {
        this.expLoadedId = undefined;
        this.expLoadedTitle = undefined;
        this.expLoadedComments = undefined;
        this.expLoadedOrganism = undefined;
        this.maps_db_select = undefined;
        this.statisticProcedure = undefined;
        
        this.gene = {
            available :undefined,
            enabled : undefined,
            leftThreshold : undefined,
            rightThreshold : undefined,
            pValThreshold : undefined,
            pValEnabled: undefined,
            leftEnabled: undefined,
            rightEnabled: undefined,
            idOnly: undefined,
            tfEnabled: undefined,
            noDeFromTfEnabled: undefined
        }
        this.prot = {
            available :undefined,
            enabled : undefined,
            leftThreshold : undefined,
            rightThreshold : undefined,
            pValThreshold : undefined,
            pValEnabled: undefined,
            leftEnabled: undefined,
            rightEnabled: undefined,
            idOnly: undefined,
            tfEnabled: undefined,
            noDeFromTfEnabled: undefined
        }
        this.meta = {
            available :undefined,
            enabled : undefined,
            leftThreshold : undefined,
            rightThreshold : undefined,
            pValThreshold : undefined,
            pValEnabled: undefined,
            leftEnabled: undefined,
            rightEnabled: undefined,
            idOnly: undefined,
            noDeEnabled: undefined
            
        }
        this.urna = {
            available :undefined,
            enabled : undefined,
            leftThreshold : undefined,
            rightThreshold : undefined,
            pValThreshold : undefined,
            pValEnabled: undefined,
            leftEnabled: undefined,
            rightEnabled: undefined,
            idOnly: undefined,
            noDeEnabled: undefined,
            noDeIdEnabled: undefined
        }
        this.meth = {
            available :undefined,
            enabled : undefined,
            leftThreshold : undefined,
            rightThreshold : undefined,
            pValThreshold : undefined,
            pValEnabled: undefined,
            leftEnabled: undefined,
            rightEnabled: undefined,
            idOnly: undefined,
            noDeEnabled: undefined,
            noDeIdEnabled: undefined
        }
        this.chroma = {
            available :undefined,
            enabled : undefined,
            leftThreshold : undefined,
            rightThreshold : undefined,
            pValThreshold : undefined,
            pValEnabled: undefined,
            leftEnabled: undefined,
            rightEnabled: undefined,
            idOnly: undefined,
            noDeEnabled: undefined,
            noDeIdEnabled: undefined
        }
    }
    updateAll = function() {
        this.updateMapsDB();
        for (let dataType of dataTypes) {
            this.updateEnabler(dataType);
            this.updateLeftCheck(dataType);
            this.updateRightCheck(dataType);
            this.updatepValCheck(dataType);
            this.updateIdOnlyCheck(dataType);
            this.updateTfCheck(dataType);
            this.updateTfIdOnlyCheck(dataType);
            this.updateLeftThresholdValue(dataType);
            this.updateRightThresholdValue(dataType);
            this.updatepValThresholdValue(dataType);
            this.updateNoDeCheck(dataType);
            this.updateNoDeFromIdOnlyCheck(dataType);
        }
    }
    updateEnabler = function(dataType) {
        if (document.getElementById(`enable${dataType}`).checked === true) {
            this[dataType].enabled = true;
        } else {
            this[dataType].enabled = false;
        }
    }
    updateLeftCheck = function(dataType) {
        if (document.getElementById(`${dataType}LeftEffectSizeCheck`).checked === true) {
            this[dataType].leftEnabled = true;
        } else {
            this[dataType].leftEnabled = false;
        }
    }
    updateRightCheck = function(dataType) {
        if (document.getElementById(`${dataType}RightEffectSizeCheck`).checked === true) {
            this[dataType].rightEnabled = true;
        } else {
            this[dataType].rightEnabled = false;
        }
    }
    updatepValCheck = function (dataType) {
        if (document.getElementById(`${dataType}pValCheck`).checked === true) {
            this[dataType].pValEnabled = true;
        } else {
            this[dataType].pValEnabled = false;
        }
    }
    updateIdOnlyCheck = function (dataType) {
        if (document.getElementById(`${dataType}IdOnlyCheck`).checked === true) {
            this[dataType].idOnly = true;
        } else {
            this[dataType].idOnly = false;
        }
    }
    updateTfCheck = function (dataType) {
        if (document.getElementById(`enabletfs_${dataType}`)) {
            if (document.getElementById(`enabletfs_${dataType}`).checked === true) {
                this[dataType].tfEnabled = true;
            } else {
                this[dataType].tfEnabled = false;
            }
        }
    }
    updateTfIdOnlyCheck = function (dataType) {
        if (document.getElementById(`nodeg_select_tf_${dataType}`)) {
            if (document.getElementById(`nodeg_select_tf_${dataType}`).checked === true) {
                this[dataType].noDeFromTfEnabled = true;
            } else {
                this[dataType].noDeFromTfEnabled = false;
            }
        }
        
    }
    updateLeftThresholdValue = function (dataType) {
        this[dataType].leftThreshold = document.getElementById(`${dataType}LeftThreshold`).value;
        checksOnCurrent.checkEffectSize(dataType,"left");
    }
    updateRightThresholdValue = function (dataType) {
        this[dataType].rightThreshold = document.getElementById(`${dataType}RightThreshold`).value;
        checksOnCurrent.checkEffectSize(dataType,"right");
    }
    updatepValThresholdValue = function (dataType) {
        this[dataType].pValThreshold = document.getElementById(`${dataType}pValThreshold`).value;
        checksOnCurrent.checkpVal(dataType);
    }
    updateNoDeCheck = function (dataType) {
        if (document.getElementById(`nodeg_select_${dataType}`)){
            if (document.getElementById(`nodeg_select_${dataType}`).checked === true) {
                this[dataType].noDeEnabled = true;
            } else {
                this[dataType].noDeEnabled = false;
            }
        }
    }
    updateNoDeFromIdOnlyCheck = function (dataType) {
        if (document.getElementById(`${dataType}NoDEFromIdOnlyCheck`)) {
            if (document.getElementById(`${dataType}NoDEFromIdOnlyCheck`).checked === true) {
                this[dataType].noDeIdEnabled = true;
            } else {
                this[dataType].noDeIdEnabled = false;
            }
        }
    }
    updateMapsDB = function () {
        this.maps_db_select = document.getElementById('maps_db_select').value;
    }
    
}

class Preview {
    constructor() {
        this.initCounters();
    }
    initCounters = function() {
        for (let dataType of dataTypes) {
            this[dataType] = {};
            this[dataType].counters = {};
            this[dataType].counters.input = 0;
            this[dataType].counters.esFiltered = 0;
            this[dataType].counters.pValFiltered = 0;
            this[dataType].counters.output = 0;
        }
    }
    makePrediction = function() {
        this.initCounters();
        let seenIds = {};
        console.log('make prediction');
        for (let dataType of dataTypes) {
            let checkLeft = false;
            let checkRight = false;
            let checkpVal = false;
            let idCol;
            let pValCol;
            let devCol;
            let leftThr;
            let rightThr;
            let pValThr;
            if (dataSets[dataType]) {
                //let dataSetLines = dataSets[dataType].data.split("\n");
                let dataSetLines = dataSets[dataType].split("\n");
                if (
                    currentConf[dataType].enabled == true &&
                    checksOnConf[dataType].idAvailable == true 
                ) {
                    idCol = expConf[`${dataType}_id_column`]-1;

                    if (
                        currentConf[dataType].leftEnabled == true && 
                        checksOnCurrent[dataType].leftThreshold == true &&
                        checksOnConf[dataType].devAvailable == true
                    ) {
                        checkLeft = true;
                        devCol = expConf[`${dataType}_dev_column`] - 1;
                        leftThr = currentConf[dataType].leftThreshold;
                    }
                    if (
                        currentConf[dataType].rightEnabled == true && 
                        checksOnCurrent[dataType].rightThreshold == true &&
                        checksOnConf[dataType].devAvailable == true
                    ) {
                        checkRight = true;
                        devCol = expConf[`${dataType}_dev_column`] - 1;
                        rightThr = currentConf[dataType].rightThreshold;
                    }
                    if (
                        currentConf[dataType].pValEnabled == true && 
                        checksOnCurrent[dataType].pValThreshold == true &&
                        checksOnConf[dataType].pValAvailable == true
                    ) {
                        checkpVal = true;
                        pValCol = expConf[`${dataType}_pvalue_column`] - 1;
                        pValThr = currentConf[dataType].pValThreshold;
                    }
                }

                seenIds[`${dataType}`] = {};

                for (let dataSetLine of dataSetLines) {
                    let currentData = dataSetLine.split("\t");
                    let currentId = currentData[idCol];

                    if (!seenIds[dataType][currentId]) {
                        seenIds[dataType][currentId] = {};
                        currentPreview[dataType].counters.input++;
                    }
                    
                    if (checkpVal === true) {
                        console.log(`${dataType}: Checking pVal`);
                        if (currentData[pValCol] > pValThr) {
                            currentPreview[dataType].counters.pValFiltered++;
                            continue;
                        }
                    }
                    if (checkLeft === true || checkRight === true) {
                        
                        if (checkLeft === true && checkRight === true) {
                            console.log(`${dataType}: Checking Left & Right`);
                            if (currentData[devCol] > leftThr && currentData[devCol] < rightThr) {
                                currentPreview[dataType].counters.esFiltered++;
                                continue;
                            }
                        }
                        if (checkLeft === false && checkRight === true) {
                            console.log(`${dataType}: Checking Right`);
                            if (currentData[devCol] < rightThr) {
                                currentPreview[dataType].counters.esFiltered++;
                                continue;
                            }
                        }
                        if (checkLeft === true && checkRight === false) {
                            console.log(`${dataType}: Checking Left`);
                            if (currentData[devCol] > leftThr) {
                                currentPreview[dataType].counters.esFiltered++;
                                continue;
                            }
                        }
                    }
                }

            }
            currentPreview[dataType].counters.output = currentPreview[dataType].counters.input - (currentPreview[dataType].counters.esFiltered + currentPreview[dataType].counters.pValFiltered);
        }
        
    }
    printPrediction = function() {
        let div_preview = document.getElementById("div_preview");
        this.reset();
        for (let dataType of dataTypes) {
            if (currentConf[dataType].enabled == true) {
                let textHeader = `<b>${prettyTypes[dataType]}</b>:`;
                let textInput = `<b>Input</b>: ${this[dataType].counters.input}`;
                let textpVal = `<b>Filetered out by p-value</b>: ${this[dataType].counters.pValFiltered}`;
                let textES = `<b>Filetered out by Effect Size</b>: ${this[dataType].counters.esFiltered}`;
                let textOutput = `<b>Output</b>: ${this[dataType].counters.output}`;
                let fontHeader = spawnFont(`${dataType}HeaderPreview`,"previewFont",textHeader);
                let fontInput = spawnFont(`${dataType}InputPreview`,"previewFont",textInput);
                let fontpVal = spawnFont(`${dataType}pValPreview`,"previewFont",textpVal);
                let fontES = spawnFont(`${dataType}ESPreview`,"previewFont",textES);
                let fontOutput = spawnFont(`${dataType}OutputPreview`,"previewFont",textOutput);
                div_preview.appendChild(document.createElement('br'));
                div_preview.appendChild(fontHeader);
                div_preview.appendChild(document.createElement('br'));
                div_preview.appendChild(fontInput);
                div_preview.appendChild(document.createElement('br'));
                div_preview.appendChild(fontES);
                div_preview.appendChild(document.createElement('br'));
                div_preview.appendChild(fontpVal);
                div_preview.appendChild(document.createElement('br'));
                div_preview.appendChild(fontOutput);
                div_preview.appendChild(document.createElement('br'));
            }
        }

        
    }
    reset = function() {
        let div_preview = document.getElementById("div_preview");
        let fonts = document.querySelectorAll('.previewFont');
        for (let font of fonts) {
            div_preview.removeChild(font);
        }
        div_preview.innerHTML = "<b>Preview</b>";
    }
}


