function accessExpLoader () {


	resetCheckBoxes();


	var what = document.getElementById('exp_select').value;
	var host = location.host;
	base_url = "http://" + host + "/pathlay/pathlay_users/" + base + "/" + what;

	mrna_url = base_url + ".mrna";
	urna_url = base_url + ".mirna";
	meta_url = base_url + ".meta";
	meth_url = base_url + ".meth";
	onto_url = base_url + ".ont";
	prot_url = base_url + ".prot";
	chroma_url = base_url + ".chroma";

	mrna_text = readTextFile(mrna_url);
	prot_text = readTextFile(prot_url);
	urna_text = readTextFile(urna_url);
	meth_text = readTextFile(meth_url);
	meta_text = readTextFile(meta_url);
	onto_text = readTextFile(onto_url);
	chroma_text = readTextFile(chroma_url);

	if (!mrna_text && document.getElementById("enablegene")) {
		if (document.getElementById("enablegene").checked) {
			document.getElementById("enablegene").checked = false;
		}
		document.getElementById("enablegene").disabled = true;
	}
	if (!urna_text && document.getElementById("enableurna") && document.getElementById("nodeg_select_urna")) {
		if (document.getElementById("enableurna").checked) {
			document.getElementById("enableurna").checked = false;
		}
		if (document.getElementById("nodeg_select_urna").checked) {
			document.getElementById("nodeg_select_urna").checked = false;
		}
		document.getElementById("enableurna").disabled = true;
		document.getElementById("nodeg_select_urna").disabled = true;
	}
	if (!prot_text && document.getElementById("enableprot")) {
		if (document.getElementById("enableprot").checked) {
			document.getElementById("enableprot").checked = false;
		}
		document.getElementById("enableprot").disabled = true;
	}
	if (!meth_text && document.getElementById("enablemeth") && document.getElementById("nodeg_select_meth")) {
		if (document.getElementById("enablemeth").checked) {
			document.getElementById("enablemeth").checked = false;
		}
		if (document.getElementById("nodeg_select_meth").checked) {
			document.getElementById("nodeg_select_meth").checked = false;
		}
		document.getElementById("enablemeth").disabled = true;
		document.getElementById("nodeg_select_meth").disabled = true;
	}
	if (!chroma_text && document.getElementById("enablechroma") && document.getElementById("nodeg_select_chroma")) {
		if (document.getElementById("enablechroma").checked) {
			document.getElementById("enablechroma").checked = false;
		}
		if (document.getElementById("nodeg_select_chroma").checked) {
			document.getElementById("nodeg_select_chroma").checked = false;
		}
		document.getElementById("enablechroma").disabled = true;
		document.getElementById("nodeg_select_chroma").disabled = true;
	}
	if (!meta_text && document.getElementById("enablemeta")) {
		if (document.getElementById("enablemeta").checked) {
			document.getElementById("enablemeta").checked = false;
		}
		document.getElementById("enablemeta").disabled = true;
	}
	if (!mrna_text && !prot_text && document-getElementById("enabletfs") && document.getElementById("nodeg_select_tf")) {
		if (document.getElementById("enabletfs").checked) {
			document.getElementById("enabletfs").checked = false;
		}
		if (document.getElementById("nodeg_select_tf").checked) {
			document.getElementById("nodeg_select_tf").checked = false;
		}
		document.getElementById("enabletfs").disabled = true;
		document.getElementById("nodeg_select_tf").disabled = true;
	}

	document.getElementById("gene_data").value = mrna_text;
	document.getElementById("urna_data").value = urna_text;
	document.getElementById("prot_data").value = prot_text;
	document.getElementById("meth_data").value = meth_text;
	document.getElementById("meta_data").value = meta_text;
	document.getElementById("chroma_data").value = chroma_text;


	document.getElementById("exp_name_input_text").value = exp_confs[what].exp_name_input_text;
	document.getElementById("exp_comment_input_text").value = exp_confs[what].exp_comment_input_text;
	if (document.getElementById("exp_organism_input_text")) {
		document.getElementById("exp_organism_input_text").value = exp_confs[what].organism;
	}

    restoreMode(exp_confs[what]);
	restoreEffectSizeSelector(exp_confs[what]);
	restorepValSelector(exp_confs[what]);

    fillNoDEG(exp_confs[what]);
    fillEnablers(exp_confs[what]);

	fillSetup(exp_confs[what],"gene");
	fillSetup(exp_confs[what],"prot");
	fillSetup(exp_confs[what],"meta");
	fillSetup(exp_confs[what],"meth");
	fillSetup(exp_confs[what],"urna");
	fillSetup(exp_confs[what],"chroma");

	if (exp_confs[what].enabletfs === 1) {
		document.getElementById("enabletfs").checked = true;
	}

	displayThresholdsByMode();

	if (document.getElementById("maps_db_select")) {
		if (!exp_confs[what].kegg) {
			document.getElementById("maps_db_select").options[0].disabled = true;
		}
		if (!exp_confs[what].wikipathways) {
			document.getElementById("maps_db_select").options[1].disabled = true;
		}
	}

    fillMapsDbSelect(exp_confs[what]);

	if (document.getElementById("thresholdDiv")) {
		
		document.getElementById("thresholdSelectDiv").removeChild(document.getElementById("thresholdSelect"));
		let thresholdSelect = document.createElement("select");
		thresholdSelect.setAttribute("id","thresholdSelect");
		thresholdSelect.setAttribute("class","thresholdSelect");
		thresholdSelect.setAttribute("onchange","toggleThresholds(this.selectedOptions[0].value)");
		document.getElementById("thresholdSelectDiv").appendChild(thresholdSelect);
		//document.getElementById("thresholdSelect").style.display = "block";

		if (mrna_text) {
			var geneOption = document.createElement("option");
			geneOption.text = "Genes";
			geneOption.value = "gene";
			document.getElementById("thresholdSelect").add(geneOption);
		}
		if (prot_text) {
			var protOption = document.createElement("option");
			protOption.text = "Proteins";
			protOption.value = "prot";
			document.getElementById("thresholdSelect").add(protOption);
		}
		if (urna_text) {
			var urnaOption = document.createElement("option");
			urnaOption.text = "miRNAs";
			urnaOption.value = "urna";
			document.getElementById("thresholdSelect").add(urnaOption);
		}
		if (meth_text) {
			var methOption = document.createElement("option");
			methOption.text = "Methylations";
			methOption.value = "meth";
			document.getElementById("thresholdSelect").add(methOption);
		}
		if (meta_text) {
			var metaOption = document.createElement("option");
			metaOption.text = "Metabolites";
			metaOption.value = "meta";
			document.getElementById("thresholdSelect").add(metaOption);
		}
		if (chroma_text) {
			var chromaOption = document.createElement("option");
			chromaOption.text = "Chromatin Status";
			chromaOption.value = "chroma";
			document.getElementById("thresholdSelect").add(chromaOption);
		}
		toggleThresholds(document.getElementById("thresholdSelect").selectedOptions[0].value);

		if (document.getElementById("geneLeftThreshold") && exp_confs[what].geneLeftThreshold) {
			document.getElementById("geneLeftThreshold").value = exp_confs[what].geneLeftThreshold;
		}
		if (document.getElementById("geneRightThreshold") && exp_confs[what].geneRightThreshold) {
			document.getElementById("geneRightThreshold").value = exp_confs[what].geneRightThreshold;
		}
		if (document.getElementById("genepValThreshold") && exp_confs[what].genepValThreshold) {
			document.getElementById("genepValThreshold").value = exp_confs[what].genepValThreshold;
		}
		if (document.getElementById("protLeftThreshold") && exp_confs[what].protLeftThreshold) {
			document.getElementById("protLeftThreshold").value = exp_confs[what].protLeftThreshold;
		}
		if (document.getElementById("protRightThreshold") && exp_confs[what].protRightThreshold) {
			document.getElementById("protRightThreshold").value = exp_confs[what].protRightThreshold;
		}
		if (document.getElementById("protpValThreshold") && exp_confs[what].protpValThreshold) {
			document.getElementById("protpValThreshold").value = exp_confs[what].protpValThreshold;
		}
		if (document.getElementById("urnaLeftThreshold") && exp_confs[what].urnaLeftThreshold) {
			document.getElementById("urnaLeftThreshold").value = exp_confs[what].urnaLeftThreshold;
		}
		if (document.getElementById("urnaRightThreshold") && exp_confs[what].urnaRightThreshold) {
			document.getElementById("urnaRightThreshold").value = exp_confs[what].urnaRightThreshold;
		}
		if (document.getElementById("urnapValThreshold") && exp_confs[what].urnapValThreshold) {
			document.getElementById("urnapValThreshold").value = exp_confs[what].urnapValThreshold;
		}
		if (document.getElementById("methLeftThreshold") && exp_confs[what].methLeftThreshold) {
			document.getElementById("methLeftThreshold").value = exp_confs[what].methLeftThreshold;
		}
		if (document.getElementById("methRightThreshold") && exp_confs[what].methRightThreshold) {
			document.getElementById("methRightThreshold").value = exp_confs[what].methRightThreshold;
		}
		if (document.getElementById("methpValThreshold") && exp_confs[what].methpValThreshold) {
			document.getElementById("methpValThreshold").value = exp_confs[what].methpValThreshold;
		}
		if (document.getElementById("metaLeftThreshold") && exp_confs[what].metaLeftThreshold) {
			document.getElementById("metaLeftThreshold").value = exp_confs[what].metaLeftThreshold;
		}
		if (document.getElementById("metaRightThreshold") && exp_confs[what].metaRightThreshold) {
			document.getElementById("metaRightThreshold").value = exp_confs[what].metaRightThreshold;
		}
		if (document.getElementById("metapValThreshold") && exp_confs[what].metapValThreshold) {
			document.getElementById("metapValThreshold").value = exp_confs[what].metapValThreshold;
		}
		if (document.getElementById("chromaLeftThreshold") && exp_confs[what].chromaLeftThreshold) {
			document.getElementById("chromaLeftThreshold").value = exp_confs[what].chromaLeftThreshold;
		}
		if (document.getElementById("chromaRightThreshold") && exp_confs[what].chromaRightThreshold) {
			document.getElementById("chromaRightThreshold").value = exp_confs[what].chromaRightThreshold;
		}
		if (document.getElementById("chromapValThreshold") && exp_confs[what].chromapValThreshold) {
			document.getElementById("chromapValThreshold").value = exp_confs[what].chromapValThreshold;
		}
	}


	currentConf.updateAll();
}

function enable_submit() {

    checkBoxes();
    checkDatabases();

}

function fillMapsDbSelect (conf) {
    changeSelectionByValue("maps_db_select",conf.maps_db_select);
}
function fillGeneSetup (conf) {

	document.getElementById("geneIdType").value = conf.geneIdType;
	document.getElementById("gene_id_column").value = conf.gene_id_column;
	document.getElementById("gene_dev_column").value = conf.gene_dev_column;
	document.getElementById("gene_pvalue_column").value = conf.gene_pvalue_column;
}
function fillProteinSetup (conf) {
	document.getElementById("protIdType").value = conf.protIdType;
	document.getElementById("prot_id_column").value = conf.prot_id_column;
	document.getElementById("prot_dev_column").value = conf.prot_dev_column;
	document.getElementById("prot_pvalue_column").value = conf.prot_pvalue_column;
}
function fillmiRNASetup (conf) {
	document.getElementById("urnaIdType").value = conf.urnaIdType;
	document.getElementById("urna_id_column").value = conf.urna_id_column;
	document.getElementById("urna_dev_column").value = conf.urna_dev_column;
	document.getElementById("urna_pvalue_column").value = conf.urna_pvalue_column;
}
function fillMethylationSetup (conf) {
	document.getElementById("methIdType").value = conf.methIdType;
	document.getElementById("meth_id_column").value = conf.meth_id_column;
	document.getElementById("meth_dev_column").value = conf.meth_dev_column;
	document.getElementById("meth_pvalue_column").value = conf.meth_pvalue_column;
}
function fillChromatinSetup (conf) {
	document.getElementById("chromaIdType").value = conf.chromaIdType;
	document.getElementById("chroma_id_column").value = conf.chroma_id_column;
	document.getElementById("chroma_dev_column").value = conf.chroma_dev_column;
	document.getElementById("chroma_pvalue_column").value = conf.chroma_pvalue_column;
}
function fillMetaboliteSetup (conf) {
	document.getElementById("metaIdType").value = conf.metaIdType;
	document.getElementById("meta_id_column").value = conf.meta_id_column;
	document.getElementById("meta_dev_column").value = conf.meta_dev_column;
	document.getElementById("meta_pvalue_column").value = conf.meta_pvalue_column;
}

function fillSetup (conf,dataType) {
	document.getElementById(`${dataType}IdType`).value = conf[`${dataType}IdType`];
	document.getElementById(`${dataType}_id_column`).value = conf[`${dataType}_id_column`];
	document.getElementById(`${dataType}_dev_column`).value = conf[`${dataType}_dev_column`];
	document.getElementById(`${dataType}_pvalue_column`).value = conf[`${dataType}_pvalue_column`];
}






function fillExpInfo (conf) {
	document.getElementById("exp_name_input_text").value = conf.exp_name_input_text;
	document.getElementById("exp_comment_input_text").value = conf.exp_comment_input_text;
	if (document.getElementById("exp_organism_input_text")) {
		document.getElementById("exp_organism_input_text").value = conf.organism;
	}
}
function fillNoDEG (conf) {

    if (conf.nodeg_select_urna == 1) {
        document.getElementById("nodeg_select_urna").checked = true;
    }
    if (conf.nodeg_select_meth == 1) {
        document.getElementById("nodeg_select_meth").checked = true;
    }
	if (conf.nodeg_select_chroma == 1) {
        document.getElementById("nodeg_select_chroma").checked = true;
    }
    if (conf.nodeg_select_tf == 1) {
        document.getElementById("nodeg_select_tf").checked = true;
    }
    
}
function fillEnablers (conf) {
    if (conf.enablegene == 1) {
        document.getElementById("enablegene").checked = true;
    }
    if (conf.enableprot == 1) {
        document.getElementById("enableprot").checked = true;
    }
    if (conf.enableurna == 1) {
        document.getElementById("enableurna").checked = true;
    }
    if (conf.enablemeth == 1) {
        document.getElementById("enablemeth").checked = true;
    }
	if (conf.enablechroma == 1) {
        document.getElementById("enablechroma").checked = true;
    }
    if (conf.enablemeta == 1) {
        document.getElementById("enablemeta").checked = true;
    }
    if (conf.enabletfs == 1) {
        document.getElementById("enabletfs").checked = true;
    }
}
function readTextFile(file) {
	//console.log(file);
	req = new XMLHttpRequest();
	req.overrideMimeType('text/plain');
    req.open( "GET", file, false );
	req.send( null );
	//console.log(req);

	if (req.status == 404) {
		alert("No"+file);
		res = '';
	} else {
		//console.log("found file");
		res = req.responseText;
	}
	return res;
}
function restoreMode(conf) {
    changeSelectionByValue("mode_select",conf.mode_select);
}
function restorepValSelector(conf) {
	changeSelectionByValue("filter_select_pval",conf.filter_select_pval);
}
function restoreEffectSizeSelector(conf) {
	changeSelectionByValue("filter_select_es",conf.filter_select_es);
}
function changeSelectionByValue(selectorId,value) {
    document.querySelector('#'+selectorId).value = value;
}
function checkBox(caller,boxId) {
	let boxToCheck = document.getElementById(boxId);
	let callerBox = document.getElementById(caller.id);
	if (boxToCheck.checked === false && boxToCheck.disabled === false) {
		if (callerBox.checked === true) {
			boxToCheck.checked = true;	
		}
	}
}

function checkBoxes() {

	var enablegene = document.getElementById('enablegene');
    var enableurna = document.getElementById('enableurna');
    var enablemeta = document.getElementById('enablemeta');
    var enablemeth = document.getElementById('enablemeth');
    var enableprot = document.getElementById('enableprot');
	var enablechroma = document.getElementById('enablechroma');
    var main_submit = document.getElementById('main_submit');

    if (enablegene.checked === false &&
    	enableurna.checked === false &&
        enablemeta.checked === false &&
        enablemeth.checked === false &&
		enablechroma.checked === false &&
        enableprot.checked === false
    ) {
        alert("Checkboxes are not checked!");
        main_submit.style.visibility = "hidden";
        return;
    } else {
        main_submit.style.visibility = "visible";
    }

    if (enablegene.disabled === true &&
         enableurna.disabled === true &&
         enablemeta.disabled === true &&
         enablemeth.disabled === true &&
         enableprot.disabled === true &&
		 enablechroma.disabled === true
     ) {
         alert("Checkboxes are all disabled!");
         main_submit.style.visibility = "hidden";
         return;
     } else {
         main_submit.style.visibility = "visible";
     }
}
function resetCheckBoxes() {
	if (document.getElementById("enablegene")) {
		document.getElementById("enablegene").disabled = false;
	}
	if (document.getElementById("enableurna")){
		document.getElementById("enableurna").disabled = false;
	}
	if (document.getElementById("nodeg_select_urna")) {
		document.getElementById("nodeg_select_urna").disabled = false;
	}
	if (document.getElementById("enableprot")) {
		document.getElementById("enableprot").disabled = false;
	}
	if (document.getElementById("enablemeth")) {
		document.getElementById("enablemeth").disabled = false;
	}
	if (document.getElementById("enablechroma")) {
		document.getElementById("enablechroma").disabled = false;
	}
	if (document.getElementById("nodeg_select_meth")) {
		document.getElementById("nodeg_select_meth").disabled = false;
	}
	if (document.getElementById("nodeg_select_chroma")) {
		document.getElementById("nodeg_select_chroma").disabled = false;
	}
	if (document.getElementById("enablemeta")) {
		document.getElementById("enablemeta").disabled = false;
	}
	if (document.getElementById("enabletfs")) {
		document.getElementById("enabletfs").disabled = false;
	}
	if (document.getElementById("nodeg_select_tf")) {
		document.getElementById("nodeg_select_tf").disabled = false;
	}
}
function checkDatabases () {
    if (document.getElementById("maps_db_select").options[0].disabled === true &&
        document.getElementById("maps_db_select").options[1].disabled === true
    ) {
        alert("No Databases available for the selected organism: check your pathlay_data/"+exp_confs[what].organism+" folder!");
        main_submit.style.visibility = 'hidden';
    }
}
function toggleThresholds(choiceValue) {
	
	let divsToHide = document.getElementsByClassName("thresholdInputDiv");
	for (let divToHide of divsToHide) {
		divToHide.style.display = "none";
	}
	document.getElementById(choiceValue + "ThresholdInputDiv").style.display = "block";;
}


function displayThresholdsByMode() {

	let modeSelected = document.getElementById("mode_select").value;
	let effectSizeFilter = document.getElementById("filter_select_es").value;
	let pValFilter = document.getElementById("filter_select_pval").value;

	
	if (modeSelected === "id_only") {
		hideEffectSizeSelector();
		hideEffectSizeFont();
		hideEffectSizeLeftThresholdFonts();
		hideEffectSizeLeftThresholdInputs();
		hideEffectSizeRightThresholdFonts();
		hideEffectSizeRightThresholdInputs();
	}
	if (modeSelected === "full") {
		showEffectSizeSelector();
		showEffectSizeFont();
		if (effectSizeFilter === "filter_left") {
			showEffectSizeLeftThresholdFonts();
			showEffectSizeLeftThresholdInputs();
			hideEffectSizeRightThresholdFonts();
			hideEffectSizeRightThresholdInputs();
		}
		if (effectSizeFilter === "filter_right") {
			showEffectSizeRightThresholdFonts();
			showEffectSizeRightThresholdInputs();
			hideEffectSizeLeftThresholdFonts();
			hideEffectSizeLeftThresholdInputs();
		}
		if (effectSizeFilter === "filter_both") {
			showEffectSizeLeftThresholdFonts();
			showEffectSizeLeftThresholdInputs();
			showEffectSizeRightThresholdFonts();
			showEffectSizeRightThresholdInputs();
		}
	}
	if (pValFilter === "filter_none") {
		hidepValInputs()
		hidepValFonts()
	}
	if (pValFilter === "filter_p") {
		showpValInputs()
		showpValFonts()
	}
	return;
}

//p-value Thresholds
function showpValFonts(){
	let fontsToShow = document.querySelectorAll(".pValFont");
	for (let fontToShow of fontsToShow) {
		fontToShow.style.visibility = "visible";
	}
}
function hidepValFonts(){
	let fontsToHide = document.querySelectorAll(".pValFont");
	for (let fontToHide of fontsToHide) {
		fontToHide.style.visibility = "hidden";
	}
}
function hidepValInputs () {
	let inputsToHide = document.getElementsByClassName("thresholdInput pVal");
	for (let inputToHide of inputsToHide) {
		inputToHide.style.visibility = "hidden"; 
	}
	return;
}
function showpValInputs () {
	let inputsToShow = document.getElementsByClassName("thresholdInput pVal");
	for (let inputToShow of inputsToShow) {
		inputToShow.style.visibility = "visible"; 
	}
	return;
}


//Effect Size Thresholds
function hideEffectSizeSelector () {
	let selectorToHide = document.getElementById("filter_select_es");
	selectorToHide.style.visibility = "hidden";
}
function showEffectSizeSelector () {
	let selectorToShow = document.getElementById("filter_select_es");
	selectorToShow.style.visibility = "visible";
}

function hideEffectSizeInputs () {
	let inputsToHide = document.getElementsByClassName("thresholdInput Effect");
	for (let inputToHide of inputsToHide) {
		inputToHide.style.display = "none"; 
	}
	return;
}
function showEffectSizeInputs () {
	let inputsToShow = document.getElementsByClassName("thresholdInput Effect");
	for (let inputToShow of inputsToShow) {
		inputToShow.style.display = "none"; 
	}
	return;
}

function hideEffectSizeFont () {
	let fontToHide = document.getElementById("effectSizeEnablerFont");
	fontToHide.style.visibility = "hidden";
}
function showEffectSizeFont () {
	let fontToShow = document.getElementById("effectSizeEnablerFont");
	fontToShow.style.visibility = "visible";
}
function hideEffectSizeLeftThresholdInputs (){
	let inputsToHide = document.querySelectorAll(".thresholdInput.Effect.Left");
	for (let inputToHide of inputsToHide) {
		inputToHide.style.visibility = "hidden";
	}
}
function showEffectSizeLeftThresholdInputs (){
	let inputsToShow = document.querySelectorAll(".thresholdInput.Effect.Left");
	for (let inputToShow of inputsToShow) {
		inputToShow.style.visibility = "visible";
	}
}
function showEffectSizeRightThresholdInputs (){
	let inputsToShow = document.querySelectorAll(".thresholdInput.Effect.Right");
	for (let inputToShow of inputsToShow) {
		inputToShow.style.visibility = "visible";
	}
}
function hideEffectSizeRightThresholdInputs (){
	let inputsToHide = document.querySelectorAll(".thresholdInput.Effect.Right");
	for (let inputToHide of inputsToHide) {
		inputToHide.style.visibility = "hidden";
	}
}
function hideEffectSizeLeftThresholdFonts (){
	let fontsToHide = document.querySelectorAll(".effectSizeFont.Left");
	for (let fontToHide of fontsToHide) {
		fontToHide.style.visibility = "hidden";
	}
}
function showEffectSizeLeftThresholdFonts (){
	let fontsToShow = document.querySelectorAll(".effectSizeFont.Left");
	for (let fontToShow of fontsToShow) {
		fontToShow.style.visibility = "visible";
	}
}
function hideEffectSizeRightThresholdFonts (){
	let fontsToHide = document.querySelectorAll(".effectSizeFont.Right");
	for (let fontToHide of fontsToHide) {
		fontToHide.style.visibility = "hidden";
	}
}
function showEffectSizeRightThresholdFonts (){
	let fontsToShow = document.querySelectorAll(".effectSizeFont.Right");
	for (let fontToShow of fontsToShow) {
		fontToShow.style.visibility = "visible";
	}
}



document.addEventListener('DOMContentLoaded', function() {

	document.getElementById('div_statistic').style.display = "none";
	document.getElementById('div_exec_buttons').style.display = "none";

	document.getElementById('load_exp_button').addEventListener('click', function(){
		document.getElementById('div_statistic').style.display = "block";
		document.getElementById('div_exec_buttons').style.display = "block";
	},false)

	document.getElementById('exp_select').addEventListener('change', function(){
		document.getElementById('div_statistic').style.display = "none";
		document.getElementById('div_exec_buttons').style.display = "none";
	},false)

	document.getElementById("main_submit").addEventListener('click', function(){
		if (!document.getElementById('accessReportDiv')) {
			newSubmit();
		}
		
	},false)

},false)