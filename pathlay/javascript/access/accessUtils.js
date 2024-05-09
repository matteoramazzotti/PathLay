function getCurrentDateTimeString() {
  // Get current date and time
  const currentDate = new Date();

  // Extract date components
  const year = currentDate.getFullYear();
  const month = (currentDate.getMonth() + 1).toString().padStart(2, '0'); // Months are zero-based
  const day = currentDate.getDate().toString().padStart(2, '0');

  // Extract time components
  const hours = currentDate.getHours().toString().padStart(2, '0');
  const minutes = currentDate.getMinutes().toString().padStart(2, '0');
  const seconds = currentDate.getSeconds().toString().padStart(2, '0');

  // Create the date-time string
  const dateTimeString = `${year}${month}${day}${hours}${minutes}${seconds}`;

  return dateTimeString;
}
function accessExpLoader () {

    resetEnablers();
    resetFields();

    dataSets = {};
	var expID = document.getElementById('exp_select').value;
    expConf.load(expID);
    lastConf.load(expID);
    checksOnConf.checkIdColumns();
    checksOnConf.checkIdTypes();
    checksOnConf.checkDevColumns();
    checksOnConf.checkpValColumns();
    checksOnConf.checkMapDBs();
	disableFields();
    disableMapDBs();

    var host = location.host;
	base_url = base !== "6135251850" ? "http://" + host + "/pathlay/pathlay_users/" + base + "/" + expID : "http://" + host + "/pathlay/demo_exps/" + base + "/" + expID;
    console.log('access.js ->' + host);
    console.log('access.js ->' + base_url);
    var currentTime=getCurrentDateTimeString();
	mrna_url = base_url + ".mrna"+ "?" + currentTime;
	urna_url = base_url + ".mirna"+ "?" + currentTime;
	meta_url = base_url + ".meta"+ "?" + currentTime;
	meth_url = base_url + ".meth"+ "?" + currentTime;
	onto_url = base_url + ".ont"+ "?" + currentTime;
	prot_url = base_url + ".prot"+ "?" + currentTime;
	chroma_url = base_url + ".chroma"+ "?" + currentTime;

	mrna_text = readTextFile(mrna_url);
	prot_text = readTextFile(prot_url);
	urna_text = readTextFile(urna_url);
	meth_text = readTextFile(meth_url);
	meta_text = readTextFile(meta_url);
	onto_text = readTextFile(onto_url);
	chroma_text = readTextFile(chroma_url);

	fillDataSets();
    checksOnConf.checkDataSets();
    disableEnablers();
    

    fillGenerics();
    fillEnablers();
    fillNoDEG();
    fillTFs();

	fillSetup();
    fillMapsDbSelect();
    restoreStatistic();
    restoreStatisticChecks();
    fillFETChecks();

	if (document.getElementById("thresholdDiv")) {
		
		initThresholdSelect();
        fillThresholdSelect();
		
		toggleThresholds(document.getElementById("thresholdSelect").selectedOptions[0].value);
        fillThresholdFields();
	}
    fillESChecks();
    fillpValCheck();

	currentConf.updateAll();
    checksOnCurrent.checkSubmit();
    currentPreview.makePrediction();
    currentPreview.printPrediction();
}
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

    if (currentConf.submitEnabled === false) { //removable
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

    if (currentConf.submitEnabled === true) {
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
    currentPreview.makePrediction();
    spawnReportDiv();
}

function readTextFile(file) {
	//console.log(file);
	var ms = Date.now();
	req = new XMLHttpRequest();
	req.overrideMimeType('text/plain');
    req.open( "GET", `${file}?dummy=${ms}`, false );
	req.send( null );
	//console.log(req);

	if (req.status == 404) {
		//alert("No"+file);
		res = '';
	} else {
		//console.log("found file");
		res = req.responseText;
	}
	return res;
}

function toggleThresholds(choiceValue) {
	
	let divsToHide = document.getElementsByClassName("thresholdInputDiv");
	for (let divToHide of divsToHide) {
		divToHide.style.display = "none";
	}
	document.getElementById(`${choiceValue}ThresholdInputDiv`).style.display = "block";;
}

function fillThresholdSelect() {
    for (let dataType of dataTypes) {
        if (checksOnConf[dataType].dataAvailable) {
            var Option = document.createElement("option");
		    Option.text = prettyTypes[dataType];
		    Option.value = dataType;
		    document.getElementById("thresholdSelect").add(Option);
        }
    }
}



function initThresholdSelect() {
    document.getElementById("thresholdSelectDiv").removeChild(document.getElementById("thresholdSelect"));
	let thresholdSelect = document.createElement("select");
	thresholdSelect.setAttribute("id","thresholdSelect");
	thresholdSelect.setAttribute("class","thresholdSelect");
	thresholdSelect.setAttribute("onchange","toggleThresholds(this.selectedOptions[0].value)");
	document.getElementById("thresholdSelectDiv").appendChild(thresholdSelect);
}


function fillSetup () {
    for (let dataType of dataTypes) {
        document.getElementById(`${dataType}IdType`).value = expConf[`${dataType}IdType`];
	    document.getElementById(`${dataType}_id_column`).value = expConf[`${dataType}_id_column`];
	    document.getElementById(`${dataType}_dev_column`).value = expConf[`${dataType}_dev_column`];
	    document.getElementById(`${dataType}_pvalue_column`).value = expConf[`${dataType}_pvalue_column`];
    }
}
function fillThresholdFields() {
    for (let dataType of dataTypes) {
        
        if (
            document.getElementById(`${dataType}LeftThreshold`) && 
            lastConf[dataType]['LeftThreshold'] != "" &&
            lastConf[dataType]['LeftThreshold'] !== undefined
        ) {
			document.getElementById(`${dataType}LeftThreshold`).value = lastConf[dataType]['LeftThreshold'];
		}
		if (
            document.getElementById(`${dataType}RightThreshold`) && 
            lastConf[dataType]['RightThreshold'] != "" &&
            lastConf[dataType]['RightThreshold'] !== undefined
        ) {
			document.getElementById(`${dataType}RightThreshold`).value = lastConf[dataType]['RightThreshold'];
		}
		if (
            document.getElementById(`${dataType}pValThreshold`) && 
            lastConf[dataType]['pValThreshold'] != "" &&
            lastConf[dataType]['pValThreshold'] !== undefined
        ) {
			document.getElementById(`${dataType}pValThreshold`).value = lastConf[dataType]['pValThreshold'];
		}
    }
}
function fillDataSets() {
    if (mrna_text) {
        dataSets['gene'] = mrna_text;
    }
    if (prot_text) {
        dataSets['prot'] = prot_text;
    }
    if (urna_text) {
        dataSets['urna'] = urna_text;
    }
    if (meth_text) {
        dataSets['meth'] = meth_text;
    }
    if (meta_text) {
        dataSets['meta'] = meta_text;
    }
    if (chroma_text) {
        dataSets['chroma'] = chroma_text;
    }

    for (let dataType of dataTypes) {
        if (dataSets[dataType]) {
            document.getElementById(`${dataType}_data`).value = dataSets[dataType];
        } else {
            document.getElementById(`${dataType}_data`).value = "";
        }        
    }
}
function fillGenerics() {
    document.getElementById("exp_name_input_text").value = expConf.name;
	document.getElementById("exp_comment_input_text").value = expConf.comment;
	if (document.getElementById("exp_organism_input_text")) {
		document.getElementById("exp_organism_input_text").value = expConf.organism;
	}
}
function fillNoDEG () {

    for (let type of dataTypes) {
        if (lastConf[type][`nodeg_select`]) {
            if ((lastConf[type][`nodeg_select`]) === true) {
                document.getElementById(`nodeg_select_${type}`).checked = true;        
            } else {
                document.getElementById(`nodeg_select_${type}`).checked = false;
            }
            if (lastConf[type][`NoDEFromIdOnlyCheck`] == true) {
                document.getElementById(`${type}NoDEFromIdOnlyCheck`).checked = true;
            } else {
                document.getElementById(`${type}NoDEFromIdOnlyCheck`).checked = false;
            }
        }
    }
    
    
}
function fillEnablers() {
    for (let type of dataTypes) {
        if (lastConf[type].enabled === true) {
            document.getElementById(`enable${type}`).checked = true;           
        } else {
            document.getElementById(`enable${type}`).checked = false;
        }
        if (lastConf[type][`IdOnlyCheck`]) {
            if (lastConf[type][`IdOnlyCheck`] == true) {
                document.getElementById(`${type}IdOnlyCheck`).checked = true;
            } else {
                document.getElementById(`${type}IdOnlyCheck`).checked = false;
            }
        }
    }
    
}
function fillESChecks() {
    for (let dataType of dataTypes) {
        if (lastConf[dataType][`RightEnabled`]) {
            if (lastConf[dataType][`RightEnabled`] == true) {
                document.getElementById(`${dataType}RightEffectSizeCheck`).checked = true;
            } else {
                document.getElementById(`${dataType}RightEffectSizeCheck`).checked = false;
            }
        } 
        if (lastConf[dataType][`LeftEnabled`]) {
            if (lastConf[dataType][`LeftEnabled`] == true) {
                document.getElementById(`${dataType}LeftEffectSizeCheck`).checked = true;
            } else {
                document.getElementById(`${dataType}LeftEffectSizeCheck`).checked = false;
            }
        } 
    }
}
function fillpValCheck() {
    for (let dataType of dataTypes) {
        if (lastConf[dataType][`pValEnabled`]) {
            if (lastConf[dataType][`pValEnabled`] == true) {
                document.getElementById(`${dataType}pValCheck`).checked = true;
            } else {
                document.getElementById(`${dataType}pValCheck`).checked = false;
            }
        }
    }
}
function fillTFs() {
    let dataTypesLocal = ['gene','prot'];
    for (let type of dataTypesLocal) {
        if (lastConf[type][`tfEnabled`]) {
            if ((lastConf[type][`tfEnabled`]) === true) {
                document.getElementById(`enabletfs_${type}`).checked = true;        
            } else {
                document.getElementById(`enabletfs_${type}`).checked = false;
            }
        }
        if (lastConf[type][`noDeFromTfEnabled`]) {
            if (lastConf[type][`noDeFromTfEnabled`] == true) {
                document.getElementById(`nodeg_select_tf_${type}`).checked = true;
            } else {
                document.getElementById(`nodeg_select_tf_${type}`).checked = false;
            }
        }

        if (lastConf[type][`tfsIdOnlyCheck`]) {
            if (lastConf[type][`tfsIdOnlyCheck`] == true) {
                document.getElementById(`enabletfsIdOnly_${type}`).checked = true;
            } else {
                document.getElementById(`enabletfsIdOnly_${type}`).checked = false;
            }
        }
        if (lastConf[type][`tfsNoDEFromIdOnlyCheck`]) {
            if (lastConf[type][`tfsNoDEFromIdOnlyCheck`] == true) {
                document.getElementById(`tfsNoDEFromIdOnlyCheck_${type}`).checked = true;
            } else {
                document.getElementById(`tfsNoDEFromIdOnlyCheck_${type}`).checked = false;
            }
        }
    }
}

function restoreStatistic() {
    if (document.getElementById("statistic_select")) {
        if (lastConf.statisticProcedure == "Nothing") {
            document.getElementById("statistic_select").selectedIndex = 0;
        }
        if (lastConf.statisticProcedure == "FET") {
            document.getElementById("statistic_select").selectedIndex = 1;
        }
    }
}
function fillFETChecks() {
    for (let dataType of dataTypes) {
        if (lastConf[dataType].FETEnabled == true) {
            document.getElementById(`${dataType}FETEnabled`).checked = true;
        } else {
            document.getElementById(`${dataType}FETEnabled`).checked = false;
        }
    }
}
function restoreStatisticChecks() {
    if (document.getElementById("FETPooling")) {
        if (lastConf.FETPooling == true) {
            document.getElementById("FETPooling").checked = true;
        } else {
            document.getElementById("FETPooling").checked = false;
        }
    }
    if (document.getElementById("FETIntersect")) {
        if (lastConf.FETIntersect == true) {
            document.getElementById("FETIntersect").checked = true;
        } else {
            document.getElementById("FETIntersect").checked = false;
        }
    }
}


function fillMapsDbSelect() {

    if (document.getElementById("maps_db_select")) {
		if (lastConf.maps_db_select == "kegg") {
            document.getElementById("maps_db_select").selectedIndex = 0;
        }
        if (lastConf.maps_db_select == "wikipathways") {
            document.getElementById("maps_db_select").selectedIndex = 1;
        }
	}
    //changeSelectionByValue("maps_db_select",lastConf.maps_db_select);
}
function changeSelectionByValue(selectorId,value) {
    document.querySelector('#'+selectorId).value = value;
}
function disableEnablers() {
    for (let dataType of dataTypes) {
        if (
            checksOnConf[dataType].idAvailable === false || 
            checksOnConf[dataType].idTypeAvailable === false ||
            checksOnConf[dataType].dataAvailable === false
        ) {
            document.getElementById(`enable${dataType}`).disabled = true;
            document.getElementById(`${dataType}IdOnlyCheck`).disabled = true;
            if (document.getElementById(`enabletfs_${dataType}`)) {
                document.getElementById(`enabletfs_${dataType}`).disabled = true;
            }
            if (document.getElementById(`nodeg_select_tf_${dataType}`)) {
                document.getElementById(`nodeg_select_tf_${dataType}`).disabled = true;
            }
            if (document.getElementById(`nodeg_select_${dataType}`)) {
                document.getElementById(`nodeg_select_${dataType}`).disabled = true;
            }
            if (document.getElementById(`${dataType}NoDEFromIdOnlyCheck`)) {
                document.getElementById(`${dataType}NoDEFromIdOnlyCheck`).disabled = true;
            }
        }
    }
}
function disableFields() {
    for (let dataType of dataTypes) {
        if (checksOnConf[dataType].devAvailable === false) {
            document.getElementById(`${dataType}RightEffectSizeCheck`).disabled = true;
            document.getElementById(`${dataType}LeftEffectSizeCheck`).disabled = true;
            document.getElementById(`${dataType}LeftThreshold`).disabled = true;
            document.getElementById(`${dataType}RightThreshold`).disabled = true;
        }
        if (checksOnConf[dataType].pValAvailable === false) {
            document.getElementById(`${dataType}pValCheck`).disabled = true;
            document.getElementById(`${dataType}pValThreshold`).disabled = true;
        }
    }
}
function disableMapDBs() {
    if (checksOnConf.kegg === false) {
        document.getElementById('maps_db_select').options[0].disabled = true;
    } else {
        document.getElementById('maps_db_select').options[0].disabled = false;
    }
    if (checksOnConf.wikipathways === false) {
        document.getElementById('maps_db_select').options[1].disabled = true;
    } else {
        document.getElementById('maps_db_select').options[1].disabled = false;
    }
}
function resetEnablers() {
    for (let dataType of dataTypes) {
        document.getElementById(`enable${dataType}`).disabled = false;
        document.getElementById(`enable${dataType}`).checked = false;
        document.getElementById(`${dataType}IdOnlyCheck`).disabled = false;
        document.getElementById(`${dataType}IdOnlyCheck`).checked = false;
        if (document.getElementById(`enabletfs_${dataType}`)) {
            document.getElementById(`enabletfs_${dataType}`).disabled = false;
            document.getElementById(`enabletfs_${dataType}`).checked = false;
        }
        if (document.getElementById(`nodeg_select_tf_${dataType}`)) {
            document.getElementById(`nodeg_select_tf_${dataType}`).disabled = false;
            document.getElementById(`nodeg_select_tf_${dataType}`).checked = false;
        }
        if (document.getElementById(`nodeg_select_${dataType}`)) {
            document.getElementById(`nodeg_select_${dataType}`).disabled = false;
            document.getElementById(`nodeg_select_${dataType}`).checked = false;
        }
        if (document.getElementById(`${dataType}NoDEFromIdOnlyCheck`)) {
            document.getElementById(`${dataType}NoDEFromIdOnlyCheck`).disabled = false;
            document.getElementById(`${dataType}NoDEFromIdOnlyCheck`).checked = false;
        }
    }
}
function resetFields() {
    for (let dataType of dataTypes) {
        document.getElementById(`${dataType}RightEffectSizeCheck`).disabled = false;
        document.getElementById(`${dataType}LeftEffectSizeCheck`).disabled = false;
        document.getElementById(`${dataType}LeftThreshold`).disabled = false;
        document.getElementById(`${dataType}RightThreshold`).disabled = false;
        document.getElementById(`${dataType}pValCheck`).disabled = false;
        document.getElementById(`${dataType}pValThreshold`).disabled = false;
    }
}
function dynamicChecks() {
    checksOnCurrent.checkSubmit();
    currentPreview.makePrediction();
    currentPreview.printPrediction();
}