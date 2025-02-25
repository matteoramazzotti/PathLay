export class PreviewController {

	constructor() {	
		this.omicPreviews = {
			gene:{},
			prot:{},
			urna:{},
			meth:{},
			chroma:{},
			meta:{}
		};
		this.currentConf = {};
	}

	//preview functions

	filterData = function (omic,expData) {
		console.log(`Input ${omic} ids: ${expData[omic].objData.length}`);
		let omicEnabled = this.currentConf.enabledOmics[omic];
		
		this.omicPreviews[omic].inputIds = expData[omic].objData;
		this.omicPreviews[omic].inputIdsNum = expData[omic].objData.length;
		
		[this.omicPreviews[omic].esFiltered,this.omicPreviews[omic].esFilteredNum] = this.filterByES(omic,expData);
		console.log(this.omicPreviews[omic].esFiltered);
		[this.omicPreviews[omic].pValFiltered,this.omicPreviews[omic].pvalFilteredNum] = this.filterBypVal(omic,expData);
		console.log(this.omicPreviews[omic].pValFiltered);

		this.omicPreviews[omic].outputIdsNum = this.omicPreviews[omic].inputIdsNum - this.omicPreviews[omic].esFilteredNum - this.omicPreviews[omic].pvalFilteredNum;

		// let test = expData[omic].objData.filter((obj) => (obj.isIdOnly));
		// console.log(`test: ${test.length}`);
		// let pValFiltered = test.filter((obj) => (
		// 	parseFloat(obj.pVal) < 0.05
		// ));
		// console.log(pValFiltered)

	}
	filterByES = function (omic,expData) {
		let esLeftEnabled = this.currentConf.omicConfs[omic].esLeftEnabled;
		let esRightEnabled = this.currentConf.omicConfs[omic].esRightEnabled;
		let leftEsThr = this.currentConf.omicConfs[omic].esLeftThr;
		let rightEsThr = this.currentConf.omicConfs[omic].esRightThr;

		let esFiltered = 
		esLeftEnabled && esRightEnabled ? expData[omic].objData.filter((obj) => (
			parseFloat(obj.esVal) < leftEsThr || parseFloat(obj.esVal) > rightEsThr
		)) :
		esLeftEnabled && !esRightEnabled ? expData[omic].objData.filter((obj) => (
			parseFloat(obj.esVal) < leftEsThr
		)) :
		!esLeftEnabled && esRightEnabled ? expData[omic].objData.filter((obj) => (
			parseFloat(obj.esVal) > rightEsThr
		)) :
		expData[omic].objData;

		let filteredCount = this.omicPreviews[omic].inputIdsNum - esFiltered.length;
		return([esFiltered,filteredCount]);
	}
	filterBypVal = function (omic,expData) {
		let pValEnabled = this.currentConf.omicConfs[omic].pValEnabled;
		let pValThr = this.currentConf.omicConfs[omic].pValThr;
		let pValFiltered = pValEnabled ? this.omicPreviews[omic].esFiltered.filter((obj) => (
			parseFloat(obj.pVal) < pValThr
		)) : this.omicPreviews[omic].esFiltered;
		let filteredCount = this.omicPreviews[omic].esFiltered.length - pValFiltered.length;
		return([pValFiltered,filteredCount]);
	}
	filterIdOnlys = function (omic) {

	}
	displayPreview = function (omic) {
		let ids = ["Input","EsFiltered","pValFiltered","Output"];
		let values = [
			this.omicPreviews[omic].inputIdsNum,
			this.omicPreviews[omic].esFilteredNum,
			this.omicPreviews[omic].pvalFilteredNum,
			this.omicPreviews[omic].outputIdsNum
		];
		["Input:","Filetered out by Effect Size:","Filetered out by p-value:","Output:"].forEach((text,i) => {
			let span = document.getElementById(`${omic}${ids[i]}Span`);
			span.innerText = `${text} ${values[i]}`;
		})
	}
}