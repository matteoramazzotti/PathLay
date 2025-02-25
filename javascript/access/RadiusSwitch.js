export class RadiusSwitch {
	constructor ({id = id, name = name} = {}) {
		this.switch = document.createElement('label');
		this.switch.className = 'switch';
		let switchInput = document.createElement('input');
		switchInput.id = id;
		switchInput.name = name;
		switchInput.type = 'checkbox';
		let switchSpan = document.createElement('span');
		switchSpan.className = 'slider round';
		this.switch.appendChild(switchInput);
		this.switch.appendChild(switchSpan);
	}
}
