import { integrityCheck, organismCodes, paths, forkedProcesses, requestQueueDBs } from './global.js';
import { updateResultsContainer, displayDBStatus, cleanUp} from './InterfaceUtils.js';
import { checkMapsExistence, getRequest } from './MapsRequests.js'

// check integrity
async function checkFileExistence(organism) {
	try {
		console.log("checkFileExistence: "+organism)
		var selectedSpecies = organism;
		paths.interactionDBPath = `pathlay_data/${organismCodes[selectedSpecies]}/db/`;
		console.log(paths.interactionDBPath);
		let response = await getRequest(`file_checker.pl?organism=${selectedSpecies}`);
		const formatFileData = (file, type, available) => ({
			id: file.id,
			required: file.required === "true",
			useProxy: file.useProxy === "true",
			useFork: file.useFork === "true",
			type: type,
			available: available,
			imgSrc: file.imgSrc,
			fileSrc: file.fileSrc,
			infoType: file.infoType,
			fileName: file.fileName
		});
		
		const interactionFiles = [
			...response.interactionFiles.present.map(file => formatFileData(file, "interaction", true)),
			...response.interactionFiles.missing.map(file => formatFileData(file, "interaction", false))
		];
		
		integrityCheck[organism] = [...interactionFiles];
		
		// console.log(response);
		console.log(integrityCheck[organism]);
		
		checkForDBIntegrity(selectedSpecies);
		displayDBStatus(selectedSpecies);
	} catch (error) {
		console.log(error)
		updateResultsContainer("serverError",organism);

	}
}
// function checkMapsExistence(organism) {
// 	console.log("checkMapsExistence")
// 	cleanUp("mapsListUlkegg");
// 	cleanUp("mapsListUlwikipathways");
// 	updateBoxMapStatus("kegg",organism,"loading");
// 	updateBoxMapStatus("wikipathways",organism,"loading");
// 	var selectedSpecies = this.value ? this.value : organism;
// 	var xhttp = new XMLHttpRequest();
// 	xhttp.onreadystatechange = function() {
// 		if (this.readyState !== 4) return;
// 		try {
// 			const response = JSON.parse(this.responseText);
// 			console.log(response);
// 			const formatMapsData = (map) => ({
// 				id : map.id,
// 				name : map.name,
// 				organism : organism,
// 				db : map.db,
// 				fileUrl : map.fileUrl,
// 				imgUrl: map.imgUrl,
// 				fileAvailable: map.fileAvailable === "true",
// 				imgAvailable: map.imgAvailable === "true",
// 				required : map.required === "true"
// 			});
// 			const formatFileData = (file, type, available) => ({
// 				id: file.id,
// 				required: file.required === "true",
// 				useProxy: file.useProxy === "true",
// 				type: type,
// 				available: available,
// 				imgSrc: file.imgSrc,
// 				fileSrc: file.fileSrc,
// 				infoType: file.infoType
// 			});
// 			const mapDBFiles = [
// 				...response.mapDBFiles.present.map(file => formatFileData(file, "mapDB", true)),
// 				...response.mapDBFiles.missing.map(file => formatFileData(file, "mapDB", false))
// 			];
// 			const mapFiles = [
// 				...response.pathwayFiles.map(map => formatMapsData(map)),
// 			];
// 			integrityCheck[organism] = [ ...mapDBFiles];
// 			mapsCheck[organism] = [...mapFiles];
// 			console.log(response);
// 			console.log(integrityCheck[organism]);
// 			printMaps(selectedSpecies);
// 			let keggStatus = checkMapsStatus(selectedSpecies,"kegg");
// 			let wpStatus = checkMapsStatus(selectedSpecies,"wikipathways");
// 			updateBoxMapStatus("kegg",organism,keggStatus);
// 			updateBoxMapStatus("wikipathways",organism,wpStatus);
// 		} catch (e) {
// 			console.log("Error parsing response: " + e.message);
// 		}

// 	}
// 	xhttp.open("GET", "maps_checker.pl?organism=" + selectedSpecies, true);
// 	xhttp.send();
// }
// async function getRequest(url) {
//   return new Promise((resolve, reject) => {
//     var xhttp = new XMLHttpRequest();
//     xhttp.onreadystatechange = function() {
//       if (this.readyState !== 4) return;

//       if (this.status >= 200 && this.status < 300) {
//         try {
//           const response = JSON.parse(this.responseText);
// 					console.log(response);
//           resolve(response);
//         } catch (e) {
//           console.error(e);
//           reject(e);
//         }
//       } else {
//         reject(new Error('Request failed with status code ' + this.status));
//       }
//     };

//     xhttp.open("GET", url, true);
//     xhttp.send();
//   });
// }

// async function checkMapsExistence(organism,dbId) {
// 	try {
// 		console.log("checkMapsExistence")
// 		cleanUp(`mapsListUl${dbId}`);
// 		updateBoxMapStatus(dbId,organism,"loading");
// 		let response = await getRequest(`maps_checker.pl?organism=${organism}&db=${dbId}`);
// 		const formatMapsData = (map) => ({
// 			id : map.id,
// 			name : map.name,
// 			organism : organism,
// 			db : map.db,
// 			fileUrl : map.fileUrl,
// 			imgUrl: map.imgUrl,
// 			fileAvailable: map.fileAvailable === "true",
// 			imgAvailable: map.imgAvailable === "true",
// 			required : map.required === "true"
// 		});
// 		const formatFileData = (file, type, available) => ({
// 			id: file.id,
// 			required: file.required === "true",
// 			useProxy: file.useProxy === "true",
// 			type: type,
// 			available: available,
// 			imgSrc: file.imgSrc,
// 			fileSrc: file.fileSrc,
// 			infoType: file.infoType
// 		});
// 		const mapDBFiles = [
// 			...response.mapDBFiles.present.map(file => formatFileData(file, "mapDB", true)),
// 			...response.mapDBFiles.missing.map(file => formatFileData(file, "mapDB", false))
// 		];
// 		const mapFiles = [
// 			...response.pathwayFiles.map(map => formatMapsData(map)),
// 		];
// 		integrityCheck[organism] = [ ...mapDBFiles];
// 		mapsCheck[organism] = [...mapFiles];
// 		printMaps(organism);
// 		let status = checkMapsStatus(organism,dbId);
// 		updateBoxMapStatus(dbId,organism,status);
// 	} catch (error) {
// 		console.log("Error: "+error);
// 	}
// }
// print maps available and missing

// function printMaps(organism) {
// 	let keggListUl = document.getElementById("mapsListUlkegg");
// 	let wpListUl = document.getElementById("mapsListUlwikipathways");
// 	// keggListUl.innerHTML = "";
// 	mapsCheck[organism].filter((d) => ((!d.imgAvailable || !d.fileAvailable) && d.db === "kegg"))
// 		.map((map) => {
// 			keggListUl.appendChild(mapLi(map));
// 	})
// 	mapsCheck[organism].filter((d) => ((d.imgAvailable && d.fileAvailable) && d.db === "kegg"))
// 		.map((map) => {
// 			keggListUl.appendChild(mapLi(map));
// 	})
// 	mapsCheck[organism].filter((d) => ((!d.imgAvailable || !d.fileAvailable) && d.db === "wikipathways"))
// 		.map((map) => {
// 			wpListUl.appendChild(mapLi(map));
// 	})
// 	mapsCheck[organism].filter((d) => ((d.imgAvailable && d.fileAvailable) && d.db === "wikipathways"))
// 		.map((map) => {
// 			wpListUl.appendChild(mapLi(map));
// 	})
// }
// async function downloadMaps(organism,db) {

// 	updateBoxMapStatus(db,organism,"download");

// 	// var list = [];
// 	// mapsCheck[organism].filter((d) => ((!d.imgAvailable || !d.fileAvailable) && d.db === db))
// 	// 	.map((map) => {
// 	// 		//query for download here
// 	// 		enqueueUploadMap(organism,map);
// 	// })
// 	// if (Array.from(requestQueueMaps.immediateRequests).length === 0) {
// 	// 	updateBoxMapStatus(map.db,organism,"ok");
// 	// }
// 	// Filter out maps that need downloading and belong to the specified db
// 	let mapsToDownload = mapsCheck[organism].filter((d) => 
// 		(!d.imgAvailable || !d.fileAvailable) && d.db === db
// 	);

// 	// Enqueue all maps that need to be downloaded
// 	const immediateRequests = mapsToDownload.map(async (map) => {
// 		await enqueueUploadMap(organism, map);
// 	});

// 	// Wait for all the enqueued immediate requests to complete
// 	await Promise.all(immediateRequests);

// 	// After all immediate requests complete, check the length
// 	if (Array.from(requestQueueMaps.immediateRequests).length === 0) {
// 		updateBoxMapStatus(db, organism, "ok");
// 	}
// }

// function checkMapsStatus (organism,db) {
// 	let mapsToCheck = mapsCheck[organism].filter((d) => (d.db === db));
// 	let errorMaps = mapsToCheck.filter((d) => (!d.imgAvailable || !d.fileAvailable));
// 	let okMaps = mapsToCheck.filter((d) => (d.imgAvailable && d.fileAvailable));


// 	let	status = 
// 		okMaps.length === mapsToCheck.length ? "ok" :
// 		errorMaps.length === mapsToCheck.length ? "error" :
// 		"warning";

// 	return(status);
// }

// function updateBoxMapStatus (db,organism,status) {
// 	console.log(`Updating Box Maps Status: ${db} ${organism} ${status}`);
// 	cleanUp(`statusBoxMaps${db}`);




// 	let box = document.getElementById(`statusBoxMaps${db}`);
// 	box.className = "result-container";
// 	// box.className += 
// 	// 	status === "ok" ? " ok-message" :
// 	// 	status === "error" ? " error-message" :
// 	// 	" warning-message";

// 	if (status === "ok") {
// 		box.appendChild(statusDiv(`${db}-okMessage`,"ok","All maps are downloaded!"));
// 	}
// 	if (status === "warning") {
// 		box.appendChild(statusDiv(`${db}-warningMessage`,"warning","Some maps were not found!"));
// 		let messageDiv = box.querySelector('div')
// 		let buttonDiv = document.createElement('div');
// 		buttonDiv.className = "status-message-button-div";
// 		buttonDiv.appendChild(downloadMapsButton(organism,db));
// 		messageDiv.appendChild(buttonDiv);
// 	}
// 	if (status === "error") {
// 		box.appendChild(statusDiv(`${db}-errorMessage`,"error","Some maps were not found!"));
// 		let messageDiv = box.querySelector('div')
// 		let buttonDiv = document.createElement('div');
// 		buttonDiv.className = "status-message-button-div";
// 		buttonDiv.appendChild(downloadMapsButton(organism,db));
// 		messageDiv.appendChild(buttonDiv);
// 	}
// 	if (status === "download") {
// 		box.appendChild(statusDiv(`${db}-loadingMessage`, "download", "Downloading files..."));
// 	}
// 	if (status === "loading") {
// 		box.appendChild(statusDiv(`${db}-loadingMessage`, "loading", "Checking files..."));
// 	}
// }

// async function enqueueUploadMap(organism, map) {
// 	return new Promise((resolve, reject) => {
// 		requestQueueMaps.enqueueImmediate(async () => {
// 			try {
// 				const formData = new FormData();
// 				formData.append('organism', organism);
// 				formData.append('mapDB', map.db);
// 				formData.append('mapID', map.id);
// 				formData.append('imgAvailable', map.imgAvailable);
// 				formData.append('fileAvailable', map.fileAvailable);
// 				formData.append('imgUrl', map.imgUrl);
// 				formData.append('fileUrl', map.fileUrl);

// 				const uploadResponse = await fetch('get_map.pl', {
// 					method: 'POST',
// 					body: formData
// 				});

// 				updateLiStatus(map, 'loading');

// 				if (!uploadResponse.ok) {
// 					const errorBody = await uploadResponse.text();
// 					updateLiStatus(map, 'error');
// 					// Reject the promise with an error
// 					reject(new Error(`Upload failed with status: ${uploadResponse.status} - ${errorBody}`));
// 				} else {
// 					const json = await uploadResponse.json();
// 					console.log(json);
// 					map.fileAvailable = json.fileAvailable;
// 					map.imgAvailable = json.imgAvailable;
// 					updateLiStatus(map, (map.imgAvailable == "true" && map.fileAvailable == "true") ? 'ok' : 'error');
// 					console.log(Array.from(requestQueueMaps.immediateRequests).length);
// 					// Resolve the promise on successful upload
// 					resolve();
// 				}
// 			} catch (error) {
// 				// Catch any unexpected errors and reject the promise
// 				updateLiStatus(map, 'error');
// 				reject(error);
// 			}
// 		});
// 	});
// }



// function downloadMapsButton(organism,db) {
// 	let button = document.createElement('button');
// 	button.className = "download-button";
// 	button.innerText = "Download";
// 	button.onclick = function() { downloadMaps(organism,db); };
// 	return(button);
// }
function downloadDBsButton(organism) {
	let button = document.createElement('button');
	button.className = "download-button";
	button.innerText = "Download";
	button.onclick = function() { downloadMissing(organism); };
	return(button);
}



// function mapLi(map){
// 	let li = document.createElement('li');
// 	li.id = `${map.id}-li`;
// 	li.className = "mapLi";
// 	let divBox = document.createElement('div');
// 	let divText = document.createElement('div');
// 	let divIcon = document.createElement('div');
	
// 	li.className += (!map.imgAvailable || !map.fileAvailable) ? " error-message" : " ok-message"; 
// 	divBox.className = 'li-div-box';
// 	divBox.id = `${map.id}-li-box`;
// 	divText.className = 'li-div';
// 	divText.id = `${map.id}-li-text`;
// 	divIcon.className = 'li-div';
// 	divIcon.id = `${map.id}-li-icon`;

// 	let iconHtml = map.imgAvailable && map.fileAvailable ? 
// 		'<i class="material-icons-outlined" id="check-icon">check_circle_outline</i>'
// 		: '<i class="material-icons-outlined" id="error-icon">error_outline</i>';
// 	;

// 	divIcon.innerHTML = iconHtml;
// 	divText.innerText = `${map.name} (${map.id})`;
// 	divBox.appendChild(divText);
// 	divBox.appendChild(divIcon);
// 	li.appendChild(divBox);
// 	return(li)
// }

// function updateLiStatus(map,status) {
// 	let iconToUpdate = document.getElementById(`${map.id}-li-icon`);
// 	let liToUpdate = document.getElementById(`${map.id}-li`);
// 	iconToUpdate.innerHTML = '';
// 	newHtml = 
// 		status === 'ok' ? '<i class="material-icons-outlined" id="check-icon">check_circle_outline</i>' :
// 		status === 'error' ? '<i class="material-icons-outlined" id="error-icon">error_outline</i>' :
// 		'';
// 	iconToUpdate.innerHTML = newHtml;
// 	liToUpdate.className = "mapLi";
// 	liToUpdate.className += 
// 		status === 'error' ? " error-message" : 
// 		status === 'ok' ? " ok-message" :
// 		' warning-message';
// 	if (status === 'loading') {
// 		let spinner = document.createElement('div');
// 		spinner.id = "spinner";
// 		spinner.className = "spinner-div";
// 		iconToUpdate.appendChild(spinner);
// 	}
	
// }
//download
function downloadMissing(organism) {

	//update result container here

	integrityCheck[organism].filter((d) => (!d.available && d.required))
		.map((file) => {
			requestQueueDBs.enqueueImmediate(() => downloadAndSaveFile(file.fileSrc,file.fileName,organism,file.infoType,file.type,file.useProxy,file.useFork));
	})
}

function checkStatus(fileID,type) {
	console.log(forkedProcesses);
	fetch(`${interactionDBPath}${fileID}.status.json`)
		.then(response => response.json())
		.then(data => {
				if (data.status === 'complete') {
						console.log('Process completed.');
						removePID(type);
				} else if (data.status === 'error') {
						console.log('Process exited with error.');
						removePID(type);
				} else if (data.status === 'processing') {
						console.log('Process ongoing.');
				} else if (data.status === 'downloading') {
					console.log('Downloading.');
				} else {
					console.log('Unknown status');
				}
				storePID(data.file,type,data.pid);
		})
		.catch(error => {
				console.error('Error checking status:', error);
		});
}
function storePID(fileID,type,pid) {
	if (!pid) {
		return;
	}
	if (forkedProcesses.filter((p) => (p.pid === pid)).length == 0) {
		forkedProcesses.push(
			{
				fileID : fileID,
				fileType : type,
				pid : pid
			}
		);
	}
}
function removePID(type) {
	console.log("Removing process data from memory");
	let toRemove = forkedProcesses.filter((p) => (p.fileType === type));
	toRemove.forEach(obj => {
    let index = forkedProcesses.indexOf(obj);
    if (index !== -1) {
			forkedProcesses.splice(index, 1);
    }
	});
	console.log(forkedProcesses);
}

async function downloadAndSaveFile(url,id, organism, type,type2, useProxy, useFork, retryCount = 5) {
	
	// need to update integritycheck when the file is downloaded (all post request resolved)
	console.log("Downloading from " + url);
	console.log("Using Proxy: " + useProxy);
	console.log("Using Fork: " + useFork);
	
	updateBoxDBDivStatus(`${type}-box`, "download");
	cleanUp(`${type}-box-icon`);
	updateBoxDBDivIcon(`${type}-box-icon`,type,"download",useProxy);
	updateResultsContainer('loading',organism)

	try {
		// Step 0: Prepare Form for POST
		const formData = new FormData();
		formData.append('organism', organism);
		formData.append('dbType', type);
		
		// Step 1: Download the file with progress tracking if proxy not required
		if (!useProxy) {
				const blob = await downloadFileWithProgress(url, type);
				formData.append('file', blob, `${organism}_${type}.tmp`);
		} else {
				formData.append('url', url);
				formData.append('type',type2);
		}
		if (useFork) {
			formData.append('useFork',true);
		} else {
			formData.append('useFork',false);
		}
		// Step 2: Upload the file to the server
		const uploadResponsePromise = fetch('prepare_db.pl', {
			method: 'POST',
			body: formData
		});

		if (useFork) {
			var intervalID = setInterval(() => checkStatus(id,type), 5000);    
		}
		const uploadResponse = await uploadResponsePromise;
		if (useFork) {
			console.log("Clearing interval.")
			clearInterval(intervalID);
			removePID(type);
		}
		console.log(uploadResponse);
		if (!uploadResponse.ok) {
			throw new Error(`Upload failed with status: ${uploadResponse.status}`);
		}
		if (!useProxy) {
			updateProgressBar(100, `${type}-progressBar`);
			console.log('File successfully uploaded.');
		} else {
			cleanUp(`${type}-box-icon`);
		}
		updateBoxDBDivIcon(`${type}-box-icon`,type,"ok",useProxy);
		updateBoxDBDivStatus(`${type}-box`, "ok");
		let toUpdateStatus = integrityCheck[organism].find(obj => obj.infoType === type);
		toUpdateStatus.available = true;
		checkForDBIntegrity(organism); 

	} catch (error) {
			console.error('Operation failed:', error);
			if (!useProxy) {
				updateProgressBar(0, `${type}-progressBar`);
			} else {
				cleanUp(`${type}-box-icon`);
				updateBoxDBDivIcon(`${type}-box-icon`,type,"error",useProxy);
			}
			updateBoxDBDivStatus(`${type}-box`, "error");

			// Retry logic
			if (retryCount > 0 && !useProxy) {
					console.log(`Retrying... (${retryCount} attempts left)`);
					await new Promise(resolve => setTimeout(resolve, 1000));  // Adding a delay before retry
					downloadAndSaveFile(url,id, organism, type,type2, useProxy, useFork, retryCount - 1);
			} else {
					console.error('All retry attempts failed.');
			}
	}
}


async function downloadFileWithProgress(url, type) {
	console.log("Downloading from " + url);

	const response = await fetch(url);
	if (!response.ok) {
			throw new Error(`Download failed with status: ${response.status}`);
	}
	console.log("Response:", response);

	const contentLength = response.headers.get('content-length');
	const totalBytes = contentLength ? parseInt(contentLength, 10) : null;

	if (totalBytes === null) {
			console.warn('Content-Length header is missing. Progress tracking will be disabled.');
	}

	let loadedBytes = 0;
	const reader = response.body.getReader();

	const stream = new ReadableStream({
			start(controller) {
					function push() {
							reader.read().then(({ done, value }) => {
									if (done) {
											controller.close();
											return;
									}
									if (value) {
											loadedBytes += value.byteLength;
											if (totalBytes) {
													updateProgressBar((loadedBytes / totalBytes) * 100, `${type}-progressBar`);
											}
											controller.enqueue(value);
									}
									push();
							}).catch(error => {
									console.error('Stream reading error:', error);
									controller.error(error);
							});
					}
					push();
			},
			cancel(reason) {
					console.error('Stream canceled:', reason);
			}
	});

	const responseStream = new Response(stream);
	const blob = await responseStream.blob();
	console.log("File Downloaded:", blob);

	return blob;
}


function updateProgressBar(percentComplete,id) {
	const progressBar = document.getElementById(id);
	progressBar.style.width = percentComplete + '%';
	progressBar.textContent = Math.floor(percentComplete) + '%';
}



// //display each db status and availability
// function displayDBStatus(organism) {
// 	cleanUp("dbBoxes");
// 	integrityCheck[organism].filter((db) => (db.type === "interaction")).map((db) => {
// 		document.getElementById("dbBoxes").appendChild(boxDBDiv(db));
// 	});
// }

// display overall db status for organism
function checkForDBIntegrity(organism) {

	// Clear previous result
	if (integrityCheck[organism].filter((file) => (!file.available)).length === 0) {
		updateResultsContainer("ok",organism);
	} else if (requestQueueDBs.getActiveImmediateRequests().length !== 0) {
		updateResultsContainer("loading",organism);
	} else {
		updateResultsContainer("dbError",organism);
		// include the following into updateResultsContainer
		let messageDiv = resultContainer.querySelector('div')
		let buttonDiv = document.createElement('div');
		buttonDiv.className = "status-message-button-div";
		buttonDiv.appendChild(downloadDBsButton(organism));
		messageDiv.appendChild(buttonDiv);
	}
}



// onload calls
document.addEventListener("DOMContentLoaded", function() {
	// document.getElementById('species').addEventListener('change',displayOrganismStatus)
	// document.getElementById('species').addEventListener('change',(event) => {checkFileExistence(event.target.value)});
	// document.getElementById('species').addEventListener('change',(event) => {checkMapsExistence(event.target.value)});
	document.getElementById('species').value = "homo_sapiens";

	document.getElementById("fileCheckerButton").addEventListener('click',() => {checkFileExistence(document.getElementById('species').value)});
	document.getElementById("mapsCheckerButton").addEventListener('click',() => {
		checkMapsExistence(document.getElementById('species').value,'kegg');
		checkMapsExistence(document.getElementById('species').value,'wikipathways')
	});
});
window.addEventListener('beforeunload', (event) => {
	var pids = forkedProcesses.map((p) => (p.pid));
	if (pids.length === 0) {
		return
	}
	
	event.preventDefault();
    
	// Send an AJAX request to the server to terminate the processes
	var xhr = new XMLHttpRequest();
	xhr.open('POST', 'cgi-bin/terminate_process.pl', true); // Adjust the URL as needed
	xhr.setRequestHeader('Content-Type', 'application/json');

	// Example of sending process IDs; in practice, you would fetch this dynamically
	xhr.send(JSON.stringify({ action: 'terminate', pids: pids }));
});


//build custom div for db status

// function statusDiv (id,status,message) {
// 	var div = document.createElement('div');
// 	div.id = id;
// 	div.className = "status-div";
// 	div.className += 
// 		status === "ok" ?  " ok-message" : 
// 		status === "error" ? " error-message" : 
// 		status === "loading" || status === "warning" ? " warning-message" : 
// 		" neutral-message";
// 	var divMessage = document.createElement('div');
// 	divMessage.className = "status-message-div"; 
// 	var divIcon = document.createElement('div');
// 	divIcon.className = status === "loading" ? "status-icon-loading" : "status-icon-div";
// 	divMessage.innerHTML = `<b>${message}</b>`;
// 	divIcon.innerHTML = 
// 		status === "ok" ? '<i class="material-icons-outlined" id="check-icon">check_circle_outline</i>' :
// 		status === "error" || status === "warning" ? '<i class="material-icons-outlined" id="error-icon">error_outline</i>' :
// 		"";
// 	if (status === "loading" || status === "download") {
// 		let spinner = document.createElement('div');
// 		spinner.id = "spinner";
// 		spinner.className = "spinner-div";
// 		divIcon.appendChild(spinner)
// 	}
// 	let messageWrap = document.createElement('div');
// 	messageWrap.className = "status-message-info-div";

// 	messageWrap.appendChild(divMessage);
// 	messageWrap.appendChild(divIcon);
// 	div.appendChild(messageWrap);
// 	return(div);
// }
// function boxDBDiv (db) {

// 	let titleDiv = document.createElement('b');
// 	titleDiv.className = 'source-db-title';

// 	let text = document.createElement('b');
// 	text.innerText = typeToTitle[db.infoType];

// 	let img = document.createElement('img');
// 	img.className = "source-db-icon";
// 	img.src = db.imgSrc;
	
// 	let div = document.createElement('div');
// 	div.className = "source-db-box";
// 	div.style.backgroundColor = db.available ? "#DFF0D8" : "#F7CCC9";

// 	let iconDiv = document.createElement('div');
// 	iconDiv.innerHTML = 
// 		db.available ? '<i class="material-icons-outlined" id="check-icon">check_circle_outline</i>' 
// 		: '<i class="material-icons-outlined" id="error-icon">error_outline</i>';

// 	titleDiv.appendChild(text);
// 	div.appendChild(titleDiv);	
// 	div.appendChild(img);
// 	iconDiv.id = `${db.infoType}-box-icon`;
// 	div.appendChild(iconDiv);
// 	div.id = `${db.infoType}-box`;
// 	return(div);
// }

function updateBoxDBDivStatus (id,status) {
	let div = document.getElementById(id);
	div.style.backgroundColor = status === "ok" ? "#DFF0D8" : status === "error" ? "#F7CCC9" : status === "download" ? "#F9F06B" : "";
}
function updateBoxDBDivIcon (id,type,status,useProxy) {
	let div = document.getElementById(id);

	let spinner = document.createElement('div');
	spinner.id = "spinner";
	spinner.className = "spinner-div";


	if (status === "download") {
		div.appendChild(!useProxy ? progressBar(type) : spinner);
	}
	if (status === "ok") {
		if (!useProxy) {
			let progressBar = document.getElementById(`${type}-progressContainer`);
			progressBar.remove();
		}
		div.innerHTML = '<i class="material-icons-outlined" id="check-icon">check_circle_outline</i>';
	}
	if (status === "error") {
		if (!useProxy) {
			let progressBar = document.getElementById(`${type}-progressContainer`);
			progressBar.remove();
		}
		div.innerHTML = '<i class="material-icons-outlined" id="check-icon">check_circle_outline</i>';
	}
}


function progressBar(type) {
	cleanUp(`${type}-box-icon`);
	let container = document.createElement("div");
	let div = document.createElement("div");
	container.id = `${type}-progressContainer`;
	container.className = "progressContainer";
	div.id = `${type}-progressBar`;
	div.className = "progressBar";
	container.appendChild(div);
	return(container);
}
// function cleanUp (divID){
// 	// Clear previous result
// 	var div = document.getElementById(divID);
// 	div.innerHTML = '';
// }
