import { typeToTitle, mapsCheck } from './global.js';
import { downloadMaps } from './MapsRequests.js';



export function updateResultsContainer(status,organism) {
	// if (requestQueue.processing) {
	// 	return;
	// }
	let resultContainer = document.getElementById('resultContainer');
	cleanUp("resultContainer");

	if (status === "loading") {
		resultContainer.appendChild(statusDiv(`${organism}-loadingMessage`, "loading", "Checking files..."));
	}
	if (status === "serverError") {
		resultContainer.appendChild(statusDiv(`${organism}-errorMessage`, "error", "Unable to fetch data"));
	}
	if (status === "ok") {
		resultContainer.appendChild(statusDiv(`${organism}-okMessage`,"ok","Database configured successfully!"));
	}
	if (status === "dbError") {
		resultContainer.appendChild(statusDiv(`${organism}-errorMessage`,"error","Database files missing!"));
	}
}

// status box for each Map DB
export function statusDiv (id,status,message) {
	var div = document.createElement('div');
	div.id = id;
	div.className = "status-div";
	div.className += 
		status === "ok" ?  " ok-message" : 
		status === "error" ? " error-message" : 
		status === "loading" || status === "warning" ? " warning-message" : 
		" neutral-message";
	var divMessage = document.createElement('div');
	divMessage.className = "status-message-div"; 
	var divIcon = document.createElement('div');
	divIcon.className = status === "loading" ? "status-icon-loading" : "status-icon-div";
	divMessage.innerHTML = `<b>${message}</b>`;
	divIcon.innerHTML = 
		status === "ok" ? '<i class="material-icons-outlined" id="check-icon">check_circle_outline</i>' :
		status === "error" || status === "warning" ? '<i class="material-icons-outlined" id="error-icon">error_outline</i>' :
		"";
	if (status === "loading" || status === "download") {
		let spinner = document.createElement('div');
		spinner.id = "spinner";
		spinner.className = "spinner-div";
		divIcon.appendChild(spinner)
	}
	let messageWrap = document.createElement('div');
	messageWrap.className = "status-message-info-div";

	messageWrap.appendChild(divMessage);
	messageWrap.appendChild(divIcon);
	div.appendChild(messageWrap);
	return(div);
}
export function updateBoxMapStatus (db,organism,status) {
	console.log(`Updating Box Maps Status: ${db} ${organism} ${status}`);
	cleanUp(`statusBoxMaps${db}`);




	let box = document.getElementById(`statusBoxMaps${db}`);
	box.className = "result-container";
	// box.className += 
	// 	status === "ok" ? " ok-message" :
	// 	status === "error" ? " error-message" :
	// 	" warning-message";

	if (status === "ok") {
		box.appendChild(statusDiv(`${db}-okMessage`,"ok","All maps are downloaded!"));
	}
	if (status === "warning") {
		box.appendChild(statusDiv(`${db}-warningMessage`,"warning","Some maps were not found!"));
		let messageDiv = box.querySelector('div')
		let buttonDiv = document.createElement('div');
		buttonDiv.className = "status-message-button-div";
		buttonDiv.appendChild(downloadMapsButton(organism,db));
		messageDiv.appendChild(buttonDiv);
	}
	if (status === "error") {
		box.appendChild(statusDiv(`${db}-errorMessage`,"error","Some maps were not found!"));
		let messageDiv = box.querySelector('div')
		let buttonDiv = document.createElement('div');
		buttonDiv.className = "status-message-button-div";
		buttonDiv.appendChild(downloadMapsButton(organism,db));
		messageDiv.appendChild(buttonDiv);
	}
	if (status === "download") {
		box.appendChild(statusDiv(`${db}-loadingMessage`, "download", "Downloading files..."));
	}
	if (status === "loading") {
		box.appendChild(statusDiv(`${db}-loadingMessage`, "loading", "Checking files..."));
	}
}

// lis
export function mapLi(map){
	let li = document.createElement('li');
	li.id = `${map.id}-li`;
	li.className = "mapLi";
	let divBox = document.createElement('div');
	let divText = document.createElement('div');
	let divIcon = document.createElement('div');
	
	li.className += (!map.imgAvailable || !map.fileAvailable) ? " error-message" : " ok-message"; 
	divBox.className = 'li-div-box';
	divBox.id = `${map.id}-li-box`;
	divText.className = 'li-div';
	divText.id = `${map.id}-li-text`;
	divIcon.className = 'li-div';
	divIcon.id = `${map.id}-li-icon`;

	let iconHtml = map.imgAvailable && map.fileAvailable ? 
		'<i class="material-icons-outlined" id="check-icon">check_circle_outline</i>'
		: '<i class="material-icons-outlined" id="error-icon">error_outline</i>';
	;

	divIcon.innerHTML = iconHtml;
	divText.innerText = `${map.name} (${map.id})`;
	divBox.appendChild(divText);
	divBox.appendChild(divIcon);
	li.appendChild(divBox);
	return(li)
}
export function updateLiStatus(map,status) {
	let iconToUpdate = document.getElementById(`${map.id}-li-icon`);
	let liToUpdate = document.getElementById(`${map.id}-li`);
	iconToUpdate.innerHTML = '';
	let newHtml = 
		status === 'ok' ? '<i class="material-icons-outlined" id="check-icon">check_circle_outline</i>' :
		status === 'error' ? '<i class="material-icons-outlined" id="error-icon">error_outline</i>' :
		'';
	iconToUpdate.innerHTML = newHtml;
	liToUpdate.className = "mapLi";
	liToUpdate.className += 
		status === 'error' ? " error-message" : 
		status === 'ok' ? " ok-message" :
		' warning-message';
	if (status === 'loading') {
		let spinner = document.createElement('div');
		spinner.id = "spinner";
		spinner.className = "spinner-div";
		iconToUpdate.appendChild(spinner);
	}
	
}
export function printMaps(organism) {
	let keggListUl = document.getElementById("mapsListUlkegg");
	let wpListUl = document.getElementById("mapsListUlwikipathways");
	// keggListUl.innerHTML = "";
	mapsCheck[organism].filter((d) => ((!d.imgAvailable || !d.fileAvailable) && d.db === "kegg"))
		.map((map) => {
			keggListUl.appendChild(mapLi(map));
	})
	mapsCheck[organism].filter((d) => ((d.imgAvailable && d.fileAvailable) && d.db === "kegg"))
		.map((map) => {
			keggListUl.appendChild(mapLi(map));
	})
	mapsCheck[organism].filter((d) => ((!d.imgAvailable || !d.fileAvailable) && d.db === "wikipathways"))
		.map((map) => {
			wpListUl.appendChild(mapLi(map));
	})
	mapsCheck[organism].filter((d) => ((d.imgAvailable && d.fileAvailable) && d.db === "wikipathways"))
		.map((map) => {
			wpListUl.appendChild(mapLi(map));
	})
}



// buttons
function downloadMapsButton(organism,db) {
	let button = document.createElement('button');
	button.className = "download-button";
	button.innerText = "Download";
	button.onclick = function() { downloadMaps(organism,db); };
	return(button);
}


//display each db status and availability
export function boxDBDiv (db) {

	let titleDiv = document.createElement('b');
	titleDiv.className = 'source-db-title';

	let text = document.createElement('b');
	text.innerText = typeToTitle[db.infoType];

	let img = document.createElement('img');
	img.className = "source-db-icon";
	img.src = db.imgSrc;
	
	let div = document.createElement('div');
	div.className = "source-db-box";
	div.style.backgroundColor = db.available ? "#DFF0D8" : "#F7CCC9";

	let iconDiv = document.createElement('div');
	iconDiv.innerHTML = 
		db.available ? '<i class="material-icons-outlined" id="check-icon">check_circle_outline</i>' 
		: '<i class="material-icons-outlined" id="error-icon">error_outline</i>';

	titleDiv.appendChild(text);
	div.appendChild(titleDiv);	
	div.appendChild(img);
	iconDiv.id = `${db.infoType}-box-icon`;
	div.appendChild(iconDiv);
	div.id = `${db.infoType}-box`;
	return(div);
}
export function displayDBStatus(organism) {
	cleanUp("dbBoxes");
	integrityCheck[organism].filter((db) => (db.type === "interaction")).map((db) => {
		document.getElementById("dbBoxes").appendChild(boxDBDiv(db));
	});
}



export function cleanUp (divID){
	// Clear previous result
	var div = document.getElementById(divID);
	div.innerHTML = '';
}
