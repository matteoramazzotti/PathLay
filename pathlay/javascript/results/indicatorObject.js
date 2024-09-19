




class Complex {
    constructor(id, parent) {
        this.id = id;
        this.parentPathway = parent; 
        this.components = [];
        this.hasDeg = false;
        this.hasProt = false;
        this.hasNoDeg = false;
        this.hasmiRNA = false;
        this.hasMethyl = false;
        this.hasTF = false;
        this.hasChroma = false;
        this.hasMeta = false;
    }
    loadContent = function() {
        let srcTxt = document.getElementById(this.id).attributes.content.nodeValue;
        let srcLines = srcTxt.split("%0A");
        srcLines.splice(0,2);
        srcLines.pop();
        //console.log(`load content on ${this.id}`);
        let status = -1;
        for (let srcLine of srcLines) {
            let srcTags = srcLine.split("|");
            var currentObj;
            var currentId = "";
            var currentName = "";
            var currentDev = "";
            var currentMirt = "";
            var currentType = "";
            // console.log(`id:${currentId} dev:${currentDev}`);
            for (let srcTag of srcTags) {
                if (typeRegex.test(srcTag) === true) {
                    currentType = typeRegex.exec(srcTag)[1];
                    if (currentType === "deg") {
                        currentObj = new Gene();
                        currentObj.type = currentType;
                        this.hasDeg = true;
                        currentObj.assignImg();
                        status = 0;
                        continue;
                    }
                    if (currentType === "nodeg") {
                        currentObj = new Gene();
                        currentObj.type = currentType;
                        this.hasNoDeg = true;
                        currentObj.assignImg();
                        status = 0;
                        continue;
                    }
                    if (currentType === "prot") {
                        currentObj = new Protein();
                        currentObj.type = currentType;
                        this.hasProt = true;
                        currentObj.assignImg();
                        status = 0;
                        continue;
                    }
                    if (currentType === "meta") {
                        currentObj = new Metabolite();
                        currentObj.type = currentType;
                        this.hasMeta = true;
                        currentObj.assignImg();
                        status = 0;
                        continue;
                    }
                    if (currentType === "urna") {
                        currentObj = new miRNA();
                        this.hasmiRNA = true;
                        currentObj.assignImg();
                        status++;
                        continue;
                    }
                    if (currentType === "tf") {
                        currentObj = new TF();
                        this.hasTF = true;
                        currentObj.assignImg();
                        status++;
                        continue;
                    }
                    if (currentType === "meth") {
                        this.hasMethyl = true;
                        status++;
                        currentObj.assignImg();
                        continue;
                    }
                    if (currentType === "chroma") {
                        this.hasChroma = true;
                        status++;
                        currentObj.assignImg();
                        continue;
                    }
                }
                if (idRegex.test(srcTag) === true) {
                    currentId = idRegex.exec(srcTag)[1];
                    currentObj.id = currentId;
                    if (!referenceTable[currentType].ids[currentId]) {
                        referenceTable[currentType].ids[currentId] = {};
                        referenceTable[currentType].ids[currentId].complexes = [];
                        referenceTable[currentType].ids[currentId].name = "";
                    }
                    referenceTable[currentType].ids[currentId].complexes.push(this.id);
                    const withoutDuplicates = Array.from(new Set(referenceTable[currentType].ids[currentId].complexes));
                    referenceTable[currentType].ids[currentId].complexes = withoutDuplicates;
                }
                if (nameRegex.test(srcTag) === true) {
                    currentName = nameRegex.exec(srcTag)[1];
                    currentObj.name = currentName;
                    referenceTable[currentType].ids[currentId].name = currentName;
                    if (currentType == "prot") {
                        entrez2protID[currentName] = currentId; 
                    } 
                    if (currentType == "deg" || currentType == "nodeg") {
                        entrez2symbol[currentId] = currentName;
                    }
                }
                if (mirtRegex.test(srcTag) === true) {
                    currentMirt = mirtRegex.exec(srcTag)[1];
                    currentObj.mirt = currentMirt;
                    referenceTable[currentType].ids[currentId].name = currentMirt;
                }
                if (devRegex.test(srcTag) === true) {
                    currentDev = devRegex.exec(srcTag)[1];
                    if (currentType === "meth") {
                        currentObj.meth = currentDev;
                        currentObj.hasMethyl = true;
                        currentObj.assignImg();
                    } else if (currentType === "chroma") {
                        currentObj.chroma = currentDev;
                        currentObj.hasChroma = true;
                        currentObj.assignImg();
                    } else {
                        currentObj.dev = currentDev;
                    }
                    currentObj.assignImg();
                }
                
            }
            if (status > 0) {
                if (currentType === "urna") {
                    this.components[this.components.length - 1].loadmiRNA(currentObj);
                    
                }
                if (currentType === "tf") {
                    this.components[this.components.length - 1].loadTf(currentObj);
                    
                }
                if (currentType === "meth") {
                    this.components[this.components.length - 1].loadMeth(currentDev);
                }
                if (currentType === "chroma") {
                    this.components[this.components.length - 1].loadChroma(currentDev);
                }         
            }
            if (status === 0) {
                this.components.push(currentObj);
                //console.log(`pushing ${currentObj.id}`);
            }
        }
    }

    loadContent2 = function() {
        let srcTxt = document.getElementById(this.id).attributes.content.nodeValue;
        let srcLines = srcTxt.split("%0A");
        srcLines.splice(0,2);
        srcLines.pop();

        let parsedData = srcLines.map(line => {
            let fields = line.split('|');
            let entry = {
                dev: undefined // Set 'dev' field as undefined by default
            };
            
            fields.forEach(field => {
                let [key, value] = field.split(':');
                // Convert numeric values to number type
                // if (!isNaN(value)) {
                //     value = parseFloat(value);
                // }
                entry[key] = value;
            });
            return entry;
        });
        
        let parentMap = {};
        let lastParent = null;

        parsedData.forEach(entry => {
            if (["deg", "prot", "nodeg", "meta"].includes(entry.type)) {
                if (!parentMap[entry.id]) {
                    parentMap[entry.id] = 
                        entry.type === "meta" ? new Metabolite() :
                        entry.type === "prot" ? new Protein() :
                        new Gene();
                    parentMap[entry.id].id = entry.id;
                    parentMap[entry.id].type = entry.type;
                    parentMap[entry.id].dev = entry.dev;
                    parentMap[entry.id].name = entry.name;
                    parentMap[entry.id].assignImg();
                    this.hasDeg = entry.type === "deg" ? true : this.hasDeg;
                    this.hasNoDeg = entry.type === "nodeg" ? true : this.hasNoDeg;
                    this.hasMeta = entry.type === "meta" ? true : this.hasMeta;
                    this.hasProt = entry.type === "prot" ? true : this.hasProt;
                }

                lastParent = parentMap[entry.id];
            } else if (["chroma", "meth", "urna","tf"].includes(entry.type)) {
                lastParent.hasMethyl = entry.type === "meth" ? true : lastParent.hasMethyl;
                lastParent.meth = entry.type === "meth" ? entry.dev : lastParent.meth;
                this.hasMethyl = entry.type === "meth" ? true : this.hasMethyl;
                
                lastParent.hasChroma = entry.type === "chroma" ? true : lastParent.hasChroma;
                lastParent.chroma = entry.type === "chroma" ? entry.dev : lastParent.chroma;
                this.hasChroma = entry.type === "chroma" ? true : this.hasChroma;


                lastParent.hasmiRNA = entry.type === "urna" ? true : lastParent.hasmiRNA;
                this.hasmiRNA = entry.type === "urna" ? true : this.hasmiRNA;

                if (entry.type === "urna") {
                    let urnaObj = new miRNA();
                    urnaObj.id = entry.id;
                    urnaObj.dev = entry.dev;
                    urnaObj.mirt = entry.mirt;
                    urnaObj.assignImg();
                    lastParent.urnas.push(urnaObj);
                }


                lastParent.hasTF = entry.type === "tf" ? true : lastParent.hasTF;
                this.hasTF = entry.type === "tf" ? true : this.hasTF;

                if (entry.type === "tf") {
                    let tfObj = new TF();
                    tfObj.id = entry.id;
                    tfObj.dev = entry.dev;
                    tfObj.name = entry.name;
                    tfObj.assignImg();
                    lastParent.tfs.push(tfObj);
                }
                lastParent.assignImg();
            }

            if (!referenceTable[entry.type].ids[entry.id]) {
                referenceTable[entry.type].ids[entry.id] = {};
                referenceTable[entry.type].ids[entry.id].complexes = [];
                referenceTable[entry.type].ids[entry.id].name = entry.mirt ? entry.mirt : entry.name;

            }
            referenceTable[entry.type].ids[entry.id].complexes.push(this.id);
            const withoutDuplicates = Array.from(new Set(referenceTable[entry.type].ids[entry.id].complexes));
            referenceTable[entry.type].ids[entry.id].complexes = withoutDuplicates;


        });
        
        // Convert parentMap to an array of parent objects

        this.components = Object.values(parentMap);
        console.log(this.components)
    }

    highLight = function(color) {
        if (color) {
            document.getElementById(this.id).style.border = `3px dotted ${color}`;
        } else {
            document.getElementById(this.id).style.border = '3px dotted red';
        }
	    
        highLightInterface.addHighLight(this);
    }
    lowLight = function() {
        document.getElementById(this.id).style.border = '0px dotted red';
        highLightInterface.removeHighLight(this);

    }
    hide = function() {
        document.getElementById(this.id).style.display = "none";
    }
    show = function() {
        document.getElementById(this.id).style.display = "block"; 
    }
    getGenes = function() {
        if (this.hasDeg === false && this.hasNoDeg === false) {
            return undefined;
        }

        let genesInComplex = {};
        for (let component of this.components) {
            if (component.type === "deg" || component.type === "nodeg") {
                genesInComplex[component.id] = {};
            }
        }
        return genesInComplex;
    }
    getProteins = function() {
        if (this.hasProt === false) {
            return undefined;
        }

        let protsInComplex = {};
        for (let component of this.components) {
            if (component.type === "prot") {
                protsInComplex[component.name] = {};
            }
        }
        return protsInComplex;
    }
    getMetabolites = function() {
        if (this.hasMeta === false) {
            return undefined;
        }

        let metabolitesInComplex = {};
        for (let component of this.components) {
            if (component.type === "meta") {
                metabolitesInComplex[component.id] = {};
            }
        }
        return metabolitesInComplex;
    }
    getMethylations = function() {
        if (this.hasMethyl === false) {
            return undefined;
        }

        let methylationsInComplex = {};
        for (let component of this.components) {
            if (component.hasMethyl === true) {
                methylationsInComplex[component.id] = {};
            } else {
                continue;
            }
        }
        return methylationsInComplex;
    }
    getChromas = function() {
        if (this.hasChroma === false) {
            return undefined;
        }

        let chromasInComplex = {};
        for (let component of this.components) {
            if (component.hasChroma === true) {
                chromasInComplex[component.id] = {};
            } else {
                continue;
            }
        }
        return chromasInComplex;
    }
    getmiRNAs = function() {
        if (this.hasmiRNA === false) {
            return undefined;
        }

        let urnasInComplex = {};
        for (let component of this.components) {
            if (component.type === "deg" || component.type === "nodeg" || component.type === "prot") {
                
                for (let urnaObj of component.urnas) {
                    urnasInComplex[urnaObj.id] = {};
                }

            } else {
                continue;
            }
        }
        return urnasInComplex;
    }
    getTFs = function() {
        if (this.hasTF === false) {
            return undefined;
        }

        let tfsInComplex = {};
        for (let component of this.components) {
            if (component.type === "deg" || component.type === "nodeg" || component.type === "prot") {
                for (let tfObj of component.tfs) {
                    tfsInComplex[tfObj.id] = {};
                }
            } else {
                continue;
            }
        }
        return tfsInComplex;
    }
    fillInfoDisplay = function(complexSelectedID) {

        let display = document.getElementById("info_display_div");
        display.innerHTML = "";

        //let previousInfos = document.querySelectorAll('.infoFont');
        //for (let previousInfo of previousInfos) {
        //    display.removeChild(previousInfo);
        //}
        let activeComplexObj;
        if (complexObjs[complexSelectedID]) {
            activeComplexObj = complexObjs[complexSelectedID];
        } else {
            activeComplexObj = new Complex(complexSelectedID,document.getElementById(complexSelectedID).parentElement.id);
            activeComplexObj.loadContent2();
        }
        

        for (let component of activeComplexObj.components) {
            let fonts = component.contentToFonts();
            for (let font of fonts) {
                display.appendChild(font);
                display.appendChild(document.createElement('br'));
            }
        }
    }
    contentToTSV = function() {
        
        for (let component of this.components) {
            if (component.type === "deg" || component.type === "nodeg") {
                
                downloadInterface.id2type[component.id] = component.type;
                if (!downloadInterface.id2name[component.id]) {
                    downloadInterface.id2name[component.id] = {};
                }
                downloadInterface.id2name[component.id][component.name] = {};

                if (!downloadInterface.id2map[component.id]) {
                    downloadInterface.id2map[component.id] = {};
                }

                if (subpoolRegex.test(this.parentPathway) === true) {
                    downloadInterface.id2map[component.id][subpoolRegex.exec(this.parentPathway)[1]] = {};    
                }

                
                if (!downloadInterface.id2dev[component.id] && component.dev) {
                    downloadInterface.id2dev[component.id] = component.dev;
                }
                if (!downloadInterface.meth2dev[component.id] && component.meth) {
                    downloadInterface.meth2dev[component.id] = component.meth;
                }
                if (!downloadInterface.chroma2dev[component.id] && component.chroma) {
                    downloadInterface.chroma2dev[component.id] = component.chroma;
                }
                if (component.urnas.length > 0) {
                    for (let urnaObj of component.urnas) {
                        if (!downloadInterface.urna2gene[urnaObj.mirt]) {
                            downloadInterface.urna2gene[urnaObj.mirt] = {};
                        }
                        downloadInterface.urna2gene[urnaObj.mirt][component.id] = {};
                        if (!downloadInterface.gene2urna[component.id]) {
                            downloadInterface.gene2urna[component.id] = {};
                        }

                        downloadInterface.gene2urna[component.id][urnaObj.id] = {};
                        downloadInterface.id2type[urnaObj.mirt] = "miRNA";
                        downloadInterface.id2dev[urnaObj.mirt] = urnaObj.dev;

                        if (!downloadInterface.id2name[urnaObj.mirt]) {
                            downloadInterface.id2name[urnaObj.mirt] = {};
                        }
                        downloadInterface.id2name[urnaObj.mirt][urnaObj.id] = {};
                        
                        if (!downloadInterface.id2map[urnaObj.mirt]) {
                            downloadInterface.id2map[urnaObj.mirt] = {};
                        }
                        if (subpoolRegex.test(this.parentPathway) === true) {
                            downloadInterface.id2map[urnaObj.mirt][subpoolRegex.exec(this.parentPathway)[1]] = {};    
                        }                    
                    }
                }
                if (component.tfs.length > 0) {
                    for (let tfObj of component.tfs) {

                        if (!downloadInterface.id2name[tfObj.id]) {
                            downloadInterface.id2name[tfObj.id] = {};
                        }
                        downloadInterface.id2name[tfObj.id][tfObj.name] = {};


                        if (!downloadInterface.tf2gene[tfObj.id]) {
                            downloadInterface.tf2gene[tfObj.id] = {};
                        }
                        downloadInterface.tf2gene[tfObj.id][component.id] = {};
                        if (!downloadInterface.gene2tf[component.id]) {
                            downloadInterface.gene2tf[component.id] = {};
                        }
                        downloadInterface.gene2tf[component.id][tfObj.id] = {};
                        downloadInterface.id2type[tfObj.id] = "Transcription Factor";
                        downloadInterface.id2dev[tfObj.id] = tfObj.dev;
                        if (!downloadInterface.id2map[tfObj.id]) {
                            downloadInterface.id2map[tfObj.id] = {};
                        }
                        if (subpoolRegex.test(this.parentPathway) === true) {
                            downloadInterface.id2map[tfObj.id][subpoolRegex.exec(this.parentPathway)[1]] = {};    
                        }
                    }
                }
            }
            if (component.type === "prot") {

                if (!downloadInterface.id2name[component.id]) {
                    downloadInterface.id2name[component.id] = {};
                }
                downloadInterface.id2name[component.id][component.name] = {};
                
                downloadInterface.id2type[component.id] = component.type;
                if (!downloadInterface.id2map[component.id]) {
                    downloadInterface.id2map[component.id] = {};
                }
                if (subpoolRegex.test(this.parentPathway) === true) {
                    downloadInterface.id2map[component.id][subpoolRegex.exec(this.parentPathway)[1]] = {};    
                }
                if (!downloadInterface.prot2dev[component.id] && component.dev) {
                    downloadInterface.prot2dev[component.id] = component.dev;
                }
                if (!downloadInterface.meth2dev[component.id] && component.meth) {
                    downloadInterface.meth2dev[component.id] = component.meth;
                }
                if (!downloadInterface.chroma2dev[component.id] && component.chroma) {
                    downloadInterface.chroma2dev[component.id] = component.chroma;
                }
                if (component.urnas.length > 0) {
                    for (let urnaObj of component.urnas) {
                        if (!downloadInterface.id2name[urnaObj.mirt]) {
                            downloadInterface.id2name[urnaObj.mirt] = {};
                        }
                        if (!downloadInterface.id2map[urnaObj.mirt]) {
                            downloadInterface.id2map[urnaObj.mirt] = {};
                        }
                        if (!downloadInterface.urna2prot[urnaObj.mirt]) {
                            downloadInterface.urna2prot[urnaObj.mirt] = {};
                        }
                        downloadInterface.urna2prot[urnaObj.mirt][component.id] = {};
                        if (!downloadInterface.prot2urna[component.id]) {
                            downloadInterface.prot2urna[component.id] = {};
                        }
                        downloadInterface.prot2urna[component.id][urnaObj.mirt] = {};
                        downloadInterface.id2type[urnaObj.mirt] = "miRNA";
                        downloadInterface.id2name[urnaObj.mirt][urnaObj.id] = {};

                        if (subpoolRegex.test(this.parentPathway) === true) {
                            downloadInterface.id2map[urnaObj.mirt][subpoolRegex.exec(this.parentPathway)[1]] = {};    
                        }                 
                    }
                }
                if (component.tfs.length > 0) {
                    for (let tfObj of component.tfs) {
                        if (!downloadInterface.tf2prot[tfObj.id]) {
                            downloadInterface.tf2prot[tfObj.id] = {};
                        }
                        if (!downloadInterface.id2name[tfObj.id]) {
                            downloadInterface.id2name[tfObj.id] = {};
                        }
                        downloadInterface.id2name[tfObj.id][tfObj.name] = {};
                        downloadInterface.tf2prot[tfObj.id][component.id] = {};
                        if (!downloadInterface.prot2tf[component.id]) {
                            downloadInterface.prot2tf[component.id] = {};
                        }
                        downloadInterface.prot2tf[component.id][tfObj.id] = {};
                        downloadInterface.id2type[tfObj.id] = "Transcription Factor";
                        if (!downloadInterface.id2map[tfObj.id]) {
                            downloadInterface.id2map[tfObj.id] = {};
                        }
                        if (subpoolRegex.test(this.parentPathway) === true) {
                            downloadInterface.id2map[tfObj.id][subpoolRegex.exec(this.parentPathway)[1]] = {};    
                        }                    
                    }
                }
            }


            if (component.type === "meta") {
                downloadInterface.id2type[component.id] = component.type;
                if (!downloadInterface.id2name[component.id]) {
                    downloadInterface.id2name[component.id] = {};
                }
                downloadInterface.id2name[component.id][component.name] = {};

                if (!downloadInterface.id2map[component.id]) {
                    downloadInterface.id2map[component.id] = {};
                }
                downloadInterface.id2map[component.id][this.parentPathway] = {};
                if (!downloadInterface.id2dev[component.id] && component.dev) {
                    downloadInterface.id2dev[component.id] = component.dev;
                }
                if (subpoolRegex.test(this.parentPathway) === true) {
                    downloadInterface.id2map[component.id][subpoolRegex.exec(this.parentPathway)[1]] = {};    
                }
            }
        }
    }
}

class Gene {
    constructor (id,type,dev,name) {
        this.id = id;
        this.type = type;
        this.name = name;
        this.dev = dev;
        this.hasmiRNA = false;
        this.hasMethyl = false;
        this.hasTF = false;
        this.hasChroma = false;
        this.meth = undefined;
        this.chroma = undefined;
        this.img = undefined;
        this.methImg = undefined;
        this.chromaImg = undefined;
        this.tfs = [];
        this.urnas = [];
    }
    loadMeth = function(methValue) {
        this.meth = methValue ? methValue : undefined;
        this.hasMethyl = true;
    }
    loadChroma = function(chromaValue) {
        this.chroma = chromaValue;
        this.hasChroma = true;
    }
    loadmiRNA = function(urnaObj) {
        this.urnas.push(urnaObj);
        this.hasmiRNA = true;
    }
    loadTf = function(tfObj) {
        this.tfs.push(tfObj);
        this.hasTF = true;
    }
    contentToFonts = function() {

        let arrayOfFonts = [];
        let arrayOfText = [];

        //arrayOfText.push(`mRNA ${this.id} (${this.name})`);
        arrayOfText.push(`<a target="_blank" href=\"https://www.ncbi.nlm.nih.gov/gene/${this.id}\">${this.id} (${this.name}) </a>`);
        if (this.type === "deg" && this.dev) {
            arrayOfText.push(` Effect Size: ${this.dev}`);
        }

        if (this.hasMethyl === true) {
            arrayOfText.push(` Methylation: ${this.meth}`);
        }
        if (this.hasChroma === true) {
            arrayOfText.push(` Chromatin: ${this.chroma}`);
        }
        if (this.hasmiRNA === true) {
            arrayOfText.push(' miRNAs:');
            for (let urna of this.urnas) {
                //arrayOfText.push(`  ${urna.id} (${urna.mirt})`);
                arrayOfText.push(`<a target="_blank" href=\"https://mirtarbase.cuhk.edu.cn/~miRTarBase/miRTarBase_2022/php/detail.php?mirtid=${urna.mirt}\">${urna.id} (${urna.mirt}) </a>`);
                arrayOfText.push(`   Effect Size: ${urna.dev}`);
            }
        }
        if (this.hasTF === true) {
            arrayOfText.push(' Transcription Factors:');
            for (let tf of this.tfs) {
                //arrayOfText.push(`  ${tf.id} (${tf.name})`);
                arrayOfText.push(`  <a target="_blank" href=\"http://www.gsea-msigdb.org/gsea/msigdb/cards/${tf.name}_TARGET_GENES\">${tf.id} (${tf.name}) </a>`);
                arrayOfText.push(`   Effect Size: ${tf.dev}`);
            }
        }

        for (let text of arrayOfText) {
            arrayOfFonts.push(spawnFont(undefined,"infoFont",text));
        }
        
        return(arrayOfFonts);
    }
    assignImg = function() {

        
        if (this.type == "deg") {
            if (this.dev !== undefined) {                
                if (this.dev > geneRightThreshold) {
                    this.img = "red_square.png";
                }
                if (this.dev < geneLeftThreshold) {
                    this.img = "green_square.png";
                }
            } else {
                this.img = "cyan_square.png";
            }
        }
        if (this.type == "nodeg") {
            this.img = "grey_square.png";
        }

        if (this.hasMethyl === true) {
            console.log("Assigning Methyl");
            if (this.meth !== undefined) {
                if (this.meth > methRightThreshold) { // this should be a threshold
                    this.methImg = "yellow_meth.png";
                }
                if (this.meth < methLeftThreshold) {
                    this.methImg = "blue_meth.png";
                }
            } else {
                this.methImg = "meth_orange.png";
            }
        }
        
        if (this.hasChroma === true) {
            console.log("Assigning Chroma");
            if (this.chroma !== undefined) {
                if (this.chroma > chromaRightThreshold) { // this should be a threshold
                    this.chromaImg = "yellow_meth.png";
                }
                if (this.chroma < chromaLeftThreshold) { // this should be a threshold
                    this.chromaImg = "blue_meth.png";
                }
            } else {
                this.chromaImg = "meth_orange.png";
            }
        }
        
    }
}

class Protein extends Gene {
    contentToFonts = function() {

        let arrayOfFonts = [];
        let arrayOfText = [];

        //arrayOfText.push(`Protein ${this.name} (${this.id})`);
        arrayOfText.push(`<a target="_blank" href=\" https://www.uniprot.org/uniprotkb/${this.id}/entry\">${this.id}</a><a target="_blank" href=\"https://www.ncbi.nlm.nih.gov/gene/${this.name}\">(${this.name}) </a>`)
        if (this.dev) {
            arrayOfText.push(` Effect Size: ${this.dev}`);
        }
        
        //if (this.hasMethyl || this.hasmiRNA || this.hasTF || this.hasChroma) {
        //    text += ":\n";
        //}

        if (this.hasMethyl === true) {
            arrayOfText.push(` Methylation: ${this.meth}`);
        }
        if (this.hasChroma === true) {
            arrayOfText.push(` Chromatin: ${this.chroma}`);
        }
        if (this.hasmiRNA === true) {
            arrayOfText.push(' miRNAs:');
            for (let urna of this.urnas) {
                arrayOfText.push(`<a target="_blank" href=\"https://mirtarbase.cuhk.edu.cn/~miRTarBase/miRTarBase_2022/php/detail.php?mirtid=${urna.mirt}\">${urna.id} (${urna.mirt}) </a>`);
                arrayOfText.push(`   Effect Size: ${urna.dev}`);
            }
        }
        if (this.hasTF === true) {
            arrayOfText.push(' Transcription Factors:');
            for (let tf of this.tfs) {
                arrayOfText.push(`  <a target="_blank" href=\"http://www.gsea-msigdb.org/gsea/msigdb/cards/${tf.name}_TARGET_GENES\"> (${tf.name}) </a>`);
                arrayOfText.push(`   Effect Size: ${tf.dev}`);
            }
        }
        for (let text of arrayOfText) {
            arrayOfFonts.push(spawnFont(undefined,"infoFont",text));
        }
        


        return(arrayOfFonts);
    }
    assignImg = function() {
        
        if (this.dev !== undefined) {                
            if (this.dev > protRightThreshold) {
                this.img = "red_square.png";
            }
            if (this.dev < protLeftThreshold) {
                this.img = "green_square.png";
            }
        } else {
            this.img = "cyan_square.png";
        }
        

        if (this.meth !== undefined) {
            if (this.meth > methRightThreshold) { // this should be a threshold
                this.methImg = "yellow_meth.png";
            }
            if (this.meth < methLeftThreshold) {
                this.methImg = "blue_meth.png";
            }
        } else {
            this.methImg = "blue_meth.png";
        }
        
        if (this.chromaImg !== undefined) {
            if (this.chroma > chromaRightThreshold) { // this should be a threshold
                this.chromaImg = "yellow_meth.png";
            }
            if (this.chroma < chromaRightThreshold) { // this should be a threshold
                this.chromaImg = "blue_meth.png";
            }
        } else {
            this.chromaImg = "blue_meth.png";
        }
        
    }
}

class Metabolite {
    constructor (id,type,dev,name) {
        this.id = id;
        this.type = type;
        this.dev = dev;
        this.name = name;
        this.img = "";
    }
    contentToFonts = function() {
        //let text = `Metabolite ${this.id} (${this.name})\n`;
        let arrayOfText = [];
        let arrayOfFonts = [];
        arrayOfText.push(`<a target="_blank" href=\"https://www.kegg.jp/entry/${this.id}\">${this.id} (${this.name}) </a>`);
        if (this.dev) {
            arrayOfText.push(` Effect Size: ${this.dev}`);
        }

        for (let text of arrayOfText) {
            arrayOfFonts.push(spawnFont(undefined,"infoFont",text));
        }

        return(arrayOfFonts);
    }
    assignImg = function() {

        if (this.dev !== undefined) {
            if (this.dev > metaRightThreshold) {
                this.img = "meta_up.png";
            }
            if (this.dev < metaLeftThreshold) {
                this.img = "meta_down.png";
            }
        } else {
            this.img = "yellow_meta.png";
        }
    }
}

class TF {
    constructor (id,type,dev,name) {
        this.id = id;
        this.type = type;
        this.dev = dev;
        this.name = name;
    }
    assignImg = function() {

        if (this.dev !== undefined) {
            if (this.dev > geneRightThreshold) {
                this.img = "yellow_tf.png";
            }
            if (this.dev < geneLeftThreshold) {
                this.img = "blue_tf.png";
            }
        } else {
            this.img = "tf_orange.png";
        }   
    }
}

class miRNA {
    constructor (id,type,dev,mirt) {
        this.id = id;
        this.type = type;
        this.mirt = mirt;
        this.dev = dev;
    }
    assignImg = function() {

        if (this.dev !== undefined) {
            if (this.dev > urnaRightThreshold) {
                this.img = "yellow_circle.png";
            }
        
            if (this.dev < urnaLeftThreshold) {
                this.img = "blue_circle.png";
            }
        } else {
            this.img = "small_circle_orange.png";
        }
    }
}

class Pathway {
    constructor (id,name) {
        this.id = id;
        this.name = name;
        this.complexes = [];
    }
    addComplex = function(complex) {
        if (typeof complex  !== "object") {
            console.log("Not a Complex Obj!");
            return
        }
        this.complexes.push(complex);
    }
    loadComplexes = function() {
        let complexImgs = document.getElementById(`${this.id}_complexes`).querySelectorAll(".complex");
        for (let complexImg of complexImgs) {
            let complexObj = new Complex (complexImg.id,this.id);
            complexObj.loadContent();
            this.addComplex(complexObj);
            complexObjs[complexObj.id] = complexObj; 
        }
    }
}




class queryObj {
    constructor(queryType,id,type,first,second) {
        this.queryType = queryType;
        this.id = id;
        this.type = type;
        this.first = first;
        this.second = second;
    }
}


