import { disableInputs } from "../accessUtils.js";

export class CheckInterface {
	constructor() {
		this.submitEnabled = undefined;
		this.omicConfs = {
			gene: {},
			prot: {},
			urna: {},
			meth: {},
			chroma: {},
			meta: {}
		};
		this.defaultConf = {
			meth: {
				LeftEffectSizeCheck: false,
				enabled: true,
				pValCheck: true,
				IdOnlyCheck: true,
				RightEffectSizeCheck: false,
				LeftThreshold: "-1",
				enabledFET: false,
				NoDEFromIdOnlyCheck: true,
				pValThreshold: "0.05",
				RightThreshold: "1",
				nodeg_select: true
			},
			chroma: {
				pValThreshold: "0.05",
				RightThreshold: "1",
				nodeg_select: true,
				LeftEffectSizeCheck: true,
				pValCheck: false,
				IdOnlyCheck: true,
				enabled: true,
				RightEffectSizeCheck: true,
				LeftThreshold: "-1",
				enabledFET: false,
				NoDEFromIdOnlyCheck: false
			},
			FETIntersect: false,
			urna: {
				RightThreshold: "1",
				pValThreshold: "0.05",
				nodeg_select: true,
				enabledFET: false,
				LeftThreshold: "-1",
				RightEffectSizeCheck: true,
				enabled: true,
				IdOnlyCheck: true,
				LeftEffectSizeCheck: true,
				pValCheck: true,
				NoDEFromIdOnlyCheck: false
			},
			prot: {
				IdOnlyCheck: true,
				LeftEffectSizeCheck: true,
				enabled: true,
				enabletfsIdOnly: false,
				enabledFET: false,
				pValThreshold: "0.05",
				enabletfs: false,
				tfsNoDEFromIdOnlyCheck: false,
				pValCheck: false,
				RightEffectSizeCheck: true,
				nodeg_select_tf: false,
				LeftThreshold: "-1",
				RightThreshold: "1"
			},
			gene: {
				enabletfsIdOnly: false,
				enabledFET: false,
				LeftEffectSizeCheck: true,
				enabled: true,
				IdOnlyCheck: true,
				enabletfs: true,
				tfsNoDEFromIdOnlyCheck: false,
				pValThreshold: "0.05",
				LeftThreshold: "-1",
				nodeg_select_tf: false,
				pValCheck: true,
				RightEffectSizeCheck: true,
				RightThreshold: "1"
			},
			mapsDB: "kegg",
			meta: {
				RightThreshold: "1",
				pValThreshold: "0.05",
				RightEffectSizeCheck: true,
				enabled: true,
				pValCheck: true,
				LeftEffectSizeCheck: true,
				IdOnlyCheck: true,
				enabledFET: false,
				LeftThreshold: "-0.5"
			},
			FETPooling: false
		};
		this.currentConf = {};
		this.lastConf = {};
	}
	checkThrInputs = function(omic) {
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
				!this.currentConf.omicConfs[omic][input] && this.currentConf.omicConfs[omic][enabled] ? "error"
				: this.currentConf.omicConfs[omic][input] && this.currentConf.omicConfs[omic][enabled] ? "ok" 
				: "disable";

		});
	};
	handleThrInputs = function(omic) {
		["LeftEffectSize","RightEffectSize","pVal"].forEach((type,i) => {
			console.log(this.omicConfs[omic][type]);
			document.getElementById(`${omic}${type}Threshold`).disabled = 
				this.omicConfs[omic][type] === "disable" ? true 
				: false;
			document.getElementById(`${omic}${type}Threshold`).style.backgroundColor = 
				this.omicConfs[omic][type] === "error" ? "#d15555" 
				: "white";	
		});
	};
	handleSubmit = function() {
		let errorCounter = 0;
		let enabledOmics = 0;

		["gene","prot","urna","meth","chroma","meta"].forEach((omic) => {
			if (this.currentConf.enabledOmics[omic]) {
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
	}
	handleConfEnabled = function() {
		["gene","prot","urna","meth","chroma","meta"].forEach((omic) => {
			["Thr","IdOnly","Tfs","NoDe","FET"].forEach((type) => {
				if (document.getElementById(`${omic}${type}Container`)) {
					!this.currentConf.enabledOmics[omic] ?	disableInputs(`${omic}${type}Container`,true) :
					disableInputs(`${omic}${type}Container`,false);
				}
			});
		});
	}
	handleFETEnabled = function() {
		let statEnabled = 0;
		["gene","prot","urna","meth","chroma","meta"].forEach((omic) => {
			statEnabled += this.currentConf.enabledFETs[omic] ? 1 : 0;
		});
		console.log(statEnabled);
		let disable = statEnabled === 0 ? true : false;
		disableInputs("FETExtraFeatures",disable);
	}
	handleNoDeEnabled = function() {
		['urna','meth','chroma'].forEach((omic) => {
			document.getElementById(`nodeg_select_${omic}`).checked = 
				!this.currentConf.enabledOmics['gene'] && !this.currentConf.enabledOmics['prot'] ? true 
				: this.currentConf.omicConfs[omic].noDeLoadEnabled;
			this.currentConf.updateEnabledNoDeLoaders(omic);
		})
	}
	handleFETPooling = function() {
		let enabledStats = 0;
		['gene','prot','urna','meth','chroma'].forEach((omic) => {
			enabledStats += document.getElementById(`${omic}FETEnabled`).checked && !document.getElementById(`${omic}FETEnabled`).disabled ? 1 : 0;
		})
		let disable = enabledStats > 0 ? false : true;
		disableInputs('FETPoolingLabel',disable);
	}
}