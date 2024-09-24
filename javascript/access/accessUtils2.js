// global variables & onload async calls
var expConf = {};
var omicToTitle = {
	gene: 'Genes',
	prot: 'Proteins',
	urna: 'miRNAs',
	meth: 'Methylations',
	chroma: 'Chromatin Statuses',
	meta: 'Metabolites'
};
var checkConf = {
	gene:{},
	prot:{},
	urna:{},
	meth:{},
	chroma:{},
	meta:{}
};
var expData = {};
var expOnts = [];
var filterPreview = {
	gene:{},
	prot:{},
	urna:{},
	meth:{},
	chroma:{},
	meta:{}
};

// configurations on interface
var currentConf = {
	enabledOmics: {
		gene: undefined,
		prot: undefined,
		urna: undefined,
		meth: undefined,
		chroma: undefined,
		meta: undefined
	},
	enabledFETs: {
		gene: undefined,
		prot: undefined,
		urna: undefined,
		meth: undefined,
		chroma: undefined,
		meta: undefined
	},
	mapDBSelected: undefined,
	omicConfs: {
		gene: {},
		prot: {},
		urna: {},
		meth: {},
		chroma: {},
		meta: {},
	},
	updateAll: function() {
		["gene","prot","urna","meth","chroma","meta"].forEach((omic) => {
			this.updateEnabledOmics(omic);
			this.updateEnabledThresholds(omic);
			this.updateThresholdValues(omic);
			this.updateEnabledIdOnly(omic);
			this.updateEnabledFETs(omic);
		});
		["urna","meth","chroma"].forEach((omic) => {
			this.updateEnabledNoDeLoaders(omic);
			this.updateEnabledNoDeIdOnlyLoaders(omic);
		});
		["gene","prot"].forEach((omic) => {
			this.updateEnabledTFs(omic);
			this.updateEnabledIdOnlyTFs(omic);
			this.updateEnabledNoDeTFsLoaders(omic);
			this.updateEnabledNoDeIdOnlyTFsLoaders(omic);
		});
		
		this.updateSelectedMapDB();

		this.updateEnabledFETExtras();
	},
	updateEnabledOmics: function(omic) {
		this.enabledOmics[omic] = document.getElementById(`enable${omic}`).checked;
	},
	updateSelectedMapDB: function() {
		this.mapDBSelected = document.getElementById('maps_db_select').selectedOptions[0].value;
	},
	updateThresholdValues: function(omic) {
		this.omicConfs[omic].esLeftThr = document.getElementById(`${omic}LeftEffectSizeThreshold`).value;
		this.omicConfs[omic].esRightThr = document.getElementById(`${omic}RightEffectSizeThreshold`).value;
		this.omicConfs[omic].pValThr = document.getElementById(`${omic}pValThreshold`).value;
	},
	updateEnabledThresholds: function(omic) {
		this.omicConfs[omic].esLeftEnabled = document.getElementById(`${omic}LeftEffectSizeCheck`).checked;
		this.omicConfs[omic].esRightEnabled = document.getElementById(`${omic}RightEffectSizeCheck`).checked;
		this.omicConfs[omic].pValEnabled = document.getElementById(`${omic}pValCheck`).checked;
	},
	updateEnabledIdOnly: function(omic) {
		this.omicConfs[omic].idOnlyEnabled = document.getElementById(`${omic}IdOnlyCheck`).checked;
	},
	updateEnabledNoDeLoaders: function(omic) {
		this.omicConfs[omic].noDeLoadEnabled = document.getElementById(`nodeg_select_${omic}`).checked;
	},
	updateEnabledNoDeIdOnlyLoaders: function(omic) {
		this.omicConfs[omic].noDeLoadIdOnlyEnabled = document.getElementById(`${omic}NoDEFromIdOnlyCheck`).checked;
	},
	updateEnabledTFs: function(omic) {
		this.omicConfs[omic].tfEnabled = document.getElementById(`enabletfs_${omic}`).checked;
	},
	updateEnabledIdOnlyTFs: function(omic) {
		this.omicConfs[omic].tfIdOnlyEnabled = document.getElementById(`enabletfsIdOnly_${omic}`).checked;
	},
	updateEnabledNoDeTFsLoaders: function (omic) {
		this.omicConfs[omic].tfNoDeEnabled = document.getElementById(`nodeg_select_tf_${omic}`).checked;
	},
	updateEnabledNoDeIdOnlyTFsLoaders: function (omic) {
		this.omicConfs[omic].tfNoDeIdOnlyEnabled = document.getElementById(`tfsNoDEFromIdOnlyCheck_${omic}`).checked;
	},
	updateEnabledFETs: function (omic) {
		this.enabledFETs[omic] = document.getElementById(`${omic}FETEnabled`).checked;
		let statsEnabled = 0;
		['gene','prot','urna','meth','chroma','meta'].forEach((om) => {
			statsEnabled += this.enabledFETs[om] ? 1 : 0;
		});
		this.statisticSelect = statsEnabled > 0 ? 'FET' : 'none';
	},
	updateEnabledFETExtras: function () {
		this.enabledFETPooling = document.getElementById(`FETPooling`).checked ? true : false;
		this.enabledFETIntersect = document.getElementById(`FETIntersect`).checked  ? true : false;
	},


};


// check for errors in the interface

var checkInterface = {
	submitEnabled : undefined,
	omicConfs : {
		gene: {},
		prot: {},
		urna: {},
		meth: {},
		chroma: {},
		meta: {},
	},
	checkThrInputs: function(omic) {
		["LeftEffectSize","RightEffectSize","pVal"].forEach((type,i) =>{

			let input =
				i == 0 ? "esLeftThr"
				: i == 1 ? "esRightThr"
				: "pValThr";
			let enabled = 
				i == 0 ? "esLeftEnabled"
				: i == 1 ? "esRightEnabled"
				: "pValEnabled";
			this.omicConfs[omic][type] = 
				!currentConf.omicConfs[omic][input] && currentConf.omicConfs[omic][enabled] ? "error"
				: currentConf.omicConfs[omic][input] && currentConf.omicConfs[omic][enabled] ? "ok" 
				: "disable";

		});
	},
	handleThrInputs: function(omic) {
		["LeftEffectSize","RightEffectSize","pVal"].forEach((type,i) => {
			console.log(this.omicConfs[omic][type]);
			document.getElementById(`${omic}${type}Threshold`).disabled = 
				this.omicConfs[omic][type] === "disable" ? true 
				: false;
			document.getElementById(`${omic}${type}Threshold`).style.backgroundColor = 
				this.omicConfs[omic][type] === "error" ? "#d15555" 
				: "white";	
		});
	},
	handleSubmit: function() {
		let errorCounter = 0;
		let enabledOmics = 0;

		["gene","prot","urna","meth","chroma","meta"].forEach((omic) => {
			if (currentConf.enabledOmics[omic]) {
				enabledOmics += 1;
				["LeftEffectSize","RightEffectSize","pVal"].forEach((type,i) => {
					errorCounter += this.omicConfs[omic][type] === "error" ? 1 : 0; 
				})
			}
		});
		console.log('Errors:' + errorCounter);
		//disable submit here 
		document.getElementById('submit').style.color = errorCounter > 0 || enabledOmics === 0 ? 'red' : 'white';
		document.getElementById('submit').style.pointerEvents = errorCounter > 0 || enabledOmics === 0 ? 'none' : '';
	},
	handleConfEnabled: function() {
		["gene","prot","urna","meth","chroma","meta"].forEach((omic) => {
			["Thr","IdOnly","Tfs","NoDe","FET"].forEach((type) => {
				if (document.getElementById(`${omic}${type}Container`)) {
					!currentConf.enabledOmics[omic] ?	disableInputs(`${omic}${type}Container`,true) :
					disableInputs(`${omic}${type}Container`,false);
				}
			});
		});
	},
	handleFETEnabled: function() {
		let statEnabled = 0;
		["gene","prot","urna","meth","chroma","meta"].forEach((omic) => {
			statEnabled += currentConf.enabledFETs[omic] ? 1 : 0;
		});
		console.log(statEnabled);
		let disable = statEnabled === 0 ? true : false;
		disableInputs("FETExtraFeatures",disable);
	},
	handleNoDeEnabled: function() {
		['urna','meth','chroma'].forEach((omic) => {
			document.getElementById(`nodeg_select_${omic}`).checked = 
				!currentConf.enabledOmics['gene'] && !currentConf.enabledOmics['prot'] ? true 
				: currentConf.omicConfs[omic].noDeLoadEnabled;
			currentConf.updateEnabledNoDeLoaders(omic);
		})
	},
	handleFETPooling: function() {
		let enabledStats = 0;
		['gene','prot','urna','meth','chroma'].forEach((omic) => {
			enabledStats += document.getElementById(`${omic}FETEnabled`).checked && !document.getElementById(`${omic}FETEnabled`).disabled ? 1 : 0;
		})
		let disable = enabledStats > 0 ? false : true;
		disableInputs('FETPoolingLabel',disable);
	}
};

// onload init
document.addEventListener("DOMContentLoaded", async function() {
	try {
		// console.log("width" + window.innerWidth + "px");
		// console.log("height" + window.innerHeight + "px");

		checkConf = await checkConfiguration();
		console.log(checkConf)
		expConf = await loadExpConf();
		[expData,expOnts] = await loadExpData();
		lastConf = await loadLastConf();
		fillExpGenerics(expConf);
		loadPageContent(expConf.organism);
		fillFETExtras(lastConf);
		["gene","prot","urna","meth","chroma","meta"].forEach((omic) => {
			fillDataCheckBoxes(lastConf,omic);
			fillExpThresholds(lastConf,omic);
			fillFETCheckBoxes(lastConf,omic);
		});
		["gene","prot"].forEach((omic) => {
			fillTfsCheckBoxes(lastConf,omic);
		});
		["urna","meth","chroma"].forEach((omic) => {
			fillNoDeCheckBoxes(lastConf,omic);
		});
		currentConf.updateAll();
		["gene","prot","urna","meth","chroma","meta"].forEach((omic) => {
			filterData(omic);
			displayPreview(omic);
			checkInterface.handleThrInputs(omic);
		});
		
		checkInterface.handleConfEnabled();
		checkInterface.handleSubmit();
		checkInterface.handleFETEnabled();
		checkInterface.handleFETPooling();

		// disable for missing datasets
		["gene","prot","urna","meth","chroma","meta"].forEach((omic) => {
			if (checkConf[omic].idColumn === 0 || !checkConf[omic].idColumn) {
				disableInputs(`enable${omic}Label`,true);
			}
		});

	} catch (error) {
		console.error('Error loading experiment configuration:', error);
	}
})


// request functions
async function performAction(action, exp) {
	console.log(`action: ${action} exp: ${exp}`);
	const sid = getQueryParam('sid');

	if (action === "deleteExp") {
		const formData = new FormData();
		formData.append('action', action);
		formData.append('sid', sid);
		formData.append('exp', exp);
		try {
			const { result, response } = await postRequest("../cgi-bin/pathlayHomeActions.pl?action=deleteExp", formData);
			window.location.reload();
			return response;
		} catch (error) {
			alert(error.message);
			throw error;
		}
	}

	if (action === "updateLastConf") {
		const formData = new FormData();
		formData.append('action', action);
		formData.append('sid', sid);
		formData.append('exp', exp);
		formData.append('conf',JSON.stringify(currentConf));
		console.log(JSON.stringify(currentConf.omicConfs));
		try {
			const { result, response } = await postRequest("../cgi-bin/pathlayAccessActions.pl?action=updateLastConf", formData);
			alert(result);
			return response;
		} catch (error) {
			alert(error.message);
			throw error;
		}
	}

	if (action === "downloadExp") {
		const query = `../cgi-bin/pathlayHomeActions.pl?action=downloadExp&sid=${sid}&exp=${exp}`;
		getRequestForDownload(query);
	}

	if (action === "editConf") {
		const baseUrl = `${window.location.protocol}//${window.location.host}${window.location.pathname}`;
		window.location.href = `${baseUrl}?sid=${sid}&mode=conf&exp=${exp}`;
	}
	
	if (action === "uploadOmicPack") {
		if (uploadInProgress) return;  // Exit if upload is already in progress
		uploadInProgress = true;  // Set the guard

		console.log("uploadOmicPack");

		const formData = new FormData();
		formData.append('action', 'uploadOmicPack');
		formData.append('sid', getQueryParam('sid'));
		formData.append('exp', getQueryParam('exp'));
		formData.append('omic', getSelectorValue('omicsSelector'));
		const fileInput = document.getElementById(`${getSelectorValue('omicsSelector')}PackInputOmic`);
		const fileSelected = new Promise((resolve) => {
			fileInput.addEventListener('change', (event) => {
				resolve(event.target.files[0]);
				console.log(event.target.files[0]);
			}, { once: true });
		});
		const file = await fileSelected;
		if (file) {
			formData.append('file', file);
			try {
				const { result, response } = await postRequest('../cgi-bin/pathlayHomeActions.pl?action=uploadOmicPack', formData);
				if (JSON.parse(result).status === 'error') {
					alert(JSON.parse(result).message);
					return
				} else {
					document.getElementById(`${getSelectorValue('omicsSelector')}Data`).value = JSON.parse(result).content;
				}
				return response;
			} catch (error) {
				alert(error.message);
				throw error;
			} finally {
				uploadInProgress = false;  
			}
		} else {
			uploadInProgress = false;  
		}
	}
	if (action) {

	}
}
async function getRequest(url) {
  return new Promise((resolve, reject) => {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
      if (this.readyState !== 4) return;

      if (this.status >= 200 && this.status < 300) {
        try {
          const response = JSON.parse(this.responseText);
          resolve(response);
        } catch (e) {
          console.error(e);
          reject(e);
        }
      } else {
        reject(new Error('Request failed with status code ' + this.status));
      }
    };

    xhttp.open("GET", url, true);
    xhttp.send();
  });
}
async function postRequest(query, formData, reloadPage) {
	return new Promise(async (resolve, reject) => {
			try {
					const response = await fetch(query, {
							method: 'POST',
							body: formData
					});

					if (response.ok) {
							const result = await response.text();
							resolve({ result, response });
							if (reloadPage) {
								window.location.reload();
							}
					} else {
							const errorText = await response.text();
							reject(new Error(`File upload failed: ${errorText}`));
					}
			} catch (error) {
					console.error('Error:', error);
					reject(new Error('An error occurred during file upload.'));
			}
	});
}

function postForm(actionURL, params) {
	// Create a form element
	var form = document.createElement("form");

	// Set the form attributes
	form.setAttribute("method", "POST");
	form.setAttribute("action", actionURL);

	// Function to create hidden inputs for nested objects
	function appendInput(name, value) {
		var input = document.createElement("input");
		input.setAttribute("type", "hidden");
		input.setAttribute("name", name);
		input.setAttribute("value", value);
		form.appendChild(input);
	}



	function processParams() {
		['gene','prot','urna','meth','chroma','meta'].forEach((omic) => {
			appendInput(`enable${omic}`, currentConf.enabledOmics[omic]);
			if (currentConf.enabledOmics[omic]) {
				appendInput(`${omic}LeftEffectSizeCheck`,currentConf.omicConfs[omic].esLeftEnabled);
				appendInput(`${omic}RightEffectSizeCheck`,currentConf.omicConfs[omic].esRightEnabled);
				appendInput(`${omic}pValCheck`,currentConf.omicConfs[omic].pValEnabled);
				appendInput(`${omic}IdOnlyCheck`,currentConf.omicConfs[omic].idOnlyEnabled);
				appendInput(`${omic}LeftThreshold`,currentConf.omicConfs[omic].esLeftThr);
				appendInput(`${omic}RightThreshold`,currentConf.omicConfs[omic].esRightThr);
				appendInput(`${omic}pValThreshold`,currentConf.omicConfs[omic].pValThr);
				appendInput(`${omic}_data`,expData[omic].textData);
				appendInput(`${omic}_id_column`,expConf[omic].idColumn);
				appendInput(`${omic}_dev_column`,expConf[omic].devColumn);
				appendInput(`${omic}_pvalue_column`,expConf[omic].pvalueColumn);
				appendInput(`${omic}FETEnabled`,currentConf.enabledFETs[omic]);
				// appendInput(`${omic}FETEnabled`,currentConf.enabledFETs[omic]);
				appendInput(`${omic}IdType`,expConf[omic].IdType)
			}
		});
		['gene','prot'].forEach((omic) => {
			if (currentConf.enabledOmics[omic]) {
				appendInput(`enabletfs_${omic}`,currentConf.omicConfs[omic].tfEnabled);
				appendInput(`nodeg_select_tf_${omic}`,currentConf.omicConfs[omic].tfNoDeEnabled);
				appendInput(`enabletfsIdOnly_${omic}`,currentConf.omicConfs[omic].tfIdOnlyEnabled);
				appendInput(`tfsNoDEFromIdOnlyCheck_${omic}`,currentConf.omicConfs[omic].tfNoDeIdOnlyEnabled);
			}
		});
		['urna','meth','chroma'].forEach((omic) => {
			if (currentConf.enabledOmics[omic]) {
				appendInput(`nodeg_select_${omic}`,currentConf.omicConfs[omic].noDeLoadEnabled);
				appendInput(`${omic}NoDEFromIdOnlyCheck`,currentConf.omicConfs[omic].noDeLoadIdOnlyEnabled);
			}
		});
		appendInput('statistic_select',currentConf.statisticSelect);
		appendInput('FETIntersect',currentConf.enabledFETIntersect);
		if (!document.getElementById('FETPooling').disabled) {
			appendInput('FETPooling',currentConf.enabledFETPooling);
		}
		appendInput('org',expConf.organism);
		appendInput('sid',getQueryParam('sid'));
		appendInput('exp_select',getQueryParam('exp'));
		appendInput('maps_db_select',currentConf.mapDBSelected);
	}

	// Process all parameters (including nested ones)
	// processParams('', params);
	processParams();
	

	// Append the form to the body
	document.body.appendChild(form);

	// Submit the form
	form.submit();

	// Remove the form after submission (optional)
	// document.body.removeChild(form);
}




function loadPageContent(organism) {
	console.log(expConf)
	let containerRows = document.getElementsByClassName('container-row');
	containerRows[2].innerHTML = '';
	containerRows[2].style.alignItems = 'flex-start';

	let box = document.createElement('div');
	box.style.display = "flex";
	box.style.flexDirection = "column";
	// box.style.margin = "20px";
	box.style.width = "20vw";

	let box2 = box.cloneNode();
	box2.style.alignItems = 'center';
	box2.style.removeProperty('width');
	// let submitButton = document.createElement('input');
	// submitButton.type = 'button';
	// submitButton.value = 'Submit';

	box2.appendChild(previewBoxPackager());
	box2.appendChild(button('submit','Submit','start',async function submit() {
		let url = `../cgi-bin/pathlay.pl?sid=${getQueryParam('sid')}&exp=${getQueryParam('exp')}`;
			//update last conf
		let resp = await performAction('updateLastConf', getQueryParam('exp'));
		if (resp) {
			postForm(url,currentConf);
		}
	}));



	// box.appendChild(editMapsDbBoxPackager());
	box.appendChild(editFETBoxPackager());

	containerRows[1].appendChild(editMapsDbBoxPackager());
	containerRows[2].appendChild(editConfBoxPackager(organism));
	containerRows[2].appendChild(box);
	containerRows[2].appendChild(box2);

}
async function loadExpConf() {
	try {
		const sid = getQueryParam('sid');
		const exp = getQueryParam('exp');
		const response = await getRequest(`pathlayHomeActions.pl?action=loadExpConf&exp=${exp}&sid=${sid}`);
		console.log('Conf received:', response);
		return(response.conf)
	} catch (error) {
		console.error('Error:', error);
	}
}
async function loadExpData() {
	try {
		const sid = getQueryParam('sid');
		const exp = getQueryParam('exp');
		const response = await getRequest(`pathlayAccessActions.pl?action=loadExpData&exp=${exp}&sid=${sid}`);
		console.log('Exp Data received:', response);
		let data = convertValuesToBoolean(response.data,["isIdOnly","haspVal","hasEs"]);
		return([data,response.onts])
	} catch (error) {
		console.error('Error:', error);
	}
}
async function loadLastConf() {
	try {
		const sid = getQueryParam('sid');
		const exp = getQueryParam('exp');
		const response = await getRequest(`pathlayAccessActions.pl?action=loadLastConf&exp=${exp}&sid=${sid}`);
		console.log('Last Exp Conf received:', response);
		return(convertValuesToBoolean(response.conf,["FETPooling","FETIntersect","enabledFET","enabled","RightEffectSizeCheck","LeftEffectSizeCheck","IdOnlyCheck","pValCheck","enabletfsIdOnly","enabletfs","nodeg_select_tf","tfsNoDEFromIdOnlyCheck","NoDEFromIdOnlyCheck","nodeg_select"]))
	} catch (error) {
		console.error('Error:', error);
	}
}
async function checkConfiguration() {
	return new Promise(async (resolve, reject) => {
		try {
			const expId = getQueryParam('exp');
			const sid = getQueryParam('sid');
			const response = await getRequest(`pathlayAccessActions.pl?action=checkConf&exp=${expId}&sid=${sid}`);
			console.log('Conf received:', response);
			resolve(response.checks);
		} catch (error) {
			console.error('Error:', error);
			reject(error);
		}
	});
}


// interface packagers

function previewBoxPackager() {
	let container = document.createElement('div');
	container.className = 'conf-container';

	let rows = [];
	[0,1,2,3,4,5,6].forEach(() => {
		let containerRow = document.createElement('div');
		containerRow.className = 'conf-row preview-box';
		containerRow.style.display = "none";
		rows.push(containerRow);
	});
	["gene","prot","urna","meth","chroma","meta"].forEach((omic,i) => {
		rows[i+1].id = `${omic}PreviewRow`;
		rows[i+1].appendChild(previewDiv(omic));
	});
	rows.forEach(row =>{
		container.appendChild(row);
	});
	let titleSpan = document.createElement('span');
	titleSpan.innerText = 'Preview';
	rows[0].appendChild(titleSpan);
	rows[0].id = "titlePreviewRow";
	rows[0].style.display = "flex";
	rows[1].style.display = "flex";
	return(container);

}
function previewDiv(omic) {
	let container = document.createElement('div');
	container.className = 'conf-container';
	container.id = `${omic}PreviewBox`;
	let title = document.createElement('span');
	title.innerText = omicToTitle[omic];

	let rows = [];
	[0,1,2,3,4].forEach(() => {
		let containerRow = document.createElement('div');
		containerRow.className = 'conf-row preview-row';
		rows.push(containerRow);
	});

	rows[0].appendChild(title);
	let ids = ["Input","EsFiltered","pValFiltered","Output"];
	["Input:","Filetered out by Effect Size:","Filetered out by p-value:","Output:"].forEach((text,i) => {
		let span = document.createElement('span');
		span.id = `${omic}${ids[i]}Span`;
		span.innerText = text;
		rows[i+1].appendChild(span);
	})

	rows.forEach(row =>{
		container.appendChild(row);
	})

	return(container);
}

function editMapsDbBoxPackager() {
	console.log("maps")
	let container = document.createElement('div');
	container.className = 'conf-container';
	container.style.width = "90%";

	let rows = [];
	[0,1].forEach(() => {
		let containerRow = document.createElement('div');
		containerRow.className = 'conf-row';
		rows.push(containerRow);
	});
	

	// select maps
	let selectContainer = document.createElement('div');
	selectContainer.className = 'select-container';
	let span = document.createElement('span');
	span.innerHTML = 'Select Maps DB';
	let select = document.createElement('select');
	select.id = 'maps_db_select';
	["kegg","wikipathways"].forEach((db) => {
		let option = document.createElement('option');
		option.value = db;
		option.innerText = db === "kegg" ? "KEGG" : "WikiPathways";
		option.name = db;
		select.appendChild(option);
	});
	selectContainer.appendChild(select);
	// add events on change 
	select.addEventListener('change', async function() {
		try {
			currentConf.updateSelectedMapDB();
		} catch (error) {
			console.log(error)
		}
	});

	// datasets enabler
	["gene","prot","urna","meth","chroma","meta"].forEach((omic) => {
		let div = document.createElement("div");
		div.style.display = 'flex';
		div.style.alignItems = 'center';
		div.style.justifyContent = 'center';
		div.style.flexDirection = 'column';
		let switchLabel = radiusSwitch(`enable${omic}`,`enable${omic}`);
		switchLabel.id = `enable${omic}Label`;
		// add events on change 
		switchLabel.addEventListener('change', async function() {
			try {
				currentConf.updateEnabledOmics(omic);
				checkInterface.handleConfEnabled(omic);
				checkInterface.handleFETPooling();
				checkInterface.handleSubmit();
			} catch (error) {
				console.log(error)
			}
		});

		let titleSpan = document.createElement('span');
		titleSpan.className = 'tfs-title-span';
		titleSpan.innerText = omicToTitle[omic];
		div.appendChild(titleSpan);
		div.appendChild(switchLabel);
		rows[1].appendChild(div);
	});

	// laod on rows
	rows[0].appendChild(span);
	rows[0].appendChild(selectContainer);
	rows.forEach(row =>{
		container.appendChild(row);
	})
	return(container)
} 

function editFETBoxPackager() {
	let container = document.createElement('div');
	container.className = 'conf-container';
	container.style.width = "auto";

	let rows = [];
	[0,1,2,3,4].forEach(() => {
		let containerRow = document.createElement('div');
		containerRow.className = 'conf-row';
		rows.push(containerRow);
	});
	let containerTitle = document.createElement('span');
	containerTitle.innerText = `Fisher's Exact Test Setting`;
	rows[0].appendChild(containerTitle);

	let titleSpan = document.createElement('span');
	titleSpan.className = 'fet-title-span';
	titleSpan.innerText = `Enable for:`;
	rows[1].appendChild(titleSpan);
	rows[1].style.justifyContent = "flex-start";

	["gene","prot","urna","meth","chroma","meta"].forEach((omic) => {
		let fetContainer = editFETEnablersPackager(omic);
		rows[2].appendChild(fetContainer);
	});
	rows[2].style.flexDirection = "column";
	rows.forEach(row =>{
		container.appendChild(row);
	})

	let containerSpan = document.createElement('span');
	containerSpan.className = 'fet-container-span';
	let titleSpan2 = document.createElement('span');
	titleSpan2.className = 'fet-title-span';
	titleSpan2.innerText = `Additional Features: `;
	containerSpan.appendChild(titleSpan2);

	rows[3].appendChild(containerSpan);
	rows[3].style.justifyContent = "flex-start";

	let extraContainer = editFETExtraFeaturesPackager();
	rows[4].appendChild(extraContainer);

	return(container);
}

function editConfBoxPackager() {
	console.log('conf')
	console.log(expConf)

	let container = document.createElement('div');
	container.className = 'conf-container';
	
	let rows = [];
	[0,1,2,3,4].forEach(() => {
		let containerRow = document.createElement('div');
		containerRow.className = 'conf-row';
		rows.push(containerRow);
	});
	rows[0].className += ' unjustify';
	// select omics
	let selectContainer = document.createElement('div');
	selectContainer.className = 'select-container';
	let span = document.createElement('span');
	span.innerHTML = 'Select omic';
	let select = document.createElement('select');
	select.id = 'omicsSelector';
	select.addEventListener('change',(event) => {displayOmic(event)});


	["gene","prot","urna","meth","chroma","meta"].forEach((omic) => {
		if (expConf[omic].idColumn) {
			let option = document.createElement('option');
			option.value = omic;
			option.innerText = omicToTitle[omic];
			option.name = omic;
			select.appendChild(option);
		}
	});

	["gene","prot","urna","meth","chroma","meta"].forEach((omic) => {
		let thrContainer = editThrBoxPackager(omic)
		rows[1].appendChild(thrContainer);
	});

	["gene","prot"].forEach((omic) => {
		let idOnlyContainer = editIdOnlyBoxPackager(omic);
		rows[2].appendChild(idOnlyContainer);


		let tfsContainer = editTfsBoxPackager(omic);
		rows[3].appendChild(tfsContainer);

		let noDeContainer = editNoDeBoxPackager(omic);
		rows[4].appendChild(noDeContainer);

	});
	["urna","meth","chroma"].forEach((omic) => {
		let idOnlyContainer = editIdOnlyBoxPackager(omic);
		rows[2].appendChild(idOnlyContainer);

		let noDeContainer = editNoDeBoxPackager(omic);
		rows[4].appendChild(noDeContainer);
	})

	
		let idOnlyContainer = editIdOnlyBoxPackager("meta");
		rows[2].appendChild(idOnlyContainer);

	
	selectContainer.appendChild(select);
	
	rows[0].appendChild(span);
	rows[0].appendChild(selectContainer);
	rows[1].style.flexDirection = 'column';
	
	rows.forEach(row =>{
		container.appendChild(row);
	})
	return(container);
}
function editThrBoxPackager(omic) {
	let thrContainer = document.createElement('div'); 
	thrContainer.id = `${omic}ThrContainer`;
	thrContainer.className = 'thr-container';
	thrContainer.style.display = omic !== 'gene' ? 'none' : 'flex';

	// thrContainer.style.alignItems = 'center';
	let thrs = ['LeftEffectSize','RightEffectSize','pVal'];

	thrs.forEach((thr) => {
		let containerSpan = document.createElement('span');
		containerSpan.className = 'thr-container-span';

		let titleSpan = document.createElement('span');
		titleSpan.className = 'thr-title-span';
		titleSpan.innerText = thr !== 'pVal' ? 'Effect Size' : 'p-value';
		titleSpan.innerText += thr === 'RightEffectSize' ? ' >' : ' <';

		let switchLabel = radiusSwitch(`${omic}${thr}Check`,`${omic}${thr}Check`);
		switchLabel.addEventListener('change', async function() {
			try {
				currentConf.updateEnabledThresholds(omic);
				checkInterface.checkThrInputs(omic);
				checkInterface.handleThrInputs(omic);
				checkInterface.handleSubmit();
				filterData(omic);
				displayPreview(omic);
			} catch (error) {
				console.log(error);
			}
		});

		let thrInput = document.createElement('input');
		thrInput.id =  `${omic}${thr}Threshold`;
		thrInput.type = 'number';
		thrInput.step = thr !== 'pVal' ? '0.1' : '0.01';
		thrInput.className = `thresholdInput Effect ${thr}`;
		thrInput.addEventListener('input', async function() {
			try {
				currentConf.updateThresholdValues(omic);
				checkInterface.checkThrInputs(omic);
				checkInterface.handleThrInputs(omic);
				checkInterface.handleSubmit();
				filterData(omic);
				displayPreview(omic);
			} catch (error) {
				console.log(error);
			}
		});


		containerSpan.appendChild(titleSpan);
		containerSpan.appendChild(thrInput);
		containerSpan.appendChild(switchLabel);
		thrContainer.appendChild(containerSpan);
		
	});
	return(thrContainer);
}
function editTfsBoxPackager(omic) {
	let tfsContainer = document.createElement('div'); 
	tfsContainer.id = `${omic}TfsContainer`;
	tfsContainer.className = 'tfs-container';
	tfsContainer.style.display = omic !== 'gene' ? 'none' : 'flex';


	let titles = ['Enable TFs',' Preserve IDs for TFs '];
	let ids = ['enabletfs','enabletfsIdOnly'];

	titles.forEach((title,i) => {
		let containerSpan = document.createElement('span');
		containerSpan.className = 'tfs-container-span';

		let titleSpan = document.createElement('span');
		titleSpan.className = 'tfs-title-span';
		titleSpan.innerText = title;

		let switchLabel = radiusSwitch(`${ids[i]}_${omic}`,`${ids[i]}_${omic}`);
		switchLabel.addEventListener('change', async function() {
			try {
				ids[i] === 'enabletfs' ? currentConf.updateEnabledTFs(omic)
				: currentConf.updateEnabledIdOnlyTFs(omic)
			} catch (error) {
				console.log(error);
			}
		});
		
		containerSpan.appendChild(titleSpan);
		containerSpan.appendChild(switchLabel);
		tfsContainer.appendChild(containerSpan);

	});


	
	return(tfsContainer);
}
function editNoDeBoxPackager(omic) {
	let container = document.createElement('div'); 
	container.id = `${omic}NoDeContainer`;
	container.className = 'noDe-container';
	container.style.display = omic !== 'gene' ? 'none' : 'flex';

	let titles = 
		omic === 'gene' || omic === 'prot' ? ['Load Non DE from TFs','Load Non DE from Preserved TFs']
		: ['No DE Loading','No DE Loading From Preserved IDs']
	;
	let ids = 
		omic === 'gene' || omic === 'prot' ? ['nodeg_select_tf','tfsNoDEFromIdOnlyCheck']
		: ['nodeg_select','NoDEFromIdOnlyCheck']	
	;

	titles.forEach((title,i) => {
		let containerSpan = document.createElement('span');
		containerSpan.className = 'noDe-container-span';

		let titleSpan = document.createElement('span');
		titleSpan.className = 'noDe-title-span';
		titleSpan.innerText = title;

		let switchId = ids[i] === "NoDEFromIdOnlyCheck" ? `${omic}${ids[i]}` : `${ids[i]}_${omic}`;
		let switchLabel = radiusSwitch(switchId,switchId);
		switchLabel.addEventListener('change',async function() {
			try {
				switchId === `${omic}NoDEFromIdOnlyCheck` ? currentConf.updateEnabledNoDeIdOnlyLoaders(omic)
				: switchId === `nodeg_select_${omic}` ? currentConf.updateEnabledNoDeLoaders(omic)
				: switchId === `nodeg_select_tf_${omic}` ? currentConf.updateEnabledNoDeTFsLoaders(omic)
				: currentConf.updateEnabledNoDeIdOnlyTFsLoaders(omic);

			} catch (error) {
				console.log(error);
			}
		});
		if (switchId === `nodeg_select_${omic}`) {
			switchLabel.addEventListener('change', async function() {
				try {
					checkInterface.handleNoDeEnabled();
				} catch (error) {
					console.log(error);
				}
			});
		}

		containerSpan.appendChild(titleSpan);
		containerSpan.appendChild(switchLabel);
		container.appendChild(containerSpan);

	});

	return(container);
}
function editIdOnlyBoxPackager(omic) {
	let idOnlyContainer = document.createElement('div'); 
	idOnlyContainer.id = `${omic}IdOnlyContainer`;
	idOnlyContainer.className = 'tfs-container';
	idOnlyContainer.style.display = omic !== 'gene' ? 'none' : 'flex';
	['Preserve non DE IDs'].forEach((title) => {
		let containerSpan = document.createElement('span');
		containerSpan.className = 'idOnly-container-span';

		let titleSpan = document.createElement('span');
		titleSpan.className = 'idOnly-title-span';
		titleSpan.innerText = title;

		let switchLabel = radiusSwitch(`${omic}IdOnlyCheck`,`${omic}IdOnlyCheck`);
		switchLabel.addEventListener('change', async function() {
			try {
				currentConf.updateEnabledIdOnly(omic);
			} catch (error) {
				console.log(error);
			}
		});


		containerSpan.appendChild(titleSpan);
		containerSpan.appendChild(switchLabel);
		idOnlyContainer.appendChild(containerSpan);

	});

	return(idOnlyContainer);
}
function editFETEnablersPackager(omic) {
	let container = document.createElement('div'); 
	container.id = `${omic}FETContainer`;
	container.className = 'fet-container';
	container.style.display = 'flex';
	container.style.flexDirection = 'row';

	let containerSpan = document.createElement('span');
	containerSpan.className = 'fet-container-span';

	let titleSpan = document.createElement('span');
	titleSpan.className = 'fet-title-span';
	titleSpan.innerText = omicToTitle[omic];

	let switchLabel = radiusSwitch(`${omic}FETEnabled`,`${omic}FETEnabled`);
	switchLabel.addEventListener('change', async function() {
		try {
			currentConf.updateEnabledFETs(omic);
			checkInterface.handleFETEnabled();
			checkInterface.handleNoDeEnabled();
			checkInterface.handleFETPooling();
		} catch (error) {
			console.log(error);
		}
	});
	containerSpan.appendChild(titleSpan);
	containerSpan.appendChild(switchLabel);
	container.appendChild(containerSpan);

	return(container);
}
function editFETExtraFeaturesPackager() {

	let extraTitles = ["Pooling","Intersect"];
	let extraContainer = document.createElement('div');
	extraContainer.id = 'FETExtraFeatures';
	extraContainer.className = 'fet-container';
	
	["FETPooling","FETIntersect"].forEach((id,i) => {
		let containerSpan = document.createElement('span');
		containerSpan.className = 'fet-container-span';
		let titleSpan = document.createElement('span');
		titleSpan.className = 'fet-title-span';
		titleSpan.innerText = `${extraTitles[i]}`;
		let switchLabel = radiusSwitch(id,id);
		switchLabel.id = `${id}Label`;
		switchLabel.addEventListener('change', async function() {
			try {
				currentConf.updateEnabledFETExtras();
			} catch (error) {
				console.log(error);
			}
		});
		containerSpan.appendChild(titleSpan);
		containerSpan.appendChild(switchLabel);
		extraContainer.appendChild(containerSpan);
	});

	return(extraContainer);
}

// interface objects

function radiusSwitch(id,name) {
	let switchLabel = document.createElement('label');
	switchLabel.className = 'switch';
	let switchInput = document.createElement('input');
	switchInput.id = id;
	switchInput.name = name;
	switchInput.type = 'checkbox';
	let switchSpan = document.createElement('span');
	switchSpan.className = 'slider round';
	switchLabel.appendChild(switchInput);
	switchLabel.appendChild(switchSpan);

	return(switchLabel);
}
function button(id,text,iconText,onClickFunction) {
	let div = document.createElement('div');
	div.className = 'conf-container';
	let a = document.createElement('a');
	a.id = id;
	a.addEventListener('click',function() {
		onClickFunction()
	});
	a.className = 'exp-package-item-icon';
	let i = document.createElement('i');
	i.className = 'material-icons';
	i.innerText = iconText;
	let span = document.createElement('span');
	span.innerText = text;
	a.appendChild(i);
	a.append(span);
	div.appendChild(a);
	return(div)
}



// fill conf elements after loading
function fillExpGenerics(expConf) {
	["expname","comments","organism"].forEach((section) => {
		document.getElementById(`${section}Input`).value = expConf[section];
	});
}
function fillDataCheckBoxes(lastConf,omic) {
	document.getElementById(`enable${omic}`).checked = lastConf[omic].enabled;
}
function fillExpThresholds(lastConf,omic) {
	["LeftEffectSizeThreshold","RightEffectSizeThreshold","pValThreshold"].forEach((id) => {
		document.getElementById(`${omic}${id}`).value = 
			id === "LeftEffectSizeThreshold" ? lastConf[omic]["LeftThreshold"]
			: id === "RightEffectSizeThreshold" ? lastConf[omic]["RightThreshold"]
			: lastConf[omic][`${id}`];
	});
	["LeftEffectSizeCheck","RightEffectSizeCheck","pValCheck","IdOnlyCheck"].forEach((id) => {
		document.getElementById(`${omic}${id}`).checked = lastConf[omic][`${id}`] ? true : false;
	});

}

function fillTfsCheckBoxes(lastConf,omic) {
	["enabletfs","enabletfsIdOnly","tfsNoDEFromIdOnlyCheck","nodeg_select_tf"].forEach((id) => {
		document.getElementById(`${id}_${omic}`).checked = lastConf[omic][id] ? true : false;
	});
}
function fillNoDeCheckBoxes(lastConf,omic) {
	document.getElementById(`${omic}NoDEFromIdOnlyCheck`).checked = lastConf[omic]["NoDEFromIdOnlyCheck"] ? true : false;
	document.getElementById(`nodeg_select_${omic}`).checked = lastConf[omic]["nodeg_select"] ? true : false;
}
function fillFETCheckBoxes(lastConf,omic) {
	document.getElementById(`${omic}FETEnabled`).checked = lastConf[omic]["enabledFET"] ? true : false;
}
function fillFETExtras(lastConf) {
	document.getElementById('FETPooling').checked = lastConf.FETPooling;
	document.getElementById('FETIntersect').checked = lastConf.FETIntersect;

}

//preview functions

function filterData(omic) {
	console.log(`Input ${omic} ids: ${expData[omic].objData.length}`);
	let omicEnabled = currentConf.enabledOmics[omic];
	
	filterPreview[omic].inputIds = expData[omic].objData;
	filterPreview[omic].inputIdsNum = expData[omic].objData.length;
	
	[filterPreview[omic].esFiltered,filterPreview[omic].esFilteredNum] = filterByES(omic);
	console.log(filterPreview[omic].esFiltered);
	[filterPreview[omic].pValFiltered,filterPreview[omic].pvalFilteredNum] = filterBypVal(omic);
	console.log(filterPreview[omic].pValFiltered);

	filterPreview[omic].outputIdsNum = filterPreview[omic].inputIdsNum - filterPreview[omic].esFilteredNum - filterPreview[omic].pvalFilteredNum;

	// let test = expData[omic].objData.filter((obj) => (obj.isIdOnly));
	// console.log(`test: ${test.length}`);
	// let pValFiltered = test.filter((obj) => (
	// 	parseFloat(obj.pVal) < 0.05
	// ));
	// console.log(pValFiltered)

}
function filterByES(omic) {
	let esLeftEnabled = currentConf.omicConfs[omic].esLeftEnabled;
	let esRightEnabled = currentConf.omicConfs[omic].esRightEnabled;
	let leftEsThr = currentConf.omicConfs[omic].esLeftThr;
	let rightEsThr = currentConf.omicConfs[omic].esRightThr;

	let esFiltered = 
	esLeftEnabled && esRightEnabled ? expData[omic].objData.filter((obj) => (
		parseFloat(obj.esVal) < leftEsThr || parseFloat(obj.esVal) > rightEsThr
	)) :
	esLeftEnabled && !esRightEnabled ? expData[omic].objData.filter((obj) => (
		parseFloat(obj.esVal) < leftEsThr
	)) :
	!esLeftEnabled && esRightEnabled ? expData[omic].objData.filter((obj) => (
		parseFloat(obj.esVal) > rightEsThr
	)) :
	expData[omic].objData;

	let filteredCount = filterPreview[omic].inputIdsNum - esFiltered.length;
	return([esFiltered,filteredCount]);
}
function filterBypVal(omic) {
	let pValEnabled = currentConf.omicConfs[omic].pValEnabled;
	let pValThr = currentConf.omicConfs[omic].pValThr;
	let pValFiltered = pValEnabled ? filterPreview[omic].esFiltered.filter((obj) => (
		parseFloat(obj.pVal) < pValThr
	)) : filterPreview[omic].esFiltered;
	let filteredCount = filterPreview[omic].esFiltered.length - pValFiltered.length;
	return([pValFiltered,filteredCount]);
}
function filterIdOnlys(omic) {

}
function displayPreview(omic) {
	let ids = ["Input","EsFiltered","pValFiltered","Output"];
	let values = [
		filterPreview[omic].inputIdsNum,
		filterPreview[omic].esFilteredNum,
		filterPreview[omic].pvalFilteredNum,
		filterPreview[omic].outputIdsNum
	];
	["Input:","Filetered out by Effect Size:","Filetered out by p-value:","Output:"].forEach((text,i) => {
		let span = document.getElementById(`${omic}${ids[i]}Span`);
		span.innerText = `${text} ${values[i]}`;
	})
}
// display functions

function displayOmic(event) {

	let idOnlyContainers = document.getElementsByClassName('idOnly-container');
	let thrContainers = document.getElementsByClassName('thr-container');
	let tfsContainers = document.getElementsByClassName('tfs-container');
	let noDeContainers = document.getElementsByClassName('noDe-container');
	let previewRows = document.getElementsByClassName('preview-box');

	Array.from(idOnlyContainers).forEach((container) => {
		container.style.display = 'none';
	})

	Array.from(thrContainers).forEach((container) => {
		container.style.display = 'none';
	})
	Array.from(tfsContainers).forEach((container) => {
		container.style.display = 'none';
	})
	Array.from(noDeContainers).forEach((area) => {
		area.style.display = 'none';
	})
	Array.from(previewRows).forEach((area) => {
		area.style.display = 'none';
	})

	let omic = event.target.selectedOptions[0].value;
	if (document.getElementById(`${omic}IdOnlyContainer`)) {
		document.getElementById(`${omic}IdOnlyContainer`).style.display = 'flex';
	}
	if (document.getElementById(`${omic}TfsContainer`)) {
		document.getElementById(`${omic}TfsContainer`).style.display = 'flex';
	}
	if (document.getElementById(`${omic}ThrContainer`)) {
		document.getElementById(`${omic}ThrContainer`).style.display = 'flex';
	}
	if (document.getElementById(`${omic}NoDeContainer`)) {
		document.getElementById(`${omic}NoDeContainer`).style.display = 'flex';
	}
	if (document.getElementById(`${omic}PreviewRow`)) {
		document.getElementById(`titlePreviewRow`).style.display = 'flex';
		document.getElementById(`${omic}PreviewRow`).style.display = 'flex';
	}
}

// generic useful functions

function getQueryParam(param,url) {
	const urlObj = url ? new URL(url) : window.location;
	const urlParams = new URLSearchParams(urlObj.search);
	return urlParams.get(param);
}
function convertValuesToBoolean(obj, keysToConvert) {
  for (let key in obj) {
    if (typeof obj[key] === 'object' && obj[key] !== null) {
      convertValuesToBoolean(obj[key], keysToConvert); // Recursive call for nested objects
    } else if (keysToConvert.includes(key)) {
      if (obj[key] === "1") {
        obj[key] = true;
      } else if (obj[key] === "0") {
        obj[key] = false;
      }
    }
  }
  return obj;
}
function disableInputs(divId,disable) {
	var div = document.getElementById(divId);
	console.log(disable);
	// select nested elements within the div
	var elements = div.querySelectorAll('input, textarea, select, button, span');

	elements.forEach(function(element) {
		disableElement(element,disable);
	});
}
function disableElement(element,disable) {
	element.disabled = disable ? true : false;
	if (element.className === "slider round") {
		if (!disable) {
			element.style.removeProperty('background-color');
		} else {
			element.style.backgroundColor = 'grey';
		}
	}
}
