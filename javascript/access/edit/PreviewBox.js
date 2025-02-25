export class PreviewBox {
	constructor() {
		this.titleIndex = {
			gene: 'Genes',
			prot: 'Proteins',
			urna: 'miRNAs',
			meth: 'Methylations',
			chroma: 'Chromatin Statuses',
			meta: 'Metabolites'
		};
		let container = document.createElement('div');
		container.className = 'conf-container';

		let rows = [];
		[0,1,2,3,4,5,6].forEach(() => {
			let containerRow = document.createElement('div');
			containerRow.className = 'conf-row preview-box';
			containerRow.style.display = "none";
			rows.push(containerRow);
		});
		["gene","prot","urna","meth","chroma","meta"].forEach((omic,i) => {
			rows[i+1].id = `${omic}PreviewRow`;
			rows[i+1].appendChild(new PreviewDiv({
				omic: omic,
				title: this.titleIndex[omic]
			}).container);
		});
		rows.forEach(row =>{
			container.appendChild(row);
		});
		let titleSpan = document.createElement('span');
		titleSpan.innerText = 'Preview';
		rows[0].appendChild(titleSpan);
		rows[0].id = "titlePreviewRow";
		rows[0].style.display = "flex";
		rows[1].style.display = "flex";
		
		this.container = container;
	}
}

class PreviewDiv {
	constructor({omic = omic, title = title} = {}) {
		let container = document.createElement('div');
		container.className = 'conf-container';
		container.id = `${omic}PreviewBox`;
		let titleSpan = document.createElement('span');
		titleSpan.innerText = title;

		let rows = [];
		[0,1,2,3,4].forEach(() => {
			let containerRow = document.createElement('div');
			containerRow.className = 'conf-row preview-row';
			rows.push(containerRow);
		});

		rows[0].appendChild(titleSpan);
		let ids = ["Input","EsFiltered","pValFiltered","Output"];
		["Input:","Filetered out by Effect Size:","Filetered out by p-value:","Output:"].forEach((text,i) => {
			let span = document.createElement('span');
			span.id = `${omic}${ids[i]}Span`;
			span.innerText = text;
			rows[i+1].appendChild(span);
		})

		rows.forEach(row =>{
			container.appendChild(row);
		})
		this.container = container;
	}
}