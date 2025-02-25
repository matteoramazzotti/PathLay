export class CurrentConf {
	constructor() {
		this.enabledOmics = {
			gene: undefined,
			prot: undefined,
			urna: undefined,
			meth: undefined,
			chroma: undefined,
			meta: undefined
		}
		this.enabledFETs = {
			gene: undefined,
			prot: undefined,
			urna: undefined,
			meth: undefined,
			chroma: undefined,
			meta: undefined
		}
		this.mapDBSelected = undefined,
		this.omicConfs = {
			gene: {},
			prot: {},
			urna: {},
			meth: {},
			chroma: {},
			meta: {},
		}
	}
	updateAll = function() {
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
	}
	updateEnabledOmics = function(omic) {
		this.enabledOmics[omic] = document.getElementById(`enable${omic}`).checked;
	}
	updateSelectedMapDB = function() {
		this.mapDBSelected = document.getElementById('maps_db_select').selectedOptions[0].value;
	}
	updateThresholdValues = function(omic) {
		this.omicConfs[omic].esLeftThr = document.getElementById(`${omic}LeftEffectSizeThreshold`).value;
		this.omicConfs[omic].esRightThr = document.getElementById(`${omic}RightEffectSizeThreshold`).value;
		this.omicConfs[omic].pValThr = document.getElementById(`${omic}pValThreshold`).value;
	}
	updateEnabledThresholds = function(omic) {
		this.omicConfs[omic].esLeftEnabled = document.getElementById(`${omic}LeftEffectSizeCheck`).checked;
		this.omicConfs[omic].esRightEnabled = document.getElementById(`${omic}RightEffectSizeCheck`).checked;
		this.omicConfs[omic].pValEnabled = document.getElementById(`${omic}pValCheck`).checked;
	}
	updateEnabledIdOnly = function(omic) {
		this.omicConfs[omic].idOnlyEnabled = document.getElementById(`${omic}IdOnlyCheck`).checked;
	}
	updateEnabledNoDeLoaders = function(omic) {
		this.omicConfs[omic].noDeLoadEnabled = document.getElementById(`nodeg_select_${omic}`).checked;
	}
	updateEnabledNoDeIdOnlyLoaders = function(omic) {
		this.omicConfs[omic].noDeLoadIdOnlyEnabled = document.getElementById(`${omic}NoDEFromIdOnlyCheck`).checked;
	}
	updateEnabledTFs = function(omic) {
		this.omicConfs[omic].tfEnabled = document.getElementById(`enabletfs_${omic}`).checked;
	}
	updateEnabledIdOnlyTFs = function(omic) {
		this.omicConfs[omic].tfIdOnlyEnabled = document.getElementById(`enabletfsIdOnly_${omic}`).checked;
	}
	updateEnabledNoDeTFsLoaders = function (omic) {
		this.omicConfs[omic].tfNoDeEnabled = document.getElementById(`nodeg_select_tf_${omic}`).checked;
	}
	updateEnabledNoDeIdOnlyTFsLoaders = function (omic) {
		this.omicConfs[omic].tfNoDeIdOnlyEnabled = document.getElementById(`tfsNoDEFromIdOnlyCheck_${omic}`).checked;
	}
	updateEnabledFETs = function (omic) {
		this.enabledFETs[omic] = document.getElementById(`${omic}FETEnabled`).checked;
		let statsEnabled = 0;
		['gene','prot','urna','meth','chroma','meta'].forEach((om) => {
			statsEnabled += this.enabledFETs[om] ? 1 : 0;
		});
		this.statisticSelect = statsEnabled > 0 ? 'FET' : 'none';
	}
	updateEnabledFETExtras = function () {
		this.enabledFETPooling = document.getElementById(`FETPooling`).checked ? true : false;
		this.enabledFETIntersect = document.getElementById(`FETIntersect`).checked  ? true : false;
	}
}