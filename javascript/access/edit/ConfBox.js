import { RadiusSwitch } from "../RadiusSwitch.js";
import { HelpSpan } from "../HelpSpan.js";

export class ConfBox {
	constructor ({expConf = expConf, checkInterface = checkInterface, previewController = previewController} = {}) {
		this.omicToTitle = {
			gene: 'Genes',
			prot: 'Proteins',
			urna: 'miRNAs',
			meth: 'Methylations',
			chroma: 'Chromatin Statuses',
			meta: 'Metabolites'
		};
		this.expConf = expConf;

		this.container = document.createElement('div');
		this.container.className = 'conf-container';
			
		let rows = [];
		[0,1,2,3,4].forEach(() => {
			let containerRow = document.createElement('div');
			containerRow.className = 'conf-row';
			rows.push(containerRow);
		});
		rows[0].className += ' unjustify';
		// select omics
		let selectContainer = document.createElement('div');
		selectContainer.className = 'select-container';
		let span = document.createElement('span');
		span.innerHTML = 'Select omic';
		let select = document.createElement('select');
		select.id = 'omicsSelector';
		select.addEventListener('change',(event) => {this.displayOmic(event)});
	
	
		["gene","prot","urna","meth","chroma","meta"].forEach((omic) => {
			if (expConf[omic].idColumn) {
				let option = document.createElement('option');
				option.value = omic;
				option.innerText = this.omicToTitle[omic];
				option.name = omic;
				select.appendChild(option);
			}
		});

		["gene","prot","urna","meth","chroma","meta"].forEach((omic) => {
			let thrContainer = new ThresholdBox({omic : omic,expConf : expConf, checkInterface : checkInterface, previewController: previewController});
			rows[1].appendChild(thrContainer.container);
		});
		["gene","prot"].forEach((omic) => {
			let idOnlyContainer = new IdOnlyBox({omic : omic,title : this.omicToTitle[omic], checkInterface : checkInterface, previewController: previewController});
			rows[2].appendChild(idOnlyContainer.container);

			let tfsContainer = new TFBox({omic : omic, title : this.omicToTitle[omic], checkInterface : checkInterface, previewController: previewController});
			rows[3].appendChild(tfsContainer.container);
	
			let noDeContainer = new NodDeBox({omic : omic, title : this.omicToTitle[omic], checkInterface : checkInterface, previewController: previewController});
			rows[4].appendChild(noDeContainer.container);
		
		});
		["urna","meth","chroma"].forEach((omic) => {
			let idOnlyContainer = new IdOnlyBox({omic : omic, title : this.omicToTitle[omic], checkInterface : checkInterface, previewController: previewController});
			rows[2].appendChild(idOnlyContainer.container);
			let noDeContainer = new NodDeBox({omic : omic, title : this.omicToTitle[omic], checkInterface : checkInterface, previewController: previewController});
			rows[4].appendChild(noDeContainer.container);
		});
		rows[2].appendChild(new IdOnlyBox({omic : "meta", title : this.omicToTitle['meta'], checkInterface : checkInterface, previewController: previewController}).container);
		selectContainer.appendChild(select);
		rows[0].appendChild(span);
		rows[0].appendChild(selectContainer);
		rows[1].style.flexDirection = 'column';
		
		rows.forEach(row =>{
			this.container.appendChild(row);
		});
	}
	displayOmic = function(event) {
		let idOnlyContainers = document.getElementsByClassName('idOnly-container');
		let thrContainers = document.getElementsByClassName('thr-container');
		let tfsContainers = document.getElementsByClassName('tfs-container');
		let noDeContainers = document.getElementsByClassName('noDe-container');
		let previewRows = document.getElementsByClassName('preview-box');

		Array.from(idOnlyContainers).forEach((container) => {
			container.style.display = 'none';
		})

		Array.from(thrContainers).forEach((container) => {
			container.style.display = 'none';
		})
		Array.from(tfsContainers).forEach((container) => {
			container.style.display = 'none';
		})
		Array.from(noDeContainers).forEach((area) => {
			area.style.display = 'none';
		})
		Array.from(previewRows).forEach((area) => {
			area.style.display = 'none';
		})

		let omic = event.target.selectedOptions[0].value;
		if (document.getElementById(`${omic}IdOnlyContainer`)) {
			document.getElementById(`${omic}IdOnlyContainer`).style.display = 'flex';
		}
		if (document.getElementById(`${omic}TfsContainer`)) {
			document.getElementById(`${omic}TfsContainer`).style.display = 'flex';
		}
		if (document.getElementById(`${omic}ThrContainer`)) {
			document.getElementById(`${omic}ThrContainer`).style.display = 'flex';
		}
		if (document.getElementById(`${omic}NoDeContainer`)) {
			document.getElementById(`${omic}NoDeContainer`).style.display = 'flex';
		}
		if (document.getElementById(`${omic}PreviewRow`)) {
			document.getElementById(`titlePreviewRow`).style.display = 'flex';
			document.getElementById(`${omic}PreviewRow`).style.display = 'flex';
		}
	}
	render = function(parent) {
		if (parent instanceof HTMLElement) {
      parent.appendChild(this.container);
		}
	}
}

class ThresholdBox {
	constructor ({expConf = expConf, omic = omic, checkInterface = checkInterface, previewController = previewController} = {}) {
		this.expConf = expConf;

		this.container = document.createElement('div'); 
		this.container.id = `${omic}ThrContainer`;
		this.container.className = 'thr-container';
		this.container.style.display = omic !== 'gene' ? 'none' : 'flex';

		// thrContainer.style.alignItems = 'center';
		let thrs = ['LeftEffectSize','RightEffectSize','pVal'];

		thrs.forEach((thr) => {
			let containerSpan = document.createElement('span');
			containerSpan.className = 'thr-container-span';
	
			let titleSpan = document.createElement('span');
			titleSpan.className = 'thr-title-span';
			titleSpan.innerText = thr !== 'pVal' ? 'Effect Size' : 'p-value';
			titleSpan.innerText += thr === 'RightEffectSize' ? ' >' : ' <';
	
			let switchLabel = new RadiusSwitch({id : `${omic}${thr}Check`,name : `${omic}${thr}Check`});
			switchLabel.switch.addEventListener('change', async function() {
				try {
					checkInterface.currentConf.updateEnabledThresholds(omic);
					checkInterface.checkThrInputs(omic);
					checkInterface.handleThrInputs(omic);
					checkInterface.handleSubmit();
					previewController.filterData(omic, checkInterface.expConf.expData);
					previewController.displayPreview(omic);
				} catch (error) {
					console.log(error);
				}
			});
	
			let thrInput = document.createElement('input');
			thrInput.id =  `${omic}${thr}Threshold`;
			thrInput.type = 'number';
			thrInput.step = thr !== 'pVal' ? '0.1' : '0.01';
			thrInput.className = `thresholdInput Effect ${thr}`;
			thrInput.addEventListener('input', async function() {
				try {
					checkInterface.currentConf.updateThresholdValues(omic);
					checkInterface.checkThrInputs(omic);
					checkInterface.handleThrInputs(omic);
					checkInterface.handleSubmit();
					previewController.filterData(omic, checkInterface.expConf.expData);
					previewController.displayPreview(omic);
				} catch (error) {
					console.log(error);
				}
			});
	
	
			containerSpan.appendChild(titleSpan);
			containerSpan.appendChild(thrInput);
			containerSpan.appendChild(switchLabel.switch);
			this.container.appendChild(containerSpan);
			
		});

	}

}


class IdOnlyBox {
	constructor ({omic = omic, title = title, checkInterface = checkInterface, previewController = previewController} = {}) {
		this.container = document.createElement('div'); 
		this.container.id = `${omic}IdOnlyContainer`;
		this.container.className = 'tfs-container';
		this.container.style.display = omic !== 'gene' ? 'none' : 'flex';
		let helps = [`Preserve ${title} IDs without expression values in ${title} dataset`];
		['Preserve non DE IDs'].forEach((title,i) => {
			let containerSpan = document.createElement('span');
			containerSpan.className = 'idOnly-container-span';
	
			let titleSpan = document.createElement('span');
			titleSpan.className = 'idOnly-title-span';
			let textSpan = document.createElement('span');
			textSpan.innerText = title;
	
			let helpSpan = new HelpSpan({title: helps[i]});
			titleSpan.appendChild(textSpan);
			titleSpan.appendChild(helpSpan.span);
	
			let switchLabel = new RadiusSwitch({id:`${omic}IdOnlyCheck`,name:`${omic}IdOnlyCheck`});
			switchLabel.switch.addEventListener('change', async function() {
				try {
					checkInterface.currentConf.updateEnabledIdOnly(omic);
				} catch (error) {
					console.log(error);
				}
			});
	
	
			containerSpan.appendChild(titleSpan);
			containerSpan.appendChild(switchLabel.switch);
			this.container.appendChild(containerSpan);
		});
	}
}

class TFBox {
	constructor ({omic = omic, title = title, checkInterface = checkInterface, previewController = previewController} = {}) {
		this.container = document.createElement('div'); 
		this.container.id = `${omic}TfsContainer`;
		this.container.className = 'tfs-container';
		this.container.style.display = omic !== 'gene' ? 'none' : 'flex';
	
	
		let titles = ['Enable TFs',' Preserve IDs for TFs '];
		let helps = [`Look for Transcription Factors in ${title} dataset`,`Preserve Transcription Factors IDs without expression values in ${title} dataset`];
		let ids = ['enabletfs','enabletfsIdOnly'];
	
		titles.forEach((title,i) => {
			let containerSpan = document.createElement('span');
			containerSpan.className = 'tfs-container-span';
	
			let titleSpan = document.createElement('span');
			titleSpan.className = 'tfs-title-span';
	
			let textSpan = document.createElement('span');
			textSpan.innerText = title;
	
			let helpSpan = new HelpSpan({title: helps[i]});
	
			titleSpan.appendChild(textSpan);
			titleSpan.appendChild(helpSpan.span);
	
	
			let switchLabel = new RadiusSwitch({id:`${ids[i]}_${omic}`,name:`${ids[i]}_${omic}`});
			switchLabel.switch.addEventListener('change', async function() {
				try {
					ids[i] === 'enabletfs' ? checkInterface.currentConf.updateEnabledTFs(omic)
					: checkInterface.currentConf.updateEnabledIdOnlyTFs(omic)
				} catch (error) {
					console.log(error);
				}
			});
			
			containerSpan.appendChild(titleSpan);
			containerSpan.appendChild(switchLabel.switch);
			this.container.appendChild(containerSpan);
	
		});
	}
}

class NodDeBox {
	constructor ({omic = omic, title = title, checkInterface = checkInterface,previewController = previewController} = {}) {
		this.container = document.createElement('div'); 
		this.container.id = `${omic}NoDeContainer`;
		this.container.className = 'noDe-container';
		this.container.style.display = omic !== 'gene' ? 'none' : 'flex';
		
		let titles = 
			omic === 'gene' || omic === 'prot' ? ['Load Non DE from TFs','Load Non DE from Preserved TFs']
			: ['No DE Loading','No DE Loading From Preserved IDs']
		;
		let helps =
			omic === 'gene' || omic === 'prot' ?
			[`Load Non Differentially Expressed ${title} interacting with Transcription Factors found in ${title} dataset`,
			`Load Non Differentially Expressed ${title} interacting with Transcription Factors without Expression Values found in ${title} dataset`]
			: [`Load Non Differentially Expressed Genes interacting with ${title} found in ${title} dataset`,
			`Load Non Differentially Expressed Genes interacting with ${title} without Expression Values found in ${title} dataset`
			];
		let ids = 
			omic === 'gene' || omic === 'prot' ? ['nodeg_select_tf','tfsNoDEFromIdOnlyCheck']
			: ['nodeg_select','NoDEFromIdOnlyCheck']	
		;
	
		titles.forEach((title,i) => {
			let containerSpan = document.createElement('span');
			containerSpan.className = 'noDe-container-span';
	
			let titleSpan = document.createElement('span');
			titleSpan.className = 'noDe-title-span';
			let textSpan = document.createElement('span');
			textSpan.innerText = title;
	
			let helpSpan = new HelpSpan({title: helps[i]});
			titleSpan.appendChild(textSpan);
			titleSpan.appendChild(helpSpan.span);
	
			
	
			let switchId = ids[i] === "NoDEFromIdOnlyCheck" ? `${omic}${ids[i]}` : `${ids[i]}_${omic}`;
			let switchLabel = new RadiusSwitch({id: switchId,name: switchId});
			switchLabel.switch.addEventListener('change',async function() {
				try {
					switchId === `${omic}NoDEFromIdOnlyCheck` ? checkInterface.currentConf.updateEnabledNoDeIdOnlyLoaders(omic)
					: switchId === `nodeg_select_${omic}` ? checkInterface.currentConf.updateEnabledNoDeLoaders(omic)
					: switchId === `nodeg_select_tf_${omic}` ? checkInterface.currentConf.updateEnabledNoDeTFsLoaders(omic)
					: checkInterface.currentConf.updateEnabledNoDeIdOnlyTFsLoaders(omic);
	
				} catch (error) {
					console.log(error);
				}
			});
			if (switchId === `nodeg_select_${omic}`) {
				switchLabel.switch.addEventListener('change', async function() {
					try {
						checkInterface.handleNoDeEnabled();
					} catch (error) {
						console.log(error);
					}
				});
			}
	
			containerSpan.appendChild(titleSpan);
			containerSpan.appendChild(switchLabel.switch);
			this.container.appendChild(containerSpan);
	
		});
	}
}







