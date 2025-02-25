import { getRequest } from '../accessRequests.js';
import { getQueryParam, convertValuesToBoolean } from '../accessUtils.js';


export class ExpConf {

	constructor() {
		this.comments = "";
		this.expname = "";
		this.organism = "";
		this.gene = {};
		this.meta = {};
		this.prot = {};
		this.urna = {};
		this.meth = {};
		this.chroma = {};
		this.onts = [];
		this.integrityChecks = {};
		this.expData = {
			gene: {},
			meta: {},
			prot: {},
			urna: {},
			meth: {},
			chroma: {}
		};
	}

	loadExpConf = async function () {
		try {
			const sid = getQueryParam('sid');
			const exp = getQueryParam('exp');
			const response = await getRequest(`pathlayHomeActions.pl?action=loadExpConf&exp=${exp}&sid=${sid}`);
			
			if (response.status === "ok") {
				console.log('Conf received:', response);
				Object.keys(response.conf).forEach((key) =>{
					this[key] = response.conf[key];
				}); 
			}

		} catch (error) {
			console.error('Error:', error);
		}
	}
	loadExpData = async function () {
		try {
			const sid = getQueryParam('sid');
			const exp = getQueryParam('exp');
			const response = await getRequest(`pathlayAccessActions.pl?action=loadExpData&exp=${exp}&sid=${sid}`);
			if (response.status === "ok") {
				console.log('Exp Data received:', response);
				let data = convertValuesToBoolean(response.data,["isIdOnly","haspVal","hasEs"]);
				this.expData = data;
				this.onts = response.onts;
			}
		} catch (error) {
			console.error('Error:', error);
		}
	}
	checkConfiguration =  async function () {
		new Promise(async (resolve, reject) => {
			try {
				console.log('Checking configuration...');
				const expId = getQueryParam('exp');
				const sid = getQueryParam('sid');
				const url = `pathlayAccessActions.pl?action=checkConf&exp=${expId}&sid=${sid}`;
				console.log(url);
				const response = await getRequest(url);
				console.log('Conf received:', response);
				resolve(this.integrityChecks = response.checks);
			} catch (error) {
				console.error('Error:', error);
				reject(error);
			}
		});
}
	// fill conf elements after loading
	fillExpGenerics = function () {
		["expname","comments","organism"].forEach((section) => {
			document.getElementById(`${section}Input`).value = this[section];
		});
	}
	
}