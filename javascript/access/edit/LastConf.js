import { convertValuesToBoolean,getQueryParam } from "../accessUtils.js"
import { getRequest } from "../accessRequests.js";

export class LastConf {

	constructor() {
		this.meth = {
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
		}
		this.chroma = {
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
		}
		this.FETIntersect = false,
		this.urna = {
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
		}
		this.prot = {
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
		}
		this.gene = {
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
		}
		this.mapsDB = "kegg",
		this.meta = {
			RightThreshold: "1",
			pValThreshold: "0.05",
			RightEffectSizeCheck: true,
			enabled: true,
			pValCheck: true,
			LeftEffectSizeCheck: true,
			IdOnlyCheck: true,
			enabledFET: false,
			LeftThreshold: "-0.5"
		}
		this.FETPooling = false
	};
	loadLastConf = async function () {
		try {
			const sid = getQueryParam('sid');
			const exp = getQueryParam('exp');
			const response = await getRequest(`pathlayAccessActions.pl?action=loadLastConf&exp=${exp}&sid=${sid}`);
			if (response.status === "ok") {
				console.log('Last Exp Conf received:', response);
				let data = convertValuesToBoolean(response.conf,["FETPooling","FETIntersect","enabledFET","enabled","RightEffectSizeCheck","LeftEffectSizeCheck","IdOnlyCheck","pValCheck","enabletfsIdOnly","enabletfs","nodeg_select_tf","tfsNoDEFromIdOnlyCheck","NoDEFromIdOnlyCheck","nodeg_select"]);
				Object.keys(data).forEach((key) => {
					this.key = data[key];
				});
			}
		} catch (error) {
			console.error('Error:', error);
		}
	}
	fillDataCheckBoxes = function (omic) {
		document.getElementById(`enable${omic}`).checked = this[omic].enabled;
	}
	fillExpThresholds = function (omic) {
		["LeftEffectSizeThreshold","RightEffectSizeThreshold","pValThreshold"].forEach((id) => {
			document.getElementById(`${omic}${id}`).value = 
				id === "LeftEffectSizeThreshold" ? this[omic]["LeftThreshold"]
				: id === "RightEffectSizeThreshold" ? this[omic]["RightThreshold"]
				: this[omic][`${id}`];
		});
		["LeftEffectSizeCheck","RightEffectSizeCheck","pValCheck","IdOnlyCheck"].forEach((id) => {
			document.getElementById(`${omic}${id}`).checked = this[omic][`${id}`] ? true : false;
		});
	
	}
	
	fillTfsCheckBoxes = function (omic) {
		["enabletfs","enabletfsIdOnly","tfsNoDEFromIdOnlyCheck","nodeg_select_tf"].forEach((id) => {
			document.getElementById(`${id}_${omic}`).checked = this[omic][id] ? true : false;
		});
	}
	fillNoDeCheckBoxes = function (omic) {
		document.getElementById(`${omic}NoDEFromIdOnlyCheck`).checked = this[omic]["NoDEFromIdOnlyCheck"] ? true : false;
		document.getElementById(`nodeg_select_${omic}`).checked = this[omic]["nodeg_select"] ? true : false;
	}
	fillFETCheckBoxes = function (omic) {
		document.getElementById(`${omic}FETEnabled`).checked = this[omic]["enabledFET"] ? true : false;
	}
	fillFETExtras = function () {
		document.getElementById('FETPooling').checked = this.FETPooling;
		document.getElementById('FETIntersect').checked = this.FETIntersect;
	
	}
}