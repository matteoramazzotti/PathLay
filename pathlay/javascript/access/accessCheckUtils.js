function spawnReportDiv() {
    let accessReportDiv = spawnDiv("accessReportDiv","reportDiv");
    let accessReportWarningDiv = spawnDiv("accessReportWarningDiv","reportDivSection");
    let accessReportCloseButton = spawnInput ("accessReportCloseButton","accessReportCloseButton","button","X","closeReportDiv()");
    let accessReportContinueButton = spawnInput ("accessReportContinueButton","accessReportContinueButton","submit","Continue","");
    let accessReportPreviewDiv = spawnDiv("accessReportPreviewDiv","reportDivSection");

    document.getElementById('configContainer').appendChild(accessReportDiv);
    accessReportDiv.appendChild(accessReportCloseButton);
    accessReportDiv.appendChild(accessReportWarningDiv);
    accessReportDiv.appendChild(accessReportPreviewDiv);

    if (currentConf.checks.submitEnabled === false) {
        for (let dataType in currentConf.warnings) {
            if (currentConf.warnings[dataType].length > 0) {
                let warningSectionTitle = spawnFont(`warningTitle${dataType}`,`warningFont`,`Warnings for: ${dataType}`);
                warningSectionTitle.setAttribute("color","white");
                let br = document.createElement('br');
                accessReportWarningDiv.appendChild(warningSectionTitle);
                accessReportWarningDiv.appendChild(br);
            } else {
                continue;
            }
            for (let warning of currentConf.warnings[dataType]) {
                let warningSectionMessage = spawnFont(``,`warningFont`,warning);
                warningSectionMessage.setAttribute("color","white");
                let br = document.createElement('br');
                accessReportWarningDiv.appendChild(warningSectionMessage);
                accessReportWarningDiv.appendChild(br);
            }
        }
    }

    if (currentConf.checks.submitEnabled === true) {
        accessReportDiv.appendChild(accessReportContinueButton);

        for (let dataType in currentConf.previews) {
            if (currentConf.previews[dataType].input === undefined) {
                continue;
            }
            
            let titleType;

            if (dataType === "gene") {
                titleType = "Genes";
            }
            if (dataType === "prot") {
                titleType = "Proteins";
            }
            if (dataType === "meth") {
                titleType = "Methylations";
            }
            if (dataType === "urna") {
                titleType = "miRNAs";
            }
            if (dataType === "tf") {
                titleType = "Transcription Factors";
            }
            if (dataType === "chroma") {
                titleType = "Chromatin Status";
            }

            let dataTitle = spawnFont(``,`warningFont`,`- ${titleType} Preview:`);
            let inputFont = spawnFont(``,`warningFont`,`  1) Input IDs:${currentConf.previews[dataType].input}`);
            let filterTitle = spawnFont(``,`warningFont`,`  2) Filtered out due to:`);
            let ESFont = spawnFont(``,`warningFont`,`    Effect Size:${currentConf.previews[dataType].esFiltered}`);
            let pValFont = spawnFont(``,`warningFont`,`    p-value:${currentConf.previews[dataType].pValFiltered}`);
            let outputFont = spawnFont(``,`warningFont`,`  3) Output IDs:${currentConf.previews[dataType].output}`);
            
            accessReportPreviewDiv.appendChild(dataTitle);
            accessReportPreviewDiv.appendChild(document.createElement('br'));
            accessReportPreviewDiv.appendChild(inputFont);
            accessReportPreviewDiv.appendChild(document.createElement('br'));
            accessReportPreviewDiv.appendChild(filterTitle);
            accessReportPreviewDiv.appendChild(document.createElement('br'));
            accessReportPreviewDiv.appendChild(ESFont);
            accessReportPreviewDiv.appendChild(document.createElement('br'));
            accessReportPreviewDiv.appendChild(pValFont);
            accessReportPreviewDiv.appendChild(document.createElement('br'));
            accessReportPreviewDiv.appendChild(outputFont);
            accessReportPreviewDiv.appendChild(document.createElement('br'));
        }
        
    }

}
function closeReportDiv() {
    document.getElementById('configContainer').removeChild(document.getElementById(`accessReportDiv`));
}


function newSubmit() {

    currentConf.resetConf();
    currentConf.updateAll();
    currentConf.checkForSubmit();
    currentConf.enableSubmit();
    currentConf.filterPreview();
    spawnReportDiv();
}

var currentConf = {
    expInfo: {
        Id:undefined,
        Name:undefined,
        Comments:undefined,
        Organism:undefined
    },
    thresholdsEnabled: {
        pVal:undefined,
        effectSize: {
            Left: undefined,
            Right: undefined
        }
    },
    noDegsEnabled: {
        urna:undefined,
        meth:undefined,
        tf:undefined
    },
    modeEnabled:undefined,
    mapsRestrictionEnabled:undefined,
    mapsDataBase:undefined,
    tfEnabled:undefined,
    gene: {
        enabled:undefined,
        data:undefined,
        thresholdValues: {
            Left:undefined,
            Right:undefined,
            pVal:undefined
        }
    },
    urna: {
        enabled:undefined,
        data:undefined,
        thresholdValues: {
            Left:undefined,
            Right:undefined,
            pVal:undefined
        }
    },
    prot: {
        enabled:undefined,
        data:undefined,
        thresholdValues: {
            Left:undefined,
            Right:undefined,
            pVal:undefined
        }
    },
    meth: {
        enabled:undefined,
        data:undefined,
        thresholdValues: {
            Left:undefined,
            Right:undefined,
            pVal:undefined
        }
    },
    chroma: {
        enabled:undefined,
        data:undefined,
        thresholdValues: {
            Left:undefined,
            Right:undefined,
            pVal:undefined
        }
    },
    meta: {
        enabled:undefined,
        data:undefined,
        thresholdValues: {
            Left:undefined,
            Right:undefined,
            pVal:undefined
        }
    },
    checks: {
        submitEnabled: false,
        gene: {
            validThresholds: {
                effectSize: {
                    Left: undefined,
                    Right: undefined
                },
                pVal: undefined
            },
            validColumns: {
                id: undefined,
                pVal: undefined,
                effectSize: undefined
            }
        },
        prot: {
            validThresholds: {
                effectSize: {
                    Left: undefined,
                    Right: undefined
                },
                pVal: undefined
            },
            validColumns: {
                id: undefined,
                pVal: undefined,
                effectSize: undefined
            } 
        },
        urna: {
            validThresholds: {
                effectSize: {
                    Left: undefined,
                    Right: undefined
                },
                pVal: undefined
            },
            validColumns: {
                id: undefined,
                pVal: undefined,
                effectSize: undefined
            } 
        },
        meth: {
            validThresholds: {
                effectSize: {
                    Left: undefined,
                    Right: undefined
                },
                pVal: undefined
            },
            validColumns: {
                id: undefined,
                pVal: undefined,
                effectSize: undefined
            } 
        },
        chroma: {
            validThresholds: {
                effectSize: {
                    Left: undefined,
                    Right: undefined
                },
                pVal: undefined
            },
            validColumns: {
                id: undefined,
                pVal: undefined,
                effectSize: undefined
            } 
        },
        meta: {
            validThresholds: {
                effectSize: {
                    Left: undefined,
                    Right: undefined
                },
                pVal: undefined
            },
            validColumns: {
                id: undefined,
                pVal: undefined,
                effectSize: undefined
            } 
        }
    },
    warnings: {
        gene:[],
        prot:[],
        urna:[],
        meth:[],
        meta:[],
        chroma:[]
    },
    previews: {
        gene: {
            input: undefined,
            esFiltered: undefined,
            pValFiltered: undefined,
            output:undefined
        },
        prot: {
            input: undefined,
            esFiltered: undefined,
            pValFiltered: undefined,
            output:undefined
        },
        urna: {
            input: undefined,
            esFiltered: undefined,
            pValFiltered: undefined,
            output:undefined
        },
        meth: {
            input: undefined,
            esFiltered: undefined,
            pValFiltered: undefined,
            output:undefined
        },
        chroma: {
            input: undefined,
            esFiltered: undefined,
            pValFiltered: undefined,
            output:undefined
        },
        meta: {
            input: undefined,
            esFiltered: undefined,
            pValFiltered: undefined,
            output:undefined
        },
    },
    updateExpInfo: function() {
        currentConf.expInfo.Id = document.getElementById("exp_select").value;
        currentConf.expInfo.Name = document.getElementById("exp_name_input_text").value;
        currentConf.expInfo.Comments = document.getElementById("exp_comment_input_text").value;
        currentConf.expInfo.Organism = document.getElementById("exp_organism_input_text").value;
    },
    logExpInfo: function() {
        console.log(`Exp ID:${currentConf.expInfo.Id}`);
        console.log(`Exp Name:${currentConf.expInfo.Name}`);
        console.log(`Exp Comments:${currentConf.expInfo.Comments}`);
        console.log(`Exp Organism:${currentConf.expInfo.Organism}`);
    },
    updateModeEnabled: function() {
        currentConf.modeEnabled = document.getElementById("mode_select").value;
    },
    logModeEnabled: function() {
        console.log(`Mode:${currentConf.modeEnabled}`);
    },
    updateNoDegsEnabled: function() {
        if (document.getElementById("nodeg_select_urna").checked === true) {
            currentConf.noDegsEnabled.urna = true;
        } else {
            currentConf.noDegsEnabled.urna = false;
        }
        if (document.getElementById("nodeg_select_meth").checked === true) {
            currentConf.noDegsEnabled.meth = true;
        } else {
            currentConf.noDegsEnabled.meth = false;
        }
        if (document.getElementById("nodeg_select_tf").checked === true) {
            currentConf.noDegsEnabled.tf = true;
        } else {
            currentConf.noDegsEnabled.tf = false;
        }
        if (document.getElementById("nodeg_select_chroma").checked === true) {
            currentConf.noDegsEnabled.chroma = true;
        } else {
            currentConf.noDegsEnabled.chroma = false;
        }
    },
    logNoDegsEnabled: function() {
        console.log(`NoDEG Loaders Enabled:\n`);
        console.log(`miRNAs: ${currentConf.noDegsEnabled.urna}`);
        console.log(`Methylations: ${currentConf.noDegsEnabled.meth}`);
        console.log(`Chromatin Status: ${currentConf.noDegsEnabled.chroma}`);
        console.log(`TFs: ${currentConf.noDegsEnabled.tf}`);
    },
    updateMapsRestrictionEnabled: function() {
        currentConf.mapsRestrictionEnabled = document.getElementById("statistic_select").value;
    },
    logMapsRestrictionEnabled: function() {
        console.log(`Map Restriction Method: ${currentConf.mapsRestrictionEnabled}`);
    },
    updateMapsDataBase: function() {
        currentConf.mapsDataBase = document.getElementById("maps_db_select").value;
    },
    logMapsDataBase: function() {
        console.log(`Maps Database: ${currentConf.mapsDataBase}`);
    },
    updateTfEnabled: function() {
        if (document.getElementById("enabletfs").checked === true) {
            currentConf.tfEnabled = true;
        } else {
            currentConf.tfEnabled = false;
        }  
    },
    logTfEnabled: function() {
        console.log(`TFs Enabled: ${currentConf.tfEnabled}`);
    },
    updateThresholdsEnabled: function() {
        if (document.getElementById("filter_select_pval").value === "filter_p") {
            currentConf.thresholdsEnabled.pVal = true;
        } else {
            currentConf.thresholdsEnabled.pVal = false;
        }
        
        if (document.getElementById("filter_select_es").value === "filter_Left" && document.getElementById("mode_select").value === "full") {
            currentConf.thresholdsEnabled.effectSize.Left = true;
            currentConf.thresholdsEnabled.effectSize.Right = false;
        }
        if (document.getElementById("filter_select_es").value === "filter_Right" && document.getElementById("mode_select").value === "full") {
            currentConf.thresholdsEnabled.effectSize.Left = false;
            currentConf.thresholdsEnabled.effectSize.Right = true;
        }
        if (document.getElementById("filter_select_es").value === "filter_both" && document.getElementById("mode_select").value === "full") {
            currentConf.thresholdsEnabled.effectSize.Left = true;
            currentConf.thresholdsEnabled.effectSize.Right = true;
        }
        if (document.getElementById("mode_select").value === "id_only") {
            currentConf.thresholdsEnabled.effectSize.Left = false;
            currentConf.thresholdsEnabled.effectSize.Right = false;
        }
    },
    logThresholdsEnabled: function() {
        console.log(`p-value Filtering:`);
        console.log(` Enabled: ${currentConf.thresholdsEnabled.pVal}`);
        console.log(`Effect Size Filtering:`);
        console.log(` Left: ${currentConf.thresholdsEnabled.effectSize.Left}`);
        console.log(` Right: ${currentConf.thresholdsEnabled.effectSize.Right}`);
    },
    updateDataSet: function(type) {
        if (document.getElementById(`enable${type}`).checked === true) {
            currentConf[type].enabled = true;
        } else {
            currentConf[type].enabled = false;
        }

        currentConf[type].thresholdValues.Left = document.getElementById(`${type}LeftThreshold`).value;
        currentConf[type].thresholdValues.Right = document.getElementById(`${type}RightThreshold`).value;
        currentConf[type].thresholdValues.pVal = document.getElementById(`${type}pValThreshold`).value;

        currentConf[type].data = document.getElementById(`${type}_data`).value;
    },
    updateAll: function() {

        currentConf.resetConf();
        currentConf.updateExpInfo();
        currentConf.updateMapsDataBase();
        currentConf.updateModeEnabled();
        currentConf.updateMapsRestrictionEnabled();
        currentConf.updateNoDegsEnabled();
        currentConf.updateThresholdsEnabled();

        currentConf.updateDataSet("gene");
        currentConf.updateDataSet("prot");
        currentConf.updateDataSet("urna");
        currentConf.updateDataSet("meth");
        currentConf.updateDataSet("chroma");
        currentConf.updateDataSet("meta");
    },
    logAll: function() {
        currentConf.logExpInfo();
        currentConf.logMapsDataBase();
        currentConf.logModeEnabled();
        currentConf.logMapsRestrictionEnabled();
        currentConf.logNoDegsEnabled();
        currentConf.logThresholdsEnabled();
    },
    resetConf: function () {
    
        let dataTypes = ["gene","prot","urna","meth","meta","chroma"];

        for (let key in currentConf.expInfo) {
            currentConf.expInfo[key] = undefined;
        }
        currentConf.thresholdsEnabled.pVal = undefined;
        for (let key in currentConf.thresholdsEnabled.effectSize) {
            currentConf.thresholdsEnabled.effectSize[key] = undefined;
        }
        for (let key in currentConf.noDegsEnabled) {
            currentConf.noDegsEnabled[key] = undefined;
        }
        currentConf.modeEnabled = undefined;
        currentConf.mapsRestrictionEnabled = undefined;
        currentConf.mapsDataBase = undefined;
        currentConf.tfEnabled = undefined;

        currentConf.checks.submitEnabled = undefined;

        for (let dataType of dataTypes) {
            currentConf[dataType].enabled = undefined;
            currentConf[dataType].data = undefined;
            for (let key in currentConf[dataType].thresholdValues) {
                currentConf[dataType].thresholdValues[key] = undefined;
            }
            for (let key in currentConf.checks[dataType].validColumns) {
                currentConf.checks[dataType].validColumns[key] = undefined;
            }
            for (let key in currentConf.checks[dataType].validThresholds.effectSize) {
                currentConf.checks[dataType].validThresholds.effectSize[key] = undefined;
            }
            for (let key in currentConf.previews[dataType]) {
                currentConf.previews[dataType][key] = undefined;
            }
            currentConf.checks[dataType].validThresholds.pVal = undefined;
            currentConf.warnings[dataType] = [];
        }
    },
    enableSubmit: function() {
        let dataRequested = [];
        if (currentConf.gene.enabled === true) {
            dataRequested.push('gene');
        }
        if (currentConf.prot.enabled === true) {
            dataRequested.push('prot');
        }
        if (currentConf.urna.enabled === true) {
            dataRequested.push('urna');
        }
        if (currentConf.meth.enabled === true) {
            dataRequested.push('meth');
        }
        if (currentConf.meta.enabled === true) {
            dataRequested.push('meta');
        }
        if (currentConf.meth.enabled === true) {
            dataRequested.push('chroma');
        }

        let warningsCounter = 0;
        for (let dataType of dataRequested) {
            if (currentConf[dataType].data === "") {
                currentConf.warnings[dataType].push(`${dataType} dataset not found!`);
                warningsCounter++;
            }

            for (let key in currentConf.checks[dataType].validThresholds.effectSize) {
                if (currentConf.checks[dataType].validThresholds.effectSize[key] === false) {
                    currentConf.warnings[dataType].push(`${dataType} Threshold Value Effect Size ${key} invalid!`);
                    warningsCounter++;
                }  
            }
            if (currentConf.checks[dataType].validThresholds.pVal === false) {
                currentConf.warnings[dataType].push(`${dataType} Threshold Value pVal invalid!`);
                warningsCounter++;
            }
            for (let key in currentConf.checks[dataType].validColumns) {
                if (currentConf.checks[dataType].validColumns[key] === false) {
                    currentConf.warnings[dataType].push(`${key} column invalid`);
                    warningsCounter++;
                }
            }
        }
        if (warningsCounter === 0) {
            currentConf.checks.submitEnabled = true;
        } else {
            currentConf.checks.submitEnabled = false;
        }
    },
    checkForSubmit: function() {

        //need to add check for data!
        if (currentConf['gene'].enabled === true) {
            currentConf.checkColumns("gene","id");
        }
        if (currentConf['prot'].enabled === true) {
            currentConf.checkColumns("prot","id");
        } 
        if (currentConf['urna'].enabled === true) {
            currentConf.checkColumns("urna","id");
        }
        if (currentConf['meth'].enabled === true) {
            currentConf.checkColumns("meth","id");
        }
        if (currentConf['meta'].enabled === true) {
            currentConf.checkColumns("meta","id");
        }
        if (currentConf['chroma'].enabled === true) {
            currentConf.checkColumns("chroma","id");
        }

        if (currentConf.modeEnabled === "full") {

            if (currentConf['gene'].enabled === true) {
                currentConf.checkColumns("gene","dev");
            }
            if (currentConf['prot'].enabled === true) {
                currentConf.checkColumns("prot","dev");
            } 
            if (currentConf['urna'].enabled === true) {
                currentConf.checkColumns("urna","dev");
            }
            if (currentConf['meth'].enabled === true) {
                currentConf.checkColumns("meth","dev");
            }
            if (currentConf['chroma'].enabled === true) {
                currentConf.checkColumns("chroma","dev");
            }
            if (currentConf['meta'].enabled === true) {
                currentConf.checkColumns("meta","dev");
            }   
            if (currentConf.thresholdsEnabled.effectSize.Left === true) {
                if (currentConf['gene'].enabled === true) {
                    currentConf.checkEffectSize('gene','Left');
                }
                if (currentConf['prot'].enabled === true) {
                    currentConf.checkEffectSize('prot','Left');
                }
                if (currentConf['urna'].enabled === true) {
                    currentConf.checkEffectSize('urna','Left');
                }
                if (currentConf['meth'].enabled === true) {
                    currentConf.checkEffectSize('meth','Left');
                }
                if (currentConf['meta'].enabled === true) {
                    currentConf.checkEffectSize('meta','Left');
                }
                if (currentConf['chroma'].enabled === true) {
                    currentConf.checkEffectSize('chroma','Left');
                }
            }
            if (currentConf.thresholdsEnabled.effectSize.Right === true) {
                if (currentConf['gene'].enabled === true) {
                    currentConf.checkEffectSize('gene','Right');
                }
                if (currentConf['prot'].enabled === true) {
                    currentConf.checkEffectSize('prot','Right');
                }
                if (currentConf['urna'].enabled === true) {
                    currentConf.checkEffectSize('urna','Right');
                }
                if (currentConf['meth'].enabled === true) {
                    currentConf.checkEffectSize('meth','Right');
                }
                if (currentConf['meta'].enabled === true) {
                    currentConf.checkEffectSize('meta','Right');
                }
                if (currentConf['chroma'].enabled === true) {
                    currentConf.checkEffectSize('chroma','Right');
                }
            }
        }
        if (currentConf.modeEnabled === "full" || currentConf.modeEnabled === "id_only") {
            if (currentConf.thresholdsEnabled.pVal === true) {
                if (currentConf['gene'].enabled === true) {
                    currentConf.checkColumns("gene","pvalue");
                    currentConf.checkpVal('gene');
                }
                if (currentConf['prot'].enabled === true) {
                    currentConf.checkColumns("prot","pvalue");
                    currentConf.checkpVal('prot');
                }
                if (currentConf['urna'].enabled === true) {
                    currentConf.checkColumns("urna","pvalue");
                    currentConf.checkpVal('urna');
                }
                if (currentConf['meth'].enabled === true) {
                    currentConf.checkColumns("meth","pvalue");
                    currentConf.checkpVal('meth');
                }
                if (currentConf['meta'].enabled === true) {
                    currentConf.checkColumns("meta","pvalue");
                    currentConf.checkpVal('meta');
                }
                if (currentConf['chroma'].enabled === true) {
                    currentConf.checkColumns("chroma","pvalue");
                    currentConf.checkpVal('chroma');
                }
            }
        }
        if (currentConf.mapsDataBase === "") {

        }
        if (currentConf.modeEnabled === "") {

        }
    },
    checkEffectSize: function(type,direction) {
    
        let numRGX = /^\d+$|^\d+?\.\d+$|^[\-|\+]\d+$|^[\-|\+]\d+?\.\d+$/;
        //if (numRGX.test(exp_confs[`${currentConf.expInfo.Id}`][`${type}${direction}Threshold`])) {
        if (numRGX.test(currentConf[type].thresholdValues[direction])) {    
            currentConf.checks[type].validThresholds.effectSize[direction] = true;
        } else {
            currentConf.checks[type].validThresholds.effectSize[direction] = false;
        }
    },
    checkpVal: function(type) {

        let numRGX = /^\d+$|^\d+?\.\d+$|^[\-|\+]\d+$|^[\-|\+]\d+?\.\d+$/;

        //if (numRGX.test(exp_confs[`${currentConf.expInfo.Id}`][`${type}pValThreshold`])) {
        if (numRGX.test(currentConf[type].thresholdValues.pVal)) {
            currentConf.checks[type].validThresholds.pVal = true;
        } else {
            currentConf.checks[type].validThresholds.pVal = false;
        }
    },
    checkColumns: function(type,column) {

        
        let numRGX = /^\d+$/;

        let realType;
        if (column === "dev") {
            realType = "effectSize"; 
        }
        if (column === "pvalue") {
            realType = "pVal";
        }
        if (column === "id") {
            realType = "id";
        }

        if (numRGX.test(exp_confs[`${currentConf.expInfo.Id}`][`${type}_${column}_column`])) {
            currentConf.checks[type].validColumns[realType] = true;
        } else {
            currentConf.checks[type].validColumns[realType] = false;
        }
    },
    logChecks: function(type) {
        console.log(`Checks for: ${type}`);
        console.log(` Valid Columns:`);
        console.log(`  ID: ${currentConf.checks[type].validColumns.id}`);
        console.log(`  pVal: ${currentConf.checks[type].validColumns.pVal}`);
        console.log(`  Effect Size: ${currentConf.checks[type].validColumns.effectSize}`);
        console.log(` Valid Thresholds:`);
        console.log(`  Effect Size Left: ${currentConf.checks[type].validThresholds.effectSize.Left}`);
        console.log(`  Effect Size Right: ${currentConf.checks[type].validThresholds.effectSize.Right}`);
        console.log(`  pVal: ${currentConf.checks[type].validThresholds.pVal}`);
    },
    logAllChecks: function() {
        currentConf.logChecks('gene');
        currentConf.logChecks('prot');
        currentConf.logChecks('urna');
        currentConf.logChecks('meth');
        currentConf.logChecks('meta');
        currentConf.logChecks('chroma');
    },
    filterPreview: function() {
        let dataTypes = ["gene","prot","urna","meth","meta","chroma"];
        if (currentConf.checks.submitEnabled === true) {
            let seenIds = {};
            for (let dataType of dataTypes) {
                if (document.getElementById(`enable${dataType}`).checked === false) {
                    continue;
                }
                let pValThr = undefined;
                let pValCol = undefined;
                let LeftThr = undefined;
                let RightThr = undefined;
                let ESCol = undefined;
                let IDCol = exp_confs[currentConf.expInfo.Id][`${dataType}_id_column`] - 1;

                let dataSetLines = currentConf[dataType].data.split("\n");

                if (currentConf.modeEnabled === "full") {
                    if (currentConf.thresholdsEnabled.effectSize.Left === true) {
                        LeftThr = currentConf[dataType].thresholdValues.Left;
                        ESCol = exp_confs[currentConf.expInfo.Id][`${dataType}_dev_column`] - 1;
                    } 
                    if (currentConf.thresholdsEnabled.effectSize.Right === true) {
                        RightThr = currentConf[dataType].thresholdValues.Right;
                        ESCol = exp_confs[currentConf.expInfo.Id][`${dataType}_dev_column`] - 1;
                    }
                }
                if (currentConf.thresholdsEnabled.pVal === true) {
                    pValThr = currentConf[dataType].thresholdValues.pVal;
                    pValCol = exp_confs[currentConf.expInfo.Id][`${dataType}_pvalue_column`] - 1;
                }
                
                seenIds[`${dataType}`] = {
                    inputCounter:0,
                    esFilteredCounter:0,
                    pValFilteredCounter:0,
                    outputCounter:0,
                    list:{}
                };

                for (let dataSetLine of dataSetLines) {
                    let currentData = dataSetLine.split("\t");
                    let currentId = currentData[IDCol];
                    if (seenIds[`${dataType}`].list[currentId]) {
                        continue;
                    }
                    seenIds[`${dataType}`].list[currentId] = 1;
                    seenIds[`${dataType}`].inputCounter++;
                    if (currentConf.modeEnabled === "full") {
                        let currentES = currentData[ESCol];
                        if (currentConf.thresholdsEnabled.effectSize.Left === true && currentConf.thresholdsEnabled.effectSize.Right === true) {
                            if (currentES > LeftThr || currentES < RightThr) {
                                seenIds[`${dataType}`].esFilteredCounter++;
                                continue;
                            }
                        }
                        if (currentConf.thresholdsEnabled.effectSize.Left === false && currentConf.thresholdsEnabled.effectSize.Right === true) {
                            if (currentES < RightThr) {
                                seenIds[`${dataType}`].esFilteredCounter++;
                                continue;
                            }
                        }
                        if (currentConf.thresholdsEnabled.effectSize.Left === true && currentConf.thresholdsEnabled.effectSize.Right === false) {
                            if (currentES > LeftThr) {
                                seenIds[`${dataType}`].esFilteredCounter++;
                                continue;
                            }
                        }
                        if (currentConf.thresholdsEnabled.pVal === true) {
                            let currentpVal = currentData[pValCol];
                            if (currentpVal > pValThr) {
                                seenIds[`${dataType}`].pValFilteredCounter++;
                                continue;
                            }
                        }
                    }
                }
                seenIds[`${dataType}`].outputCounter = seenIds[`${dataType}`].inputCounter - seenIds[`${dataType}`].esFilteredCounter - seenIds[`${dataType}`].pValFilteredCounter;
                currentConf.previews[`${dataType}`].input = seenIds[`${dataType}`].inputCounter;
                currentConf.previews[`${dataType}`].esFiltered = seenIds[`${dataType}`].esFilteredCounter;
                currentConf.previews[`${dataType}`].pValFiltered = seenIds[`${dataType}`].pValFilteredCounter;
                currentConf.previews[`${dataType}`].output = seenIds[`${dataType}`].outputCounter;
            }
        }
    }
};

//if something remains undefined, it wasn't needed
//if something is true, it was needed and it has been found
//if something is false, it was needed but hasn't been found
