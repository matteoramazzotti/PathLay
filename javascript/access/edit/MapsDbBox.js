import { RadiusSwitch } from "../RadiusSwitch.js";

export class MapsDbBox {
	constructor(checkInterface){
		console.log("maps")
		this.omicToTitle = {
			gene: 'Genes',
			prot: 'Proteins',
			urna: 'miRNAs',
			meth: 'Methylations',
			chroma: 'Chromatin Statuses',
			meta: 'Metabolites'
		};
		this.container = document.createElement('div');
		this.container.className = 'conf-container';
		this.container.style.width = "90%";

		let rows = [];
		[0,1,2].forEach(() => {
			let containerRow = document.createElement('div');
			containerRow.className = 'conf-row';
			rows.push(containerRow);
		});
		

		// select maps
		let selectContainer = document.createElement('div');
		selectContainer.className = 'select-container';
		let span = document.createElement('span');
		span.innerHTML = 'Select Maps DB';
		let select = document.createElement('select');
		select.id = 'maps_db_select';
		["kegg","wikipathways"].forEach((db) => {
			let option = document.createElement('option');
			option.value = db;
			option.innerText = db === "kegg" ? "KEGG" : "WikiPathways";
			option.name = db;
			select.appendChild(option);
		});
		selectContainer.appendChild(select);
		// add events on change 
		select.addEventListener('change', async function() {
			try {
				checkInterface.currentConf.updateSelectedMapDB();
			} catch (error) {
				console.log(error)
			}
		});

		// datasets enabler
		["gene","prot","urna","meth","chroma","meta"].forEach((omic) => {
			let div = document.createElement("div");
			div.style.display = 'flex';
			div.style.alignItems = 'center';
			div.style.justifyContent = 'center';
			div.style.flexDirection = 'column';
			let switchLabel = new RadiusSwitch({id:`enable${omic}`,name:`enable${omic}`});
			switchLabel.switch.id = `enable${omic}Label`;
			// add events on change 
			switchLabel.switch.addEventListener('change', async function() {
				try {
					checkInterface.currentConf.updateEnabledOmics(omic);
					checkInterface.handleConfEnabled(omic);
					checkInterface.handleFETPooling();
					checkInterface.handleSubmit();
				} catch (error) {
					console.log(error)
				}
			});

			let titleSpan = document.createElement('span');
			titleSpan.className = 'tfs-title-span';
			titleSpan.innerText = this.omicToTitle[omic];
			div.appendChild(titleSpan);
			div.appendChild(switchLabel.switch);
			
			rows[2].appendChild(div);
		});

		// load on rows
		rows[0].appendChild(span);
		rows[0].appendChild(selectContainer);
		let enableTitle = document.createElement('span');
		enableTitle.innerText = "Select Datasets to be used";
		rows[1].appendChild(enableTitle);
		rows[1].style.justifyContent = 'flex-start';
		rows.forEach(row =>{
			this.container.appendChild(row);
		})
	}
}
