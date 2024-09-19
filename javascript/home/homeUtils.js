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


function homeExpLoader () {

	var what = document.getElementById('exp_select').value;
	var host = location.host;
  base_url = base !== "6135251850" ? "http://" + host + "/pathlay/pathlay_users/" + base + "/" + what : "http://" + host + "/pathlay/demo_exps/" + base + "/" + what;

	console.log(base_url);
  var currentTime=getCurrentDateTimeString();
	mrna_url = base_url + ".mrna" + "?" + currentTime;
	urna_url = base_url + ".mirna" + "?" + currentTime;
	meta_url = base_url + ".meta" + "?" + currentTime;
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

	document.getElementById("gene_data").value = mrna_text;
	document.getElementById("urna_data").value = urna_text;
	document.getElementById("prot_data").value = prot_text;
	document.getElementById("meth_data").value = meth_text;
	document.getElementById("meta_data").value = meta_text;
	document.getElementById("chroma_data").value = chroma_text;

	changeSelectionByValue("geneIdTypeSelector",exp_confs[what].geneIdType);
	changeSelectionByValue("protIdTypeSelector",exp_confs[what].protIdType);
	changeSelectionByValue("urnaIdTypeSelector",exp_confs[what].urnaIdType);
	changeSelectionByValue("methIdTypeSelector",exp_confs[what].methIdType);
	changeSelectionByValue("metaIdTypeSelector",exp_confs[what].metaIdType);
	changeSelectionByValue("chromaIdTypeSelector",exp_confs[what].chromaIdType);


  fillExpInfo(exp_confs[what]);
	fillGeneSetup(exp_confs[what]);
	fillProteinSetup(exp_confs[what]);
	fillmiRNASetup(exp_confs[what]);
	fillMethylationSetup(exp_confs[what]);
	fillMetaboliteSetup(exp_confs[what]);
	fillChromatinSetup(exp_confs[what]);
    fillONT(exp_confs[what]);
}
function fillGeneSetup (conf) {
	document.getElementById("gene_id_column").value = conf.gene_id_column;
	document.getElementById("gene_dev_column").value = conf.gene_dev_column;
	document.getElementById("gene_pvalue_column").value = conf.gene_pvalue_column;
}
function fillProteinSetup (conf) {
	document.getElementById("prot_id_column").value = conf.prot_id_column;
	document.getElementById("prot_dev_column").value = conf.prot_dev_column;
	document.getElementById("prot_pvalue_column").value = conf.prot_pvalue_column;
}
function fillmiRNASetup (conf) {
	document.getElementById("urna_id_column").value = conf.urna_id_column;
	document.getElementById("urna_dev_column").value = conf.urna_dev_column;
	document.getElementById("urna_pvalue_column").value = conf.urna_pvalue_column;
}
function fillMethylationSetup (conf) {
	document.getElementById("meth_id_column").value = conf.meth_id_column;
	document.getElementById("meth_dev_column").value = conf.meth_dev_column;
	document.getElementById("meth_pvalue_column").value = conf.meth_pvalue_column;
}
function fillMetaboliteSetup (conf) {
	document.getElementById("meta_id_column").value = conf.meta_id_column;
	document.getElementById("meta_dev_column").value = conf.meta_dev_column;
	document.getElementById("meta_pvalue_column").value = conf.meta_pvalue_column;
}
function fillChromatinSetup (conf) {
	document.getElementById("chroma_id_column").value = conf.chroma_id_column;
	document.getElementById("chroma_dev_column").value = conf.chroma_dev_column;
	document.getElementById("chroma_pvalue_column").value = conf.chroma_pvalue_column;
}
function fillExpInfo (conf) {
	document.getElementById("exp_name_input_text").value = conf.exp_name_input_text;
	document.getElementById("exp_comment_input_text").value = conf.exp_comment_input_text;
	if (document.getElementById("exp_organism_input_text")) {
		document.getElementById("exp_organism_input_text").value = conf.organism;
	}
	if (document.getElementById("exp_organism_selector")) {
		changeSelectionByValue("exp_organism_selector",conf.organism);
	}
}
function fillONT (conf) {
    if (document.getElementById("exp_organism_selector")) {
		//document.getElementById("exp_organism_selector").value = conf.organism;
		document.getElementById("ont_display_"+conf.organism).style.display = "block";
		document.getElementById("ont_pool_"+conf.organism).style.display = "block";
	}

	var onts_to_reset = document.getElementsByClassName('ont_rm_button');

	for (i = 0; i < onts_to_reset.length; i++) {
		onts_to_reset[i].click();
	}

	if (onto_text != '' && document.getElementById('ont_pool_'+conf.organism)) {
		const onts = onto_text.split("\n");
		var i = 0;
		for (i = 0;i < onts.length - 1 ; i++) {
			if (document.getElementById(onts[i]+"_"+conf.organism).childNodes[4]) {
				document.getElementById(onts[i]+"_"+conf.organism).childNodes[4].click();
			}
		}
	}
}
function resetONT() {
	var onts_to_reset = document.getElementsByClassName('ont_rm_button');

	for (i = 0; i < onts_to_reset.length; i++) {
		onts_to_reset[i].click();
	}
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
		alert("No"+file);
		res = '';
	} else {
		//console.log("found file");
		res = req.responseText;
	}
	return res;
}
function submitForm (task) {
	var input = document.getElementById('ope');
	input.setAttribute("value", task);
	if (task == 'delete') {
		var r = window.confirm("You are about to delete exp"+document.getElementById('exp_select').value);
		if (r == false) {
			return;
		}
	}
	if (task == 'save') {
		var r = window.confirm("You are about to update exp"+document.getElementById('exp_select').value);
		if (r == false) {
			return;
		}
	}
	if (task == 'add') {
		var r = window.confirm("You are about to add an exp");
		if (r == false) {
			return;
		}
	}
	if (task == 'upload') {
		var r = window.confirm("You are about to upload the file "+document.getElementById('file').value+". Please review the file index before going on...");
		if (r == false) {
			return;
		}
		document.getElementById('main').enctype="multipart/form-data";
	}
	if (task == 'download' || task == 'download_home' || task == 'download_pool') {
		document.getElementById('main').target="new";
	} else {
		document.getElementById('main').target="_self";
	}
	document.getElementById('main').submit();
}

function showhide() {
	sel = document.getElementById("datatype").value;
	document.getElementById("div_setup_gene").style.display="none";
	document.getElementById("div_setup_urna").style.display="none";
	document.getElementById("div_setup_meta").style.display="none";
	document.getElementById("div_setup_meth").style.display="none";
	document.getElementById("div_setup_prot").style.display="none";
	document.getElementById("div_setup_chroma").style.display="none";
    document.getElementById("gene_data").style.display="none";
    document.getElementById("urna_data").style.display="none";
    document.getElementById("meta_data").style.display="none";
	document.getElementById("meth_data").style.display="none";
	document.getElementById("prot_data").style.display="none";
	document.getElementById("chroma_data").style.display="none";
	document.getElementById("div_setup_"+sel).style.display="block";
    document.getElementById(sel+"_data").style.display="block";
}

function toggleThresholds(choiceValue) {
	
	let divsToHide = document.getElementsByClassName("thresholdInputDiv");
	for (let divToHide of divsToHide) {
		divToHide.style.display = "none";
	}
	document.getElementById(choiceValue + "ThresholdInputDiv").style.display = "block";;
}



function searchONT(event) {

    var organismSelected = document.getElementById("exp_organism_selector").selectedOptions[0].value;

    var ulToSearchId = "ont_ul_" + organismSelected;
    var poolToSearchId = "ont_pool_" + organismSelected;    
    var filter = document.getElementById("searchBarONT").value.toUpperCase();

    var liCollectionLeft = document.getElementById(ulToSearchId).getElementsByClassName("ont_li");
    var liCollectionRight = document.getElementById(poolToSearchId).getElementsByClassName("ont_li_pool");

    if (event.keycode || event.charCode) {
        var key = event.keyCode || event.charCode;
    }
    

    if(key == 8 || key == 46) {
        for (i = 0; i < liCollectionLeft.length; i++) {
            if (liCollectionLeft[i].style.display === "" || liCollectionLeft[i].style.display === "none") {
                continue;
            }
            let innerText = liCollectionLeft[i].innerText;
            if (innerText.toUpperCase().indexOf(filter) > -1) {
                liCollectionLeft[i].style.display = "";
            } else {
                liCollectionLeft[i].style.display = "none";
            }
        }
        for (i = 0; i < liCollectionRight.length; i++) {
            if (liCollectionRight[i].style.display === "" || liCollectionRight[i].style.display === "none") {
                continue;
            }
            let innerText = liCollectionRight[i].innerText;
            
            if (innerText.toUpperCase().indexOf(filter) > -1) {
                liCollectionRight[i].style.display = "";
            } else {
                liCollectionRight[i].style.display = "none";
            }
        }
        return;
    }


    for (i = 0; i < liCollectionLeft.length; i++) {
        let innerText = liCollectionLeft[i].innerText;
        if (innerText.toUpperCase().indexOf(filter) > -1) {
            liCollectionLeft[i].style.display = "";
        } else {
            liCollectionLeft[i].style.display = "none";
        }
    }

    for (i = 0; i < liCollectionRight.length; i++) {
        let innerText = liCollectionRight[i].innerText;
        
        if (innerText.toUpperCase().indexOf(filter) > -1) {
            liCollectionRight[i].style.display = "";
        } else {
            liCollectionRight[i].style.display = "none";
        }
    }
}

function resetSearchONT() {

    document.getElementById("searchBarONT").value = "";
    searchONT("");
}

function resetFields() {
	let dataTypes = [
		'gene',
		'prot',
		'urna',
		'chroma',
		'meth',
		'meta'
	];
	for (let dataType of dataTypes) {
		document.getElementById(`${dataType}_data`).value = "";
		document.getElementById(`${dataType}_id_column`).value = "";
		document.getElementById(`${dataType}_dev_column`).value = "";
		document.getElementById(`${dataType}_pvalue_column`).value = "";

	}
	resetSearchONT();
	resetONT();
}

const addbtns = document.getElementsByClassName("ul_add_button");
var i = 0;

function getNewExpId() {
	let expsInHome = Object.keys(exp_confs);
	var expRegex = new RegExp(/exp(.+?)$/);
	let newNum = 0;
	let currentNum;
	for (let expId of expsInHome) {
		if (expRegex.test(expId) == true) {
			currentNum = Number(expRegex.exec(expId)[1]);
			if (currentNum > newNum) {
				newNum = currentNum ;
			}
		}
	}
	newNum++; 
	let newExpId = `exp${newNum}`;
	return newExpId;
}
function addNewExpToSelector(expId) {
	let newOption = document.createElement('option');
	newOption.value = expId;
	newOption.label = expId;
	document.getElementById('exp_select').appendChild(newOption);
}


document.addEventListener("DOMContentLoaded", function() {
	console.log('DOMContentLoaded -> ADDING SAVED ONTS TO POOL');
	for (i = 0; i < addbtns.length; i++) {

		addbtns[i].addEventListener("click",add_to_ont_pool);
	}




	document.getElementById('div_main').style.display = "none";
	document.getElementById('div_ont').style.display = "none";
	document.getElementById('div_upload').style.display = "none";
	document.getElementById('expSaveButton').style.visibility = "hidden";

	document.getElementById('addNewExp').addEventListener('click', function(){
		resetFields();
		let newExpId = getNewExpId();
		addNewExpToSelector(newExpId);
		exp_confs[newExpId] = {};
		document.getElementById('exp_select').selectedIndex = (document.getElementById('exp_select').options.length) - 1;
		var changeEvent = new Event('change');
		document.getElementById('exp_select').dispatchEvent(changeEvent);
	},false)
	document.getElementById('expLoaderButton').addEventListener('click', function(){
		document.getElementById('div_main').style.display = "block";
		document.getElementById('div_ont').style.display = "block";
		document.getElementById('div_upload').style.display = "block";
		document.getElementById('expSaveButton').style.visibility = "visible";
	},false)

	document.getElementById('exp_select').addEventListener('change', function(){
		document.getElementById('div_main').style.display = "none";
		document.getElementById('div_ont').style.display = "none";
		document.getElementById('div_upload').style.display = "none";
		document.getElementById('expSaveButton').style.visibility = "hidden";
	},false)

})






function add_to_ont_pool() {
	console.log('add_to_ont_pool()');
	const organism_regex = new RegExp(/_(.+?)$/);
	var lid = this.parentElement.id;
	if (organism_regex.test(lid) === true) {
		organism = organism_regex.exec(lid)[1];
	}

	document.getElementById("ont_ul_pool_"+organism).appendChild(this.parentElement);
	this.parentElement.className = "ont_li_pool";
	this.parentElement.classList[0].value = "ont_li_pool";
	//document.getElementById(this.parentElement.textContent).name = "onts_selected";
	document.getElementById(this.parentElement.id).childNodes[3].name = "onts_selected_"+organism;
	console.log(document.getElementById(this.parentElement.id));
	this.className = "ont_rm_button";
	this.classList[0].value = "ont_rm_button";
	this.value = "-";
	this.removeEventListener("click",add_to_ont_pool);
	this.addEventListener("click",remove_from_ont_pool);
}

function remove_from_ont_pool() {
	console.log('remove_from_ont_pool()');
	console.log('add_to_ont_pool()');
	const organism_regex = new RegExp(/_(.+?)$/);
	var lid = this.parentElement.id;
	if (organism_regex.test(lid) === true) {
		organism = organism_regex.exec(lid)[1];
	}


	document.getElementById("ont_ul_"+organism).appendChild(this.parentElement);
	this.parentElement.className = "ont_li";
	this.parentElement.classList[0].value = "ont_li";
	//document.getElementById(this.parentElement.textContent).name = "onts";
	document.getElementById(this.parentElement.id).childNodes[3].name = "onts";
	console.log(document.getElementById(this.parentElement.id));
	this.className = "ont_add_button";
	this.classList[0].value = "ont_add_button";
	this.value = "+";
	this.removeEventListener("click",remove_from_ont_pool);
	this.addEventListener("click",add_to_ont_pool);

}

function toggleONTs(organism) {

	console.log(organism);
	/* Reset Search Box */
	resetSearchONT();


	var displays = document.getElementsByClassName("ont_display");
	var pools = document.getElementsByClassName("ont_pool");

	for (let i = 0;i < displays.length;i++) {
		displays[i].style.display = "none";
		pools[i].style.display = "none";
	}

	document.getElementById("ont_display_"+organism).style.display = "block";
	document.getElementById("ont_pool_"+organism).style.display = "block";
}

function changeSelectionByValue(selectorId,value) {
    document.querySelector('#'+selectorId).value = value;
}
function changeSelectionByValue(selectorId,value) {
    document.querySelector('#'+selectorId).value = value;
}
