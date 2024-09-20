import { updateBoxMapStatus,updateLiStatus, cleanUp, printMaps } from './InterfaceUtils.js';
import { requestQueueMaps, mapsCheck, integrityCheck } from './global.js';

// generic requests

export async function getRequest(url) {
  return new Promise((resolve, reject) => {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
      if (this.readyState !== 4) return;

      if (this.status >= 200 && this.status < 300) {
        try {
          const response = JSON.parse(this.responseText);
					console.log(response);
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


//maps requests
export async function checkMapsExistence(organism,dbId) {
	try {
		console.log("checkMapsExistence")
		cleanUp(`mapsListUl${dbId}`);
		updateBoxMapStatus(dbId,organism,"loading");
		let response = await getRequest(`maps_checker.pl?organism=${organism}&db=${dbId}`);
		const formatMapsData = (map) => ({
			id : map.id,
			name : map.name,
			organism : organism,
			db : map.db,
			fileUrl : map.fileUrl,
			imgUrl: map.imgUrl,
			fileAvailable: map.fileAvailable === "true",
			imgAvailable: map.imgAvailable === "true",
			required : map.required === "true"
		});
		const formatFileData = (file, type, available) => ({
			id: file.id,
			required: file.required === "true",
			useProxy: file.useProxy === "true",
			type: type,
			available: available,
			imgSrc: file.imgSrc,
			fileSrc: file.fileSrc,
			infoType: file.infoType
		});
		const mapDBFiles = [
			...response.mapDBFiles.present.map(file => formatFileData(file, "mapDB", true)),
			...response.mapDBFiles.missing.map(file => formatFileData(file, "mapDB", false))
		];
		const mapFiles = [
			...response.pathwayFiles.map(map => formatMapsData(map)),
		];
		
		integrityCheck[organism] = [ ...mapDBFiles];
		mapsCheck[organism] = [...(mapsCheck[organism] || []), ...mapFiles];
		printMaps(organism);
		let status = checkMapsStatus(organism,dbId);
		updateBoxMapStatus(dbId,organism,status);
	} catch (error) {
		console.log("Error: "+error);
	}
}
function checkMapsStatus (organism,db) {
	let mapsToCheck = mapsCheck[organism].filter((d) => (d.db === db));
	let errorMaps = mapsToCheck.filter((d) => (!d.imgAvailable || !d.fileAvailable));
	let okMaps = mapsToCheck.filter((d) => (d.imgAvailable && d.fileAvailable));


	let	status = 
		okMaps.length === mapsToCheck.length ? "ok" :
		errorMaps.length === mapsToCheck.length ? "error" :
		"warning";

	return(status);
}
export async function downloadMaps(organism,db) {

	console.log(db);
	console.log(organism);
	updateBoxMapStatus(db,organism,"download");

	// var list = [];
	// mapsCheck[organism].filter((d) => ((!d.imgAvailable || !d.fileAvailable) && d.db === db))
	// 	.map((map) => {
	// 		//query for download here
	// 		enqueueUploadMap(organism,map);
	// })
	// if (Array.from(requestQueueMaps.immediateRequests).length === 0) {
	// 	updateBoxMapStatus(map.db,organism,"ok");
	// }
	// Filter out maps that need downloading and belong to the specified db
	let mapsToDownload = mapsCheck[organism].filter((d) => 
		(!d.imgAvailable || !d.fileAvailable) && d.db === db
	);
	console.log(mapsToDownload);
	// Enqueue all maps that need to be downloaded
	const immediateRequests = mapsToDownload.map(async (map) => {
		await enqueueUploadMap(organism, map);
	});

	// Wait for all the enqueued immediate requests to complete
	await Promise.all(immediateRequests);

	// After all immediate requests complete, check the length
	if (Array.from(requestQueueMaps.immediateRequests).length === 0) {
		updateBoxMapStatus(db, organism, "ok");
	}
}
export async function enqueueUploadMap(organism, map) {
	return new Promise((resolve, reject) => {
		requestQueueMaps.enqueueImmediate(async () => {
			try {
				const formData = new FormData();
				formData.append('organism', organism);
				formData.append('mapDB', map.db);
				formData.append('mapID', map.id);
				formData.append('imgAvailable', map.imgAvailable);
				formData.append('fileAvailable', map.fileAvailable);
				formData.append('imgUrl', map.imgUrl);
				formData.append('fileUrl', map.fileUrl);

				const uploadResponse = await fetch('get_map.pl', {
					method: 'POST',
					body: formData
				});

				updateLiStatus(map, 'loading');

				if (!uploadResponse.ok) {
					const errorBody = await uploadResponse.text();
					updateLiStatus(map, 'error');
					// Reject the promise with an error
					reject(new Error(`Upload failed with status: ${uploadResponse.status} - ${errorBody}`));
				} else {
					const json = await uploadResponse.json();
					console.log(json);
					map.fileAvailable = json.fileAvailable;
					map.imgAvailable = json.imgAvailable;
					updateLiStatus(map, (map.imgAvailable == "true" && map.fileAvailable == "true") ? 'ok' : 'error');
					console.log(Array.from(requestQueueMaps.immediateRequests).length);
					// Resolve the promise on successful upload
					resolve();
				}
			} catch (error) {
				// Catch any unexpected errors and reject the promise
				updateLiStatus(map, 'error');
				reject(error);
			}
		});
	});
}

