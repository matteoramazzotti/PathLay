// general declarations
export const integrityCheck = {
	homo_sapiens: [],
	mus_musculus: []
};

export var mapsCheck = {
	homo_sapiens: [],
	mus_musculus: []
};

export const typeToTitle = {
	ont: "Ontologies",
	meta: "Metabolites",
	tf: "Transcription Factors",
	gene: "Genes",
	prot: "Proteins",
	urna: "miRNAs"
};

export const organismCodes = {
	homo_sapiens: "hsa",
	mus_musculus: "mmu"
};
// Assuming RequestQueue is defined elsewhere and imported in globals.js
import { RequestQueue } from './RequestQueue.js';

export const paths = {
	interactionDBPath : ""
};
export const fork = {
	forkedProcesses : []
};


export const requestQueueMaps = new RequestQueue();
export const requestQueueDBs = new RequestQueue();
