export class HelpSpan {
	constructor ({title = title} = {}) {
		this.span = document.createElement('span');
		this.span.innerText = 'help';
		this.span.className = 'material-symbols-outlined';
		this.span.title = title;
		this.span.addEventListener('mouseover', () => {
			this.span.style.cursor = 'help';
		});
	}
}