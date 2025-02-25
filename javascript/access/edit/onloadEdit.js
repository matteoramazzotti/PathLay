import { loadPageContent } from './accessUtilsEdit.js';
import { disableInputs } from "../accessUtils.js";
import { ExpConf } from './ExpConf.js';
import { LastConf } from './LastConf.js';
import { CheckInterface } from './CheckInterface.js';
import { CurrentConf } from './CurrentConf.js';
import { PreviewController } from './PreviewController.js';



// configurations on interface
export var expConf = new ExpConf();
export var lastConf = new LastConf();
export var currentConf = new CurrentConf();

// check for errors in the interface

export var checkInterface = new CheckInterface();
checkInterface.expConf = expConf;
checkInterface.currentConf = currentConf;
checkInterface.lastConf = lastConf;

// controller to update and display the preview for each omic
var previewController = new PreviewController();
previewController.currentConf = checkInterface.currentConf;

// onload init
document.addEventListener("DOMContentLoaded", async function() {
	try {
		// console.log("width" + window.innerWidth + "px");
		// console.log("height" + window.innerHeight + "px");
		
		await expConf.checkConfiguration();
		await expConf.loadExpConf();
		await expConf.loadExpData();
		// lastConf = await lastConf.loadLastConf() ? await loadLastConf() : defaultConf;
		await lastConf.loadLastConf();

		loadPageContent(expConf.organism,checkInterface, previewController);
		
		checkInterface.expConf.fillExpGenerics();
		checkInterface.lastConf.fillFETExtras();
		["gene","prot","urna","meth","chroma","meta"].forEach((omic) => {
			checkInterface.lastConf.fillDataCheckBoxes(omic);
			checkInterface.lastConf.fillExpThresholds(omic);
			checkInterface.lastConf.fillFETCheckBoxes(omic);
		});
		["gene","prot"].forEach((omic) => {
			checkInterface.lastConf.fillTfsCheckBoxes(omic);
		});
		["urna","meth","chroma"].forEach((omic) => {
			checkInterface.lastConf.fillNoDeCheckBoxes(omic);
		});
		checkInterface.currentConf.updateAll();
		["gene","prot","urna","meth","chroma","meta"].forEach((omic) => {
			console.log(checkInterface.currentConf);
			previewController.filterData(omic, checkInterface.expConf.expData);
			previewController.displayPreview(omic);
			checkInterface.handleThrInputs(omic);
		});
		
		checkInterface.handleConfEnabled();
		checkInterface.handleSubmit();
		checkInterface.handleFETEnabled();
		checkInterface.handleFETPooling();

		// disable for missing datasets
		["gene","prot","urna","meth","chroma","meta"].forEach((omic) => {
			if (checkInterface.expConf.integrityChecks[omic].idColumn === 0 || !checkInterface.expConf.integrityChecks[omic].idColumn) {
				disableInputs(`enable${omic}Label`,true);
			}
		});

	} catch (error) {
		console.error('Error loading experiment configuration:', error);
	}
})
