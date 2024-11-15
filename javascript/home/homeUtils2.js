// global variables & onload async calls
var omicsValid = {};
var expConf = {};
var expData = {};
var expOnts = [];
var idTypesValid = {};
var availableOnts = {};
let uploadInProgress = false;  

document.addEventListener("DOMContentLoaded", async function() {
	try {
		let {omics , idTypes} = await loadAvailableOmics();
		omicsValid = omics;
		idTypesValid = idTypes;

		expConf = await loadExpConf();
		[expData,expOnts] = await loadExpData();
		availableOnts = await loadOnts();
		
		// mark selected onts from onts file for every organism that has those ont ids
		Object.keys(availableOnts).forEach((organism) => {
			availableOnts[organism].map((ont) => {
				ont.selected = expOnts.includes(ont.id) ? true : false;
			});
		});
		//assign change event to organism select here
		document.getElementById('organismSelect').addEventListener('change',(event) => {
			loadConfBox(event);
			loadOntBox(event);
		})
		
    fillOrganismSelect(expConf.organism);
		

  } catch (error) {
    console.error('Error loading experiment configuration:', error);
  }
});






async function submitForm(event) {
	const clickedElement = event.target;
	const parentElement = clickedElement.parentElement;
	const parentId = parentElement.id;
	let query = parentElement.action;

	const sid = getQueryParam('sid');
	const action = getQueryParam('action',query);
	console.log(`submitForm: ${query}`);

	const formData = new FormData();
	formData.append('action', action);
	formData.append('sid', sid);

	if (parentId === 'upload_pack_form') {
		const fileInput = document.getElementById('packInput');
    
		const fileSelected = new Promise((resolve) => {
			fileInput.addEventListener('change', (event) => {
					resolve(event.target.files[0]);
			}, { once: true });
		});

		document.getElementById('packInput').click();

		const file = await fileSelected;
		formData.append('file', file);

		postRequest(query,formData,true);
	}
	if (parentId === 'download_home_form') {
		query += `&sid=${sid}`;
		getRequestForDownload(query)	
	}
	if (parentId === 'add_new_form') {
		await postRequest(query,formData);
		window.location.reload();
	}
	if (parentId === 'download_pack_form') {
		query += `&sid=${sid}&exp=${getQueryParam('exp')}`;
		getRequestForDownload(query);
	}
	if (parentId === 'save_form') {
		query += `&sid=${sid}&exp=${getQueryParam('exp')}`;
		console.log(query);
		let confToPost = {
			title: getFieldValue('expnameInput'),
			comments: getFieldValue('commentsInput'),
			id: getQueryParam('exp'),
			organism: getSelectorValue('organismSelect'),
			omics : {}
		};

		["gene","prot","urna","meth","chroma","meta"].map((omic) => {
			confToPost.omics[omic] = {
				idType : getSelectorValue(`${omic}IdTypeSelector`),
				idColumn : getFieldValue(`${omic}IdColumnInput`),
				devColumn : getFieldValue(`${omic}DevColumnInput`),
				pValColumn : getFieldValue(`${omic}pValColumnInput`),
				textData: getFieldValue(`${omic}Data`)
			};
		})
		confToPost.onts = Array.from(document.getElementById('selectedOntsUl').getElementsByTagName('li')).map((li) =>(
			li.id
		));
		console.log(confToPost);
		formData.append('data',JSON.stringify(confToPost));
		postRequest(query,formData,true);
	}

}

async function uploadFileAndReload(query, formData) {
	try {
			const { result, response } = await postRequest(query, formData);
			window.location.reload();
			return response;
	} catch (error) {
			alert(error.message);
			throw error;
	}
}



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

	if (action === "downloadExp") {
		const query = `../cgi-bin/pathlayHomeActions.pl?action=downloadExp&sid=${sid}&exp=${exp}`;
		getRequestForDownload(query);
	}

	if (action === "editExp") {
		const baseUrl = `${window.location.protocol}//${window.location.host}${window.location.pathname}`;
		window.location.href = `${baseUrl}?sid=${sid}&mode=edit&exp=${exp}`;
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
}
function redirect() {
	const baseUrl = `${window.location.protocol}//${window.location.host}${window.location.pathname}`;
	let script = 
			dest === "home" ? 'pathlayHome.pl' :
			dest === "access" ? 'pathlayAccess.pl' :
			'pathlayDBConf.pl';

	const newUrl = `${baseUrl.replace('welcome.pl', script)}?sid=${getQueryParam("sid")}`;
	window.location.href = newUrl;        
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
async function getRequestForDownload(url) {
	try {
		const response = await fetch(url, {
			method: 'GET', 
		});

		if (!response.ok) {
			throw new Error('Network response was not ok ' + response.statusText);
		}

		const blob = await response.blob();
		const link = document.createElement('a');
		
		link.href = URL.createObjectURL(blob);
		const contentDisposition = response.headers.get('Content-Disposition');
		if (contentDisposition && contentDisposition.includes('filename=')) {
			let filename = contentDisposition
				.split('filename=')[1]
				.replace(/['"]/g, ''); // Remove any surrounding quotes
			link.download = filename;
		}
		document.body.appendChild(link);
		link.click();
		document.body.removeChild(link);

	} catch (error) {
		console.error('There was a problem with the fetch operation:', error);
	}
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


// Edit Exp Page functions
// structural elements

function editConfBoxPackager(organism) {
	let container = document.createElement('div');
	container.className = 'conf-container';
	
	let rows = [];
	[0,1,2,3].forEach(() => {
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


	["gene","prot","urna","meth","chroma","meta"].map((omic) => {
		if (omicsValid[organism][omic]) {
			let option = document.createElement('option');
			option.value = omic;
			option.innerText = omic;
			option.name = omic;
			select.appendChild(option);
		}
	});

	selectContainer.appendChild(select);
	
	// edit ID Type
	["gene","prot","urna","meth","chroma","meta"].map((omic) => {
		let idTypeContainer = document.createElement('div');
		idTypeContainer.className = 'id-type-container';
		idTypeContainer.id = `${omic}IdTypeContainer`;
		idTypeContainer.style = 'display: none;';
		

		let selectContainer2 = document.createElement('div');
		selectContainer2.className = 'select-container';
		
		let idTypeSelect = document.createElement('select');
		idTypeSelect.id = `${omic}IdTypeSelector`;

		idTypesValid[organism][omic].map((idType) => {
			let option = document.createElement('option');
			option.value = idType.id;
			option.innerText = idType.name;
			option.name = idType.id;
			idTypeSelect.appendChild(option);
		})


		let span = document.createElement('span');
		span.innerText = "Select ID Type";
		
		selectContainer2.appendChild(idTypeSelect);
		idTypeContainer.appendChild(span);
		idTypeContainer.appendChild(selectContainer2);
		// edit Columns Numbers
		let columnsContainer = document.createElement('div');
		columnsContainer.className = 'columns-container';
		columnsContainer.id = `${omic}ColumnsContainer`;
		columnsContainer.style = 'display: none;';
		let idColumnInput = document.createElement('input');
		idColumnInput.type = 'text';
		idColumnInput.id = `${omic}IdColumnInput`;
		let devColumnInput = document.createElement('input');
		devColumnInput.type = 'text';
		devColumnInput.id = `${omic}DevColumnInput`;

		let pvalColumnInput = document.createElement('input');
		pvalColumnInput.type = 'text';
		pvalColumnInput.id = `${omic}pValColumnInput`;
		
	
		let columnInputs = [idColumnInput,devColumnInput,pvalColumnInput];
		let columnTexts = ["ID Column","Effect Size Column","p-value Column"];
		[0,1,2].forEach(n => {
			let columnRow = document.createElement('div');
			columnRow.className = 'columns-row';
			let span = document.createElement('span');
			span.innerText = columnTexts[n];
			columnRow.appendChild(span);
			columnRow.appendChild(columnInputs[n]);
			columnsContainer.appendChild(columnRow);
		});
		
		// text area
		
		let textArea = document.createElement('textarea');
		textArea.id = `${omic}Data`;
		textArea.className = "data-text-area";
		textArea.className += ` ${omic}-colored`;
		textArea.style = 'display: none;';
		
		// upload button
		let uploadButton = document.createElement('a');
		uploadButton.id = `${omic}UploadButton`;
		uploadButton.className = 'exp-package-item-icon upload-button';
		uploadButton.style.display = 'none';
		uploadButton.addEventListener('click', () => {
			document.getElementById(`${omic}PackInputOmic`).click();
		});
		
		let uploadIcon = document.createElement('i');
		uploadIcon.innerHTML = 'upload_file';
		uploadIcon.className = 'material-icons';
		let iconSpan = document.createElement('span');
		iconSpan.innerText = `Upload ${omic} pack`;
		let fileInput = document.createElement('input');
		fileInput.id = `${omic}PackInputOmic`;
		fileInput.style.display = 'none';
		fileInput.style.pointerEvents = 'none';
		fileInput.type = 'file';
		fileInput.addEventListener('click',() => {
			performAction('uploadOmicPack',getQueryParam('exp'))
		});
		// let form = document.createElement('form');
		// form.appendChild(uploadButton);
		uploadButton.appendChild(uploadIcon);
		uploadButton.appendChild(iconSpan);
		uploadButton.appendChild(fileInput);
		
		// append rows
		rows[1].appendChild(idTypeContainer);
		rows[1].appendChild(columnsContainer);
		rows[2].appendChild(textArea);
		rows[3].appendChild(uploadButton);
		
		// assign rows IDs
		rows[2].id = `dataRow`;
	});
	
	rows[0].appendChild(span);
	rows[0].appendChild(selectContainer);
	
	rows.forEach(row =>{
		container.appendChild(row);
	})
	return(container);
}
function editOntBoxPackager(organism) {
	let container = document.createElement('div');
	container.className = 'conf-container onts-container';
	let rows = [];
	[0,1,2,3].forEach(() => {
		let containerRow = document.createElement('div');
		containerRow.className = 'conf-row';
		rows.push(containerRow);
	});
	rows[0].className += ' unjustify';


	let searchSpan = document.createElement('span');
	searchSpan.innerText = 'Search';
	let searchBar = document.createElement('input');
	searchBar.type = 'text';
	searchBar.className = 'searchbar';
	searchBar.placeholder = 'Search for Ontologies';
	searchBar.addEventListener('input',(event) => {
		searchForOnt(event);
	})

	let ontDiv1 = document.createElement('div');
	ontDiv1.id = 'availableOntsBox';
	ontDiv1.className = 'onts-box left-radius';
	let ontDiv2 = document.createElement('div');
	ontDiv2.className = 'onts-box right-radius';
	ontDiv2.id = 'selectedOntsBox';

	let ontUl1 = document.createElement('ul');
	ontUl1.id = 'availableOntsUl';
	ontUl1.className = 'onts-ul';
	let ontUl2 = document.createElement('ul');
	ontUl2.id = 'selectedOntsUl';
	ontUl2.className= 'onts-ul';

	availableOnts[organism].map((ontObj) => {
		let li = document.createElement('li');
		li.id = ontObj.id;
		li.name = ontObj.name;
		li.className = 'ont-li';
		li.innerText = `${ontObj.name} (${ontObj.id})`;
		let boxToAppend = ontObj.default || ontObj.selected ? ontUl2 : ontUl1;

		if (!ontObj.default) {
			let icon = document.createElement('span');
			icon.className = 'material-symbols-outlined';
			icon.innerHTML = boxToAppend === ontUl1 ? 'add' : 'remove';
			icon.addEventListener('click',(event) => {
				moveOnt(event)
			})
			li.appendChild(icon);
		} else {
			let icon = document.createElement('span');
			icon.className = 'material-symbols-outlined';
			icon.innerHTML = 'lock';
			li.appendChild(icon);
		}
		boxToAppend.appendChild(li);
	});


	ontDiv1.appendChild(ontUl1);
	ontDiv2.appendChild(ontUl2);

	rows[0].appendChild(searchSpan);
	rows[0].appendChild(searchBar);
	rows[1].appendChild(ontDiv1);
	rows[1].appendChild(ontDiv2);


	rows.forEach(row =>{
		container.appendChild(row);
	})
	return(container);
}

// Load exp conf and create object, called by the organism selector
function loadConfBox(event) {
	const organism = event.target.selectedOptions[0].value;
	let containerRows = document.getElementsByClassName('container-row');
	containerRows[2].innerHTML = '';
	containerRows[2].appendChild(editConfBoxPackager(organism));


	var event = new Event('change');
	document.getElementById('omicsSelector').dispatchEvent(event);
	
	
	fillExpGenerics(expConf);
	fillExpColumns(expConf);
	fillExpIdTypeSelect(expConf);
	fillExpData(expData);
}
function loadOntBox(event){
	const organism = event.target.selectedOptions[0].value;
	let containerRows = document.getElementsByClassName('container-row');
	
	containerRows[3].innerHTML = '';
	containerRows[3].appendChild(editOntBoxPackager(organism));
}



async function loadAvailableOmics() {
	try {
		const response = await getRequest(`pathlayHomeActions.pl?action=getOmics`);
		console.log('Conf received:', response);
		return {omics : convertToBoolean(response.omicsValid), idTypes : response.idTypesValid};
	} catch (error) {
		console.error('Error:', error);
	}
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
		const response = await getRequest(`pathlayHomeActions.pl?action=loadExpData&exp=${exp}&sid=${sid}`);
		console.log('Exp Data received:', response);
		return([response.data,response.onts])
	} catch (error) {
		console.error('Error:', error);
	}
}

async function loadOnts() {
	const sid = getQueryParam('sid');
	const exp = getQueryParam('exp');
	const response = await getRequest(`pathlayHomeActions.pl?action=loadOnts&exp=${exp}&sid=${sid}`);
	console.log('Available Onts received:', response.onts);
	return(response.onts);
}


// fill conf elements after loading

function fillOrganismSelect(organism) {
	selectOptionByValue('organismSelect',organism);
	var event = new Event('change');
	document.getElementById('organismSelect').dispatchEvent(event);
}
function fillExpGenerics(expConf) {
	["expname","comments"].forEach((section) => {
		document.getElementById(`${section}Input`).value = expConf[section];
	});
}
function fillExpColumns(expConf) {
	["gene","prot","urna","meth","chroma","meta"].map((omic) => {
		if (expConf[omic]) {
			document.getElementById(`${omic}IdColumnInput`).value = expConf[omic].idColumn;
			document.getElementById(`${omic}DevColumnInput`).value = expConf[omic].devColumn;
			document.getElementById(`${omic}pValColumnInput`).value = expConf[omic].pvalueColumn;
		}
	});
}
function fillExpIdTypeSelect(expConf) {
	["gene","prot","urna","meth","chroma","meta"].map((omic) => {
		if (expConf[omic]) {
			selectOptionByValue(`${omic}IdTypeSelector`, expConf[omic].IdType);	
		}
	});
}
function fillExpData(expData) {
	["gene","prot","urna","meth","chroma","meta"].map((omic) => {
		document.getElementById(`${omic}Data`).value = expData[omic] ? expData[omic] : '';
		document.getElementById(`${omic}Data`).style.height = "30vh";
	});
}


// search bar
function searchForOnt(event) {
	const searchFor = event.target.value.toLowerCase();
	let allOntLis = Array.from(document.getElementsByClassName('ont-li'));
	allOntLis.map((li) => {
		li.style.display = li.innerText.toLowerCase().includes(searchFor) ? 'flex' : 'none';
	})
}

// move onts around

function moveOnt (event) {
	let li = event.target.parentElement;
	let parentUl = document.getElementById(li.id).parentElement;
	console.log(`li to move: ${li.id}`);
	console.log(`parent box: ${parentUl.id}`);

	let appendTo = document.getElementById(parentUl.id === 'availableOntsUl' ? 'selectedOntsUl' : 'availableOntsUl');
	li.getElementsByTagName('span')[0].innerHTML = parentUl.id === 'availableOntsUl' ? 'remove' : 'add';
	appendTo.appendChild(li);
	reorderListByTag(appendTo,'id');
	console.log(appendTo)
	//update onts object for every organism 
	Object.keys(availableOnts).forEach((organism) => {
		let toUpdate = availableOnts[organism].find((ont) => ont.id === li.id);
		if (toUpdate) {
			toUpdate.selected = appendTo.id === 'availableOntsUl' ? false : true;
			console.log(toUpdate);
		}
	})
	console.log(availableOnts);
}


// get values from elements for saving

function getFieldValue(id) {
	return(document.getElementById(id).value);
}
function getSelectorValue(id) {
	return(document.getElementById(id).selectedOptions[0].value);
}


// hide and display elements

function displayOmic(event) {

	let idTypeContainers = document.getElementsByClassName('id-type-container');
	let columnsContainers = document.getElementsByClassName('columns-container');
	let dataAreas = document.getElementsByClassName('data-text-area');
	let uploadButtons = document.getElementsByClassName('upload-button');

	Array.from(idTypeContainers).forEach((container) => {
		container.style.display = 'none';
	})
	Array.from(columnsContainers).forEach((container) => {
		container.style.display = 'none';
	})
	Array.from(dataAreas).forEach((area) => {
		area.style.display = 'none';
	})
	Array.from(uploadButtons).forEach((button) => {
		button.style.display = 'none';
	})

	let omic = event.target.selectedOptions[0].value;
	document.getElementById(`${omic}IdTypeContainer`).style.display = 'flex';
	document.getElementById(`${omic}ColumnsContainer`).style.display = 'flex';
	document.getElementById(`${omic}Data`).style.display = 'flex';
	document.getElementById(`${omic}UploadButton`).style.display = 'flex';
}



// generic useful functions

function getQueryParam(param,url) {
	const urlObj = url ? new URL(url) : window.location;
	const urlParams = new URLSearchParams(urlObj.search);
	return urlParams.get(param);
}
function selectOptionByValue(selectElementId, value) {
	var selectElement = document.getElementById(selectElementId);
	for (var i = 0; i < selectElement.options.length; i++) {
		if (selectElement.options[i].value == value) {
			selectElement.selectedIndex = i;
			break;
		}
	}

}
function convertToBoolean(obj) {
  const newObj = {};

  for (const key in obj) {
    if (obj.hasOwnProperty(key)) {
      newObj[key] = {};
      for (const subKey in obj[key]) {
        if (obj[key].hasOwnProperty(subKey)) {
          newObj[key][subKey] = obj[key][subKey] === 1;
        }
      }
    }
  }

  return newObj;
}
function reorderListByTag(list,tag) {
	var itemsArray = Array.from(list.getElementsByTagName('li'));
	itemsArray.sort((a, b) => a[tag].localeCompare(b[tag]));
	// Remove  items from the list
	while (list.firstChild) {
		list.removeChild(list.firstChild);
	}
	// Append the sorted items back
	itemsArray.forEach(item => list.appendChild(item));
}
