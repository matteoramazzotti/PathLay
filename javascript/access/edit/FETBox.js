import { RadiusSwitch } from "../RadiusSwitch.js";
import { HelpSpan } from "../HelpSpan.js";


export class FETBox {
	constructor	(checkInterface) {
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
		this.container.style.width = "auto";

		let rows = [];
		[0,1,2,3,4].forEach(() => {
			let containerRow = document.createElement('div');
			containerRow.className = 'conf-row';
			rows.push(containerRow);
		});
		let containerTitle = document.createElement('span');
		containerTitle.innerText = `Fisher's Exact Test Setting`;
		rows[0].appendChild(containerTitle);

		let titleSpan = document.createElement('span');
		titleSpan.className = 'fet-title-span';
		titleSpan.innerText = `Enable for:`;
		rows[1].appendChild(titleSpan);
		rows[1].style.justifyContent = "flex-start";

		["gene","prot","urna","meth","chroma","meta"].forEach((omic) => {
			let fetContainer = this.enablersPackager(omic,checkInterface);
			rows[2].appendChild(fetContainer);
		});
		rows[2].style.flexDirection = "column";
		rows.forEach(row =>{
			this.container.appendChild(row);
		})

		let containerSpan = document.createElement('span');
		containerSpan.className = 'fet-container-span';
		let titleSpan2 = document.createElement('span');
		titleSpan2.className = 'fet-title-span';
		titleSpan2.innerText = `Additional Features: `;
		containerSpan.appendChild(titleSpan2);

		rows[3].appendChild(containerSpan);
		rows[3].style.justifyContent = "flex-start";

		let extraContainer = this.extraFeaturesPackager();
		rows[4].appendChild(extraContainer);
	}

	enablersPackager = function(omic,checkInterface) {
		let container = document.createElement('div'); 
		container.id = `${omic}FETContainer`;
		container.className = 'fet-container';
		container.style.display = 'flex';
		container.style.flexDirection = 'row';
	
		let containerSpan = document.createElement('span');
		containerSpan.className = 'fet-container-span';
	
		let titleSpan = document.createElement('span');
		titleSpan.className = 'fet-title-span';
		titleSpan.innerText = this.omicToTitle[omic];
	
		let switchLabel = new RadiusSwitch({id:`${omic}FETEnabled`,name:`${omic}FETEnabled`});
		switchLabel.switch.addEventListener('change', async function() {
			try {
				checkInterface.currentConf.updateEnabledFETs(omic);
				checkInterface.handleFETEnabled();
				checkInterface.handleNoDeEnabled();
				checkInterface.handleFETPooling();
			} catch (error) {
				console.log(error);
			}
		});
		containerSpan.appendChild(titleSpan);
		containerSpan.appendChild(switchLabel.switch);
		container.appendChild(containerSpan);
	
		return(container);
	}
	extraFeaturesPackager = function() {
		console.log('extraFeaturesPackager');
		let extraTitles = ["Pooling","Intersect"];
		let extraContainer = document.createElement('div');
		extraContainer.id = 'FETExtraFeatures';
		extraContainer.className = 'fet-container';
		let helps = [
			`Execute Fisher's Exact Test on a list of Genes/Protein produced by the union of the enabled datasets for the test, including No DE components loaded`,
			`Display only Pathways obtained by the intersection of the Pathway Lists obtained from each Fisher's Exact test execution`
		];
		
		["FETPooling","FETIntersect"].forEach((id,i) => {
			let containerSpan = document.createElement('span');
			containerSpan.className = 'fet-container-span';
			let titleSpan = document.createElement('span');
			titleSpan.className = 'fet-title-span';
			let switchLabel = new RadiusSwitch({id: id, name: id});
			switchLabel.switch.id = `${id}Label`;
			switchLabel.switch.addEventListener('change', async function() {
				try {
					checkInterface.currentConf.updateEnabledFETExtras();
				} catch (error) {
					console.log(error);
				}
			});
			let textSpan = document.createElement('span');
			textSpan.innerText = extraTitles[i];

			let helpSpan = new HelpSpan({title: helps[i]});
			titleSpan.appendChild(textSpan);
			titleSpan.appendChild(helpSpan.span);

			containerSpan.appendChild(titleSpan);
			containerSpan.appendChild(switchLabel.switch);
			extraContainer.appendChild(containerSpan);
		});
		console.log(extraContainer);
		return(extraContainer);
	}
}