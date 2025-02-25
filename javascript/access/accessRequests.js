// request functions

export async function getRequest(url) {
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
export async function postRequest(query, formData, reloadPage) {
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

export function postForm(actionURL, params) {
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

export async function postJsonAndStock(query, body) {
	return new Promise(async (resolve, reject) => {
		try {
			const response = await fetch(query, {
					method: 'POST',
					headers: {
						"Content-Type": "application/json"
					},
					body: JSON.stringify(body)
			});

			if (response.ok) {
				const result = await response.json();
				sessionStorage.setItem("responseJson", JSON.stringify(result));
				resolve({ result, response });
			} else {
				const error = await response.json();
				reject(new Error(`Error: ${error.message}`));
			}
		} catch (error) {
			console.error('Error:', error);
			reject(new Error('An error occurred'));
		}
	});
}
export function postJsonByForm(action,jsonData) {
	const form = document.createElement("form");
	form.method = "POST";
	form.action = action;

	const input = document.createElement("input");
	input.type = "hidden";
	input.name = "json_data"; 
	input.value = JSON.stringify(jsonData);

	form.appendChild(input);
	document.body.appendChild(form);
	form.submit();
}