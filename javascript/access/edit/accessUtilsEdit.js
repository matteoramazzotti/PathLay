import {performAction,getQueryParam} from "../accessUtils.js";
import { postJsonAndStock, postJsonByForm } from '../accessRequests.js';
import { PreviewBox } from './PreviewBox.js';
import { ConfBox } from './ConfBox.js';
import { MapsDbBox } from './MapsDbBox.js';
import { FETBox } from './FETBox.js';



export function loadPageContent(organism,checkInterface, previewController) {
	console.log(organism)
	console.log(checkInterface.expConf)
	let containerRows = document.getElementsByClassName('container-row');
	containerRows[2].innerHTML = '';
	containerRows[2].style.alignItems = 'flex-start';

	let box = document.createElement('div');
	box.style.display = "flex";
	box.style.flexDirection = "column";
	// box.style.margin = "20px";
	box.style.width = "20vw";

	let box2 = box.cloneNode();
	box2.style.alignItems = 'center';
	box2.style.removeProperty('width');

	box2.appendChild(new PreviewBox().container);
	box2.appendChild(button('submit','Submit','start',async function submit() {
		let resp = await performAction('updateLastConf', getQueryParam('exp'), checkInterface.currentConf, checkInterface.expConf.expData);
		if (resp) {
			checkInterface.currentConf.sid = getQueryParam('sid');
			checkInterface.currentConf.org = organism;
			let confBackEnd = processParamsForJson(checkInterface.currentConf, checkInterface.expConf);

			let url = `../cgi-bin/pathlayIntegrator.pl?sid=${getQueryParam('sid')}&exp=${getQueryParam('exp')}`;
			let {result,promise} = await postJsonAndStock(url,confBackEnd);
			let data = JSON.parse(result);
			url = `../cgi-bin/pathlayMaps.pl?sid=${getQueryParam('sid')}&exp=${getQueryParam('exp')}`;
			postJsonByForm(url,data.data);
		}
	}));



	box.appendChild(new FETBox(checkInterface).container);

	containerRows[1].appendChild(new MapsDbBox(checkInterface).container);
	let confBox = new ConfBox({expConf:checkInterface.expConf,checkInterface:checkInterface, previewController: previewController});
	confBox.render(containerRows[2]);
	containerRows[2].appendChild(box);
	containerRows[2].appendChild(box2);
}

function processParamsForJson(currentConf,expConf) {
	let newJson = {};
	['gene','prot','urna','meth','chroma','meta'].forEach((omic) => {
		newJson[`enable${omic}`] = currentConf.enabledOmics[omic];
		if (currentConf.enabledOmics[omic]) {
			newJson[`${omic}LeftEffectSizeCheck`] = currentConf.omicConfs[omic].esLeftEnabled;
			newJson[`${omic}RightEffectSizeCheck`] = currentConf.omicConfs[omic].esRightEnabled;
			newJson[`${omic}pValCheck`] = currentConf.omicConfs[omic].pValEnabled;
			newJson[`${omic}IdOnlyCheck`] = currentConf.omicConfs[omic].idOnlyEnabled;
			newJson[`${omic}LeftThreshold`] = currentConf.omicConfs[omic].esLeftThr;
			newJson[`${omic}RightThreshold`] = currentConf.omicConfs[omic].esRightThr;
			newJson[`${omic}pValThreshold`] = currentConf.omicConfs[omic].pValThr;
			newJson[`${omic}_data`] = expConf.expData[omic].textData;
			newJson[`${omic}_id_column`] = expConf[omic].idColumn;
			newJson[`${omic}_dev_column`] = expConf[omic].devColumn;
			newJson[`${omic}_pvalue_column`] = expConf[omic].pvalueColumn;
			newJson[`${omic}FETEnabled`] = currentConf.enabledFETs[omic];
			newJson[`${omic}IdType`] = expConf[omic].IdType;
		}
	});
	['gene','prot'].forEach((omic) => {
		newJson[`enabletfs_${omic}`] = currentConf.omicConfs[omic].tfEnabled;
		newJson[`nodeg_select_tf_${omic}`] = currentConf.omicConfs[omic].tfNoDeEnabled;
		newJson[`enabletfsIdOnly_${omic}`] = currentConf.omicConfs[omic].tfIdOnlyEnabled;
		newJson[`tfsNoDEFromIdOnlyCheck_${omic}`] = currentConf.omicConfs[omic].tfNoDeIdOnlyEnabled;
	});
	['urna','meth','chroma'].forEach((omic) => {
		if (currentConf.enabledOmics[omic]) {
			newJson[`nodeg_select_${omic}`] = currentConf.omicConfs[omic].noDeLoadEnabled;
			newJson[`${omic}NoDEFromIdOnlyCheck`] = currentConf.omicConfs[omic].noDeLoadIdOnlyEnabled;
		}
	});
	newJson['statistic_select'] = currentConf.statisticSelect;
	newJson['FETIntersect'] = currentConf.enabledFETIntersect;
	if (!document.getElementById('FETPooling').disabled) {
		newJson['FETPooling'] = currentConf.enabledFETPooling;
	}
	newJson['org'] = expConf.organism;
	newJson['sid'] = getQueryParam('sid');
	newJson['exp_select'] = getQueryParam('exp');
	newJson['maps_db_select'] = currentConf.mapDBSelected;
	console.log(newJson);
	return newJson;
}	
function button(id,text,iconText,onClickFunction) {
	let div = document.createElement('div');
	div.className = 'conf-container';
	let a = document.createElement('a');
	a.id = id;
	a.addEventListener('click',function() {
		onClickFunction()
	});
	a.className = 'exp-package-item-icon';
	let i = document.createElement('i');
	i.className = 'material-icons';
	i.innerText = iconText;
	let span = document.createElement('span');
	span.innerText = text;
	a.appendChild(i);
	a.append(span);
	div.appendChild(a);
	return(div)
}





