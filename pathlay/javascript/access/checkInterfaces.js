class ChecksOnConf {
    constructor() {
        this.gene = {
            idAvailable : undefined,
            devAvailable : undefined,
            pValAvailable : undefined,
            dataAvailable : undefined,
            idTypeAvailable : undefined
        }
        this.prot = {
            idAvailable : undefined,
            devAvailable : undefined,
            pValAvailable : undefined,
            dataAvailable : undefined,
            idTypeAvailable : undefined
        }
        this.meta = {
            idAvailable : undefined,
            devAvailable : undefined,
            pValAvailable : undefined,
            dataAvailable : undefined,
            idTypeAvailable : undefined
        }
        this.chroma = {
            idAvailable : undefined,
            devAvailable : undefined,
            pValAvailable : undefined,
            dataAvailable : undefined,
            idTypeAvailable : undefined
        }
        this.meth = {
            idAvailable : undefined,
            devAvailable : undefined,
            pValAvailable : undefined,
            dataAvailable : undefined,
            idTypeAvailable : undefined
        }
        this.urna = {
            idAvailable : undefined,
            devAvailable : undefined,
            pValAvailable : undefined,
            dataAvailable : undefined,
            idTypeAvailable : undefined
        }
        this.wikipathways = undefined;
        this.kegg = undefined;
    }
    checkAll = function() {
        this.checkIdColumns();
        this.checkDevColumns();
        this.checkpValColumns();
        this.checkIdTypes();
        this.checkDataSets();    
    }

    checkIdColumns = function() {
        for (let dataType of dataTypes) {
            if (
                expConf[`${dataType}_id_column`] !== "undefined" && 
                expConf[`${dataType}_id_column`] !== undefined && 
                expConf[`${dataType}_id_column`] != ""
            ) {
                this[dataType].idAvailable = true;
            } else {
                this[dataType].idAvailable = false;
            }
        }
    }
    checkDevColumns = function() {
        for (let dataType of dataTypes) {
            if (
                expConf[`${dataType}_dev_column`] != "undefined" && 
                expConf[`${dataType}_dev_column`] !== undefined && 
                expConf[`${dataType}_dev_column`] != ""
            ) {
                this[dataType].devAvailable = true;
            } else {
                this[dataType].devAvailable = false;
            }
        }
    }
    checkpValColumns = function() {
        for (let dataType of dataTypes) {
            if (
                expConf[`${dataType}_pvalue_column`] != "undefined" && 
                expConf[`${dataType}_pvalue_column`] !== undefined && 
                expConf[`${dataType}_pvalue_column`] != ""
            ) {
                this[dataType].pValAvailable = true;
            } else {
                this[dataType].pValAvailable = false;
            }

        }
    }
    checkIdTypes = function() {
        for (let dataType of dataTypes) {
            if (validIdTypes[dataType][expConf[`${dataType}IdType`]]) {
                this[dataType].idTypeAvailable = true;
            } else {
                this[dataType].idTypeAvailable = false;
            }
        }
    }
    checkDataSets = function() {
        for (let dataType of dataTypes) {
            if (dataSets[dataType] && dataSets[dataType] !== "") {
                this[dataType].dataAvailable = true;
            } else {
                this[dataType].dataAvailable = false;
            }
        }
    }
    checkMapDBs = function () {
        if (expConf.kegg === true) {
            this.kegg = true;
        } else {
            this.kegg = false;
        }
        if (expConf.wikipathways === true) {
            this.wikipathways = true;
        } else {
            this.wikipathways = false;
        }
        if (this.wikipathways === false && this.kegg === false) {
            checksOnCurrent.mapDBSelected = false;
        }
    }
}

class ChecksOnCurrent{
    constructor () {
        this.gene = {
            leftThreshold : undefined,
            rightThreshold : undefined,
            pValThreshold : undefined
        }
        this.prot = {
            leftThreshold : undefined,
            rightThreshold : undefined,
            validpValThreshold : undefined
        }
        this.meta = {
            leftThreshold : undefined,
            rightThreshold : undefined,
            pValThreshold : undefined
        }
        this.chroma = {
            leftThreshold : undefined,
            rightThreshold : undefined,
            pValThreshold : undefined
        }
        this.meth = {
            leftThreshold : undefined,
            rightThreshold : undefined,
            pValThreshold : undefined
        }
        this.urna = {
            leftThreshold : undefined,
            rightThreshold : undefined,
            pValThreshold : undefined
        }
        this.mapDBSelected = undefined;
        this.submitEnabled = undefined;
    }
    checkMapDBs = function() {
        if (currentConf.maps_db_select == "kegg" || currentConf.maps_db_select == "wikipathways") {
            this.mapDBSelected = true;
        } else {
            this.mapDBSelected = false;
        }
        if (this.mapDBSelected === false || this.mapDBSelected === undefined) {
            this.submitEnabled = false;
            console.log("Disabling submit for db")
        }
    }
    checkEffectSize = function(type,direction) {
        let numRGX = /^\d+$|^\d+?\.\d+$|^[\-|\+]\d+$|^[\-|\+]\d+?\.\d+$/;
        if (numRGX.test(currentConf[type][`${direction}Threshold`])) {    
            this[type][`${direction}Threshold`] = true;
        } else {
            this[type][`${direction}Threshold`] = false;
        }
    }
    checkpVal = function(type) {
        let numRGX = /^\d+$|^\d+?\.\d+$|^[\-|\+]\d+$|^[\-|\+]\d+?\.\d+$/;
        if (numRGX.test(currentConf[type][`pValThreshold`])) {    
            this[type][`pValThreshold`] = true;
        } else {
            this[type][`pValThreshold`] = false;
        }
    }

    checkEnablersForSubmit = function() {
        if (
            document.getElementById('enablegene').disabled == true &&
            document.getElementById('enableprot').disabled == true &&
            document.getElementById('enablemeta').disabled == true &&
            document.getElementById('enableurna').disabled == true &&
            document.getElementById('enablemeth').disabled == true &&
            document.getElementById('enablechroma').disabled == true
        ) {
            console.log('All Disabled');
            document.getElementById('div_exec_buttons').style.display = "none";
            this.submitEnabled = false;
        } else {
            document.getElementById('div_exec_buttons').style.display = "block";
        }
        if (
            document.getElementById('enablegene').checked == false &&
            document.getElementById('enableprot').checked == false &&
            document.getElementById('enablemeta').checked == false &&
            document.getElementById('enableurna').checked == false &&
            document.getElementById('enablemeth').checked == false &&
            document.getElementById('enablechroma').checked == false
        ) {
            console.log('All Unchecked');
            document.getElementById('div_exec_buttons').style.display = "none";
            this.submitEnabled = false;
        } else {
            document.getElementById('div_exec_buttons').style.display = "block";
        }
    }
    checkThresholdsForSubmit = function() {
        console.log("checking thresholds");
        for (let dataType of dataTypes) {
            if (currentConf[dataType].enabled === true) {
                if (currentConf[dataType].leftEnabled === true && this[dataType].leftThreshold === false) {
                    console.log("Invalid Left");
                    document.getElementById(`${dataType}LeftThreshold`).style.background = "red";
                    this.submitEnabled = false;
                } else {
                    document.getElementById(`${dataType}LeftThreshold`).style.background = "";
                }
                if (currentConf[dataType].rightEnabled === true && this[dataType].rightThreshold === false) {
                    console.log("Invalid Right");
                    document.getElementById(`${dataType}RightThreshold`).style.background = "red";
                    this.submitEnabled = false;
                } else {
                    document.getElementById(`${dataType}RightThreshold`).style.background = "";
                }
                if (currentConf[dataType].pValEnabled === true && this[dataType].pValThreshold === false) {
                    console.log("Invalid pVal");
                    document.getElementById(`${dataType}pValThreshold`).style.background = "red";
                    this.submitEnabled = false;
                } else {
                    document.getElementById(`${dataType}pValThreshold`).style.background = "";
                }
            }
        }
        console.log(`Submit Enabled: ${this.submitEnabled}`);
    }
    checkSubmit = function() {
        this.submitEnabled = true;
        console.log("Checking");
        this.checkMapDBs();
        this.checkThresholdsForSubmit();
        this.checkNoDeConstraints();
        this.checkNoDeFromIdOnlyConstraints();
        this.checkEnablersForSubmit();
        if (this.submitEnabled === true) {
            this.enableSubmit();
        } else {
            console.log("Disabling Submit Button");
            this.disableSubmit();
        }
    }
    checkNoDeConstraints = function() {
        let types = [
            "urna",
            "meth",
            "chroma"
        ];

        if (
            currentConf.gene.enabled === false && 
            currentConf.prot.enabled === false
        ) {
            for (let type of types) {
                if (currentConf[type].enabled == true ) {
                    if (currentConf[type].noDeEnabled === false) {
                        console.log("Clicking in constraints");
                        document.getElementById(`nodeg_select_${type}`).click();
                        currentConf.updateNoDeCheck(type);
                    }
                }
            }
        }
    }
    checkNoDeFromIdOnlyConstraints = function() {
        let types = [
            "urna",
            "meth",
            "chroma"
        ];

        for (let type of types) {
            if (currentConf[type].enabled == true ) {
                if (currentConf[type].noDeIdEnabled === true && currentConf[type].idOnly === false) {
                    console.log("Clicking in constraints");
                    document.getElementById(`${type}IdOnlyCheck`).click();
                    currentConf.updateNoDeFromIdOnlyCheck(type);
                }
            }
        }
    }
    disableSubmit = function() {
        document.getElementById("div_exec_buttons").style.display = "none";
    }
    enableSubmit = function() {
        document.getElementById("div_exec_buttons").style.display = "block";
    }
}

class WarningsOnConf {
    constructor (){
        this.gene = [],
        this.prot = [],
        this.meta = [],
        this.urna = [],
        this.meth = [],
        this.chroma = []
    }
    
}