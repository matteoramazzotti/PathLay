import { postRequest } from "./accessRequests.js";

// perform requests

export async function performAction(action, exp, currentConf) {
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
			
			return response;
		} catch (error) {
			
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
	if (action === "runLast") {
		const baseUrl = `${window.location.protocol}//${window.location.host}/pathlay/cgi-bin/pathlay.pl`;
		window.location.href = `${baseUrl}?sid=${sid}&exp=${exp}&conf=last`; // this will be in two steps after refactor
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


// generic useful functions

export function getQueryParam(param,url) {
	const urlObj = url ? new URL(url) : window.location;
	const urlParams = new URLSearchParams(urlObj.search);
	return urlParams.get(param);
}
export function convertValuesToBoolean(obj, keysToConvert) {
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
export function disableInputs(divId,disable) {
	var div = document.getElementById(divId);
	console.log(disable);
	// select nested elements within the div
	var elements = div.querySelectorAll('input, textarea, select, button, span');

	elements.forEach(function(element) {
		disableElement(element,disable);
	});
}
export function disableElement(element,disable) {
	element.disabled = disable ? true : false;
	if (element.className === "slider round") {
		if (!disable) {
			element.style.removeProperty('background-color');
		} else {
			element.style.backgroundColor = 'grey';
		}
	}
}