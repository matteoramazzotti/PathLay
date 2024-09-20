import { integrityCheck, organismCodes, paths, fork, requestQueueDBs } from './global.js';
import { updateResultsContainer, displayDBStatus, cleanUp, downloadDBsButton} from './InterfaceUtils.js';
import { checkMapsExistence, getRequest } from './MapsRequests.js'

// check 

async function grantAccess() {
	try {
		let response = await getRequest(`checkClient.pl`);
		return response.accessGranted === "true" ? true : false;
	} catch(error) {
		console.log(error);
		return false;
	}
}


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

//download
export function downloadMissing(organism) {

	//update result container here

	integrityCheck[organism].filter((d) => (!d.available && d.required))
		.map((file) => {
			requestQueueDBs.enqueueImmediate(() => downloadAndSaveFile(file.fileSrc,file.fileName,organism,file.infoType,file.type,file.useProxy,file.useFork));
	})
}

function checkStatus(fileID,type) {
	console.log(fork.forkedProcesses);
	fetch(`../${paths.interactionDBPath}${fileID}.status.json`)
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
	if (fork.forkedProcesses.filter((p) => (p.pid === pid)).length == 0) {
		fork.forkedProcesses.push(
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
	let toRemove = fork.forkedProcesses.filter((p) => (p.fileType === type));
	toRemove.forEach(obj => {
    let index = fork.forkedProcesses.indexOf(obj);
    if (index !== -1) {
			fork.forkedProcesses.splice(index, 1);
    }
	});
	console.log(fork.forkedProcesses);
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
		let resultContainer = document.getElementById('resultContainer');
		let messageDiv = resultContainer.querySelector('div');
		let buttonDiv = document.createElement('div');
		buttonDiv.className = "status-message-button-div";
		buttonDiv.appendChild(downloadDBsButton(organism));
		messageDiv.appendChild(buttonDiv);
	}
}



// onload calls
function getQueryParam(param) {
	const urlParams = new URLSearchParams(window.location.search);
	return urlParams.get(param);
}
document.addEventListener("DOMContentLoaded", async function() {
	try {
		let access = await grantAccess();
		if (!access) {
			let sid = getQueryParam("sid");
			document.body.innerHTML = '';
			let errorPage = `
				<div style="text-align: center; margin-top: 20%;">
					<h1 style="color: red;">Access Denied</h1>
					<p>You do not have permission to view this page.</p>
					<button id="goBackButton" ">Go Back</button>
				</div>
			`;
			document.body.innerHTML = errorPage;
			document.getElementById("goBackButton").addEventListener('click', () => {
				const baseUrl = `${window.location.protocol}//${window.location.host}${window.location.pathname}`;
				let newUrl = `${baseUrl.replace('pathlayDBConf.pl', 'welcome.pl')}?sid=${sid}`;
				window.location.href = newUrl;
			})
		} else {
			document.getElementById('species').value = "homo_sapiens";
			document.getElementById("fileCheckerButton").addEventListener('click',() => {
				checkFileExistence(document.getElementById('species').value)
			});
			document.getElementById("mapsCheckerButton").addEventListener('click',() => {
				checkMapsExistence(document.getElementById('species').value,'kegg');
				checkMapsExistence(document.getElementById('species').value,'wikipathways');
			});
		}
	} catch(error) {
		console.log(error)
	}
});
window.addEventListener('beforeunload', (event) => {
	var pids = fork.forkedProcesses.map((p) => (p.pid));
	if (pids.length === 0) {
		return;
	}
	var payload = JSON.stringify({ action: 'terminate', pids: pids });
	navigator.sendBeacon('terminate_process.pl', payload);
	event.preventDefault();
	event.returnValue = ''; // Modern browsers ignore custom text
});





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