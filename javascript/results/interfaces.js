class HighLightInterface {
    constructor() {
        this.highLighted = {};
        this.enabledMaps = {};
        this.genesHL = {};
        this.protsHL = {};
        this.metasHL = {};
        this.methsHL = {};
        this.chromasHL = {};
        this.urnasHL = {};
        this.tfsHL = {};
    }
    restoreDefault = function() {
        for (let complexId in this.highLighted) {
            this.highLighted[complexId].lowLight();
        }
        this.highLighted = {};
        this.enabledMaps = {};
        this.genesHL = {};
        this.protsHL = {};
        this.metasHL = {};
        this.methsHL = {};
        this.urnasHL = {};
        this.tfsHL = {};
        this.chromHL = {};
    }
    restoreByHLType = function(color) {
        for (let complexId in this.highLighted) {
            
            if (document.getElementById(complexId).style.border === `3px dotted ${color}`) {
                this.highLighted[complexId].lowLight();
            }
        }
    }
    addHighLight = function(complex) {
        this.highLighted[complex.id] = complex;
    }
    removeHighLight = function(complex) {
        this.highLighted[complex.id] = {};
        delete this.highLighted[complex.id];
    }
    fillHighlighters = function () {

        for (let complexId in queryInterface.validComplexIDs) {
            let genesInComp = complexObjs[complexId].getGenes();
            let metasInComp = complexObjs[complexId].getMetabolites();
            let protsInComp = complexObjs[complexId].getProteins();
            let chromInComp = complexObjs[complexId].getChromas();
            let methsInComp = complexObjs[complexId].getMethylations();
            let urnasInComp = complexObjs[complexId].getmiRNAs();
            let tfsInComp = complexObjs[complexId].getTFs();
            
            if (genesInComp !== undefined) {
                for (let geneID in genesInComp) {
                    this.genesHL[geneID] = {};
                }
            }
            if (protsInComp !== undefined) {
                for (let protID in protsInComp) {
                    this.protsHL[protID] = {};
                }
            }
            if (metasInComp !== undefined) {
                for (let metaID in metasInComp) {
                    this.metasHL[metaID] = {};
                }
            }
            if (urnasInComp !== undefined) {
                for (let urnaID in urnasInComp) {
                    this.urnasHL[urnaID] = {};
                }
            }
            if (chromInComp !== undefined) {
                for (let chromaID in chromInComp) {
                    this.chromasHL[chromaID] = {};
                }
            }
            if (methsInComp !== undefined) {
                for (let methID in methsInComp) {
                    this.methsHL[methID] = {};
                }
            }
            if (tfsInComp !== undefined) {
                for (let tfID in tfsInComp) {
                    this.tfsHL[tfID] = {};
                }
            }
        }

        if (document.getElementById('geneHLDynamic') && document.getElementById('geneHLDefault')) {
            let select = document.getElementById('geneHLDynamic');
            for (let i = 0;i < select.options.length;i++) {
                if (this.genesHL[select.options[i].value]) {
                    continue;
                } else {
                    select.remove(i);
                    i--;
                }
            }
            const firstOpt = document.getElementById('geneHLDefault').options[0].cloneNode(true);
            select.add(firstOpt,0);
            document.getElementById('geneHLDynamic').style.display = "block";
            document.getElementById('geneHLDefault').style.display = "none";
            document.getElementById('geneHLDynamic').selectedIndex = 0;
            document.getElementById('geneHLDefault').selectedIndex = 0;
            selectorInterface.updateEnabled('geneHLDynamic');
        }

        if (document.getElementById('protHLDynamic') && document.getElementById('protHLDefault')) {
            let select = document.getElementById('protHLDynamic');
            for (let i = 0;i < select.options.length;i++) {
                if (this.protsHL[select.options[i].value]) {
                    continue;
                } else {
                    select.remove(i);
                    i--;
                }
            }
            const firstOpt = document.getElementById('protHLDefault').options[0].cloneNode(true);
            select.add(firstOpt,0);
            document.getElementById('protHLDynamic').style.display = "block";
            document.getElementById('protHLDefault').style.display = "none";
            document.getElementById('protHLDynamic').selectedIndex = 0;
            document.getElementById('protHLDefault').selectedIndex = 0;
            selectorInterface.updateEnabled('protHLDynamic');
        }

        console.log(this.urnasHL);
        if (document.getElementById('urnaHLDynamic') && document.getElementById('urnaHLDefault')) {
            let select = document.getElementById('urnaHLDynamic');
            for (let i = 0;i < select.options.length;i++) {
                if (this.urnasHL[select.options[i].value]) {
                    continue;
                } else {
                    select.remove(i);
                    i--;
                }
            }
            const firstOpt = document.getElementById('urnaHLDefault').options[0].cloneNode(true);
            select.add(firstOpt,0);
            document.getElementById('urnaHLDynamic').style.display = "block";
            document.getElementById('urnaHLDefault').style.display = "none";
            document.getElementById('urnaHLDynamic').selectedIndex = 0;
            document.getElementById('urnaHLDefault').selectedIndex = 0;
            selectorInterface.updateEnabled('urnaHLDynamic');
        }
        
        if (document.getElementById('metaHLDynamic') && document.getElementById('metaHLDefault')) {
            let select = document.getElementById('metaHLDynamic');
            for (let i = 0;i < select.options.length;i++) {
                if (this.metasHL[select.options[i].value]) {
                    continue;
                } else {
                    select.remove(i);
                    i--;
                }
            }
            const firstOpt = document.getElementById('metaHLDefault').options[0].cloneNode(true);
            select.add(firstOpt,0);
            document.getElementById('metaHLDynamic').style.display = "block";
            document.getElementById('metaHLDefault').style.display = "none";
            document.getElementById('metaHLDynamic').selectedIndex = 0;
            document.getElementById('metaHLDefault').selectedIndex = 0;
            selectorInterface.updateEnabled('metaHLDynamic');
        }

        if (document.getElementById('chromaHLDynamic') && document.getElementById('chromaHLDefault')) {
            let select = document.getElementById('chromaHLDynamic');
            for (let i = 0;i < select.options.length;i++) {
                if (this.chromasHL[select.options[i].value]) {
                    continue;
                } else {
                    select.remove(i);
                    i--;
                }
            }
            const firstOpt = document.getElementById('chromaHLDefault').options[0].cloneNode(true);
            select.add(firstOpt,0);
            document.getElementById('chromaHLDynamic').style.display = "block";
            document.getElementById('chromaHLDefault').style.display = "none";
            document.getElementById('chromaHLDynamic').selectedIndex = 0;
            document.getElementById('chromaHLDefault').selectedIndex = 0;
            selectorInterface.updateEnabled('chromaHLDynamic');
        }

        if (document.getElementById('methHLDynamic') && document.getElementById('methHLDefault')) {
            let select = document.getElementById('methHLDynamic');
            for (let i = 0;i < select.options.length;i++) {
                if (this.methsHL[select.options[i].value]) {
                    continue;
                } else {
                    select.remove(i);
                    i--;
                }
            }
            const firstOpt = document.getElementById('methHLDefault').options[0].cloneNode(true);
            select.add(firstOpt,0);
            document.getElementById('methHLDynamic').style.display = "block";
            document.getElementById('methHLDefault').style.display = "none";
            document.getElementById('methHLDynamic').selectedIndex = 0;
            document.getElementById('methHLDefault').selectedIndex = 0;
            selectorInterface.updateEnabled('methHLDynamic');
        }

        if (document.getElementById('tfHLDynamic') && document.getElementById('tfHLDefault')) {
            let select = document.getElementById('tfHLDynamic');
            for (let i = 0;i < select.options.length;i++) {
                if (this.tfsHL[select.options[i].value]) {
                    continue;
                } else {
                    select.remove(i);
                    i--;
                }
            }
            const firstOpt = document.getElementById('tfHLDefault').options[0].cloneNode(true);
            select.add(firstOpt,0);
            document.getElementById('tfHLDynamic').style.display = "block";
            document.getElementById('tfHLDefault').style.display = "none";
            document.getElementById('tfHLDynamic').selectedIndex = 0;
            document.getElementById('tfHLDefault').selectedIndex = 0;
            selectorInterface.updateEnabled('tfHLDynamic');
        }

    }
    highLightById = function (id,type) {

        this.enabledMaps = {};
        if (id === "all") {
            this.restoreByHLType('magenta');
            this.enableAllMapOptions();
            return;
        }
        if (referenceTable[type].ids[id].complexes) {
            for (let complexID of referenceTable[type].ids[id].complexes) {
                complexObjs[complexID].highLight('magenta');
                this.addHighLight(complexObjs[complexID]);
                //this.disableMapOption(complexObjs[complexID].parentPathway);
                this.enabledMaps[complexObjs[complexID].parentPathway] = {};
            }
        }

        this.checkMapsToKeep();
    }

    checkMapsToKeep = function () {
        let selectDynamic = document.getElementById('mapselectDynamic');
        let selectDefault = document.getElementById('mapselectDefault');

        for (let option of selectDynamic.options) {
            if (this.enabledMaps[option.value]) {
                option.disabled = false;
                continue;
            } else {
                option.disabled = true;
            }
        }
        for (let option of selectDefault.options) {
            if (this.enabledMaps[option.value]) {
                option.disabled = false;
                continue;
            } else {
                option.disabled = true;
            }
        }
    }


    disableMapOption = function (optionID) {
        let selectDynamic = document.getElementById('mapselectDynamic');
        let selectDefault = document.getElementById('mapselectDefault');
        for (let option of selectDynamic.options) {
            if (this.enabledMaps[optionID]) {
                console.log(`Continue on ${optionID}`);
                continue;
            }
            if (option.value === optionID) {
                option.disabled = false;
                this.enabledMaps[optionID] = {};
                console.log(`${option.value} vs ${optionID}`);
            } else {
                option.disabled = true;
            }
        }
        for (let option of selectDefault.options) {
            if (this.enabledMaps[optionID]) {
                console.log(`Continue on ${optionID}`);
                continue;
            }
            if (option.value === optionID) {
                option.disabled = false;
                this.enabledMaps[optionID] = {};
                console.log(`${option.value} vs ${optionID}`);
            } else {
                option.disabled = true;
            }
        }
    } //maybe useless
    enableAllMapOptions = function () {
        let selectDynamic = document.getElementById('mapselectDynamic');
        let selectDefault = document.getElementById('mapselectDefault');

        for (let option of selectDynamic.options) {
            option.disabled = false;
        }
        for (let option of selectDefault.options) {
            option.disabled = false;
        }
    }
}

class SelectorInterface {
    constructor() {
        this.defaultOptions = {};
        this.enabledOptions = {};
        this.disabledOptions = {};
        this.selectedValues = {};
    }


    addOption = function(selectorID,optionValue) {
        let newOption = new Option(this.defaultOptions[selectorID][optionValue],optionValue);



        document.getElementById(selectorID).add(newOption,undefined);

        let optionsCollection = document.getElementById(selectorID).options;
        let optionsArray = [];
        for (let opt of optionsCollection) {
            optionsArray.push(opt);
        }
        let optionsSorted = sortOptionsByValue(optionsArray);

        for (let i = 0; i < optionsCollection.length; i++) {
            optionsCollection[i] = optionsSorted[i];
        }
        this.updateEnabled(selectorID);
    }
    removeOption = function(selectorID,optionValue) {
        let selectorOptions = document.getElementById(selectorID).options;
        for (let option of selectorOptions) {
            if (option.value === optionValue) {
                document.getElementById(selectorID).remove(option.index);
            }
        }
        this.updateDisabled(selectorID);
    }
    emptySelector = function (selectorID) {
        while (document.getElementById(selectorID).options.length > 0) {
            document.getElementById(selectorID).remove(0);
        }
    }
    initDefault = function (selectorID) {
        this.enabledOptions[selectorID] = {};
        this.disabledOptions[selectorID] = {};
        if (!this.defaultOptions[selectorID]) {
            let selectorOptions = document.getElementById(selectorID).options;
            this.defaultOptions[selectorID] = {};
            for (let option of selectorOptions) {                
                this.defaultOptions[selectorID][option.value] = option.textContent;
            }
        }
        this.updateEnabled(selectorID);
    }
    updateEnabled = function (selectorID) {
        let selectorOptions = document.getElementById(selectorID).options;
        //var defaultCheck = this.defaultOptions[selectorID];
        this.enabledOptions[selectorID] = {};
        //console.log(defaultCheck);
        for (let option of selectorOptions) {
            
            this.enabledOptions[selectorID][option.value] = option.textContent;
            //delete defaultCheck[option.value];

            if (this.disabledOptions[selectorID][option.value]) {
                delete this.disabledOptions[selectorID][option.value];
            }
        }

        //for (keyRemains in defaultCheck) {
        //    this.disabledOptions[selectorID][keyRemains] = defaultCheck[keyRemains];
        //}
    }
    updateDisabled = function (selectorID) {
        console.log(selectorID);
        let selectorOptions = document.getElementById(selectorID).options;
        for (let option of selectorOptions) {
            
            this.disabledOptions[selectorID][option.value] = option.textContent;

            if (this.enabledOptions[selectorID][option.value]) {
                delete this.enabledOptions[selectorID][option.value];
            }
        }
    }
    updateSelected = function (selectorID) {
        this.selectedValues[selectorID] = {};
        this.selectedValues[selectorID].value = document.getElementById(selectorID).value;
        this.selectedValues[selectorID].text = document.getElementById(selectorID).selectedOptions[0].innerText;
        console.log("Update Done");
    }


    restoreDefault = function (selectorID) {
        //this.emptySelector(selectorID);
        
        //for (let defaultValue in this.defaultOptions[selectorID]) {
        //    this.addOption(selectorID,defaultValue);

        //}
        document.getElementById(`${selectorID}Dynamic`).style.display = "none";
        document.getElementById(`${selectorID}Default`).style.display = "block";
        cloneSelect(document.getElementById(`${selectorID}Default`),document.getElementById(`${selectorID}Dynamic`));
    }
    restoreDefaultAll = function() {
        //for (let selectorID in this.defaultOptions) {
        //    this.restoreDefault(selectorID);
        //}
        this.restoreDefault('mapselect');
        if (document.getElementById('geneHLDefault')) {
            this.restoreDefault('geneHL');
            document.getElementById('geneHLDynamic').style.display = "none";
            document.getElementById('geneHLDefault').style.display = "block";
        }
        if (document.getElementById('protHLDefault')) {
            this.restoreDefault('protHL');
            document.getElementById('protHLDynamic').style.display = "none";
            document.getElementById('protHLDefault').style.display = "block";
        }
        if (document.getElementById('metaHLDefault')) {
            this.restoreDefault('metaHL');
            document.getElementById('metaHLDynamic').style.display = "none";
            document.getElementById('metaHLDefault').style.display = "block";
        }
        if (document.getElementById('urnaHLDefault')) {
            this.restoreDefault('urnaHL');
            document.getElementById('urnaHLDynamic').style.display = "none";
            document.getElementById('urnaHLDefault').style.display = "block";
        }
        if (document.getElementById('tfHLDefault')) {
            this.restoreDefault('tfHL');
            document.getElementById('tfHLDynamic').style.display = "none";
            document.getElementById('tfHLDefault').style.display = "block";
        }
    }

} 

class UlInterface {
    constructor() {
        this.onDisplay = {
            logistics_ul_pool: {},
            logistics_ul_pool_agreement: {}
        }
    }
    addLiFromSelector = function (optionValue,optionType,ulID) {
        
        var ul = document.getElementById(ulID);

        if (optionType === "agreement") {

            let inst = optionValue.split("|");
            //let queryObj = {first:inst[0],second:inst[1],type:inst[2]};
            //queryObj.id = optionValue;

            let queryObjAgr = new queryObj("agreement",optionValue,inst[2],inst[0],inst[1]);

            for (let queryID in queryInterface.queryByAgreement.queryInst) {
                if (queryInterface.queryByAgreement.queryInst[queryID].first === queryObjAgr.first && queryInterface.queryByAgreement.queryInst[queryID].second === queryObjAgr.second) {
                    alert("Agreement already selected!");
                    //ulInterface.updateOnDisplay(ulID);
                    return;
                }
                if (queryInterface.queryByAgreement.queryInst[queryID].second === queryObjAgr.first && queryInterface.queryByAgreement.queryInst[queryID].first === queryObjAgr.second) {
                    alert("Agreement already selected!");
                    //ulInterface.updateOnDisplay(ulID);
                    return;
                }
            }
            
            let text = `${optionValue}`;
            let li = spawnLi(`${optionValue}`,'agreementLi',undefined,text);
            let rmButton = spawnInput (undefined,"ul_rm_button","button","X","ulInterface.removeLi(this.parentElement.id)");
            rmButton.style = "margin-left:25px;width:20px;height:20px;font-size:10px;";
            li.name = optionValue;

            

            li.appendChild(rmButton);
            ul.appendChild(li);
            //this.updateOnDisplay(ulID);
            
            queryInterface.addAgreementToQuery(queryObjAgr);
            return;

        }
        
        if (optionType !== "agreement" && optionType !== "ontology") {
            let text = `${optionValue}`;
            let li = spawnLi(`${optionValue}`,'idLi',undefined,text);
            let rmButton = spawnInput (undefined,"ul_rm_button","button","X","ulInterface.removeLi(this.parentElement.id)");
            rmButton.style = "margin-left:25px;width:20px;height:20px;font-size:10px;";
            li.name = optionValue;
            li.setAttribute('type',optionType);
            if (optionType === "gene") {
                li.style.backgroundColor = '#e6faff';
                li.onmouseover = function() { //still don't know why css isn't working
                    this.style.backgroundColor = "#eee";
                }
                li.onmouseout = function() {
                    this.style.backgroundColor = "#e6faff";
                }
            }
            if (optionType === "urna") {
                li.style.backgroundColor = '#ffb3b3';
                li.onmouseover = function() 
                {
                    this.style.backgroundColor = "#ffc9c9";
                }
                li.onmouseout = function() 
                {
                    this.style.backgroundColor = "#ffb3b3";
                }
            }
            if (optionType === "meta") {
                li.style.backgroundColor = '#ffffb3';
                li.onmouseover = function() 
                {
                    this.style.backgroundColor = "#f7f7c1";
                }
                li.onmouseout = function() 
                {
                    this.style.backgroundColor = "#ffffb3";
                }
            }
            if (optionType === "prot") {
                li.style.backgroundColor = '#e6b3ff';
                li.onmouseover = function() 
                {
                    this.style.backgroundColor = "#eeccff";
                }
                li.onmouseout = function() 
                {
                    this.style.backgroundColor = "#e6b3ff";
                }
            }

            if (queryInterface.queryById.queryInst[li.id] && queryInterface.queryById.queryInst[li.id].type === li.type) {
                return;
            }

            li.appendChild(rmButton);
            ul.appendChild(li);
            this.updateOnDisplay(ulID);
            
            //let queryObj = {id:optionValue,type:optionType};
            let queryObjId = new queryObj("id",optionValue,optionType,undefined,undefined);
            queryInterface.addIdToQuery(queryObjId);
            return;
        }
        if (optionType === "ontology") {
            let queryObjOnt = new queryObj("ont",optionValue,undefined);

            let name = document.getElementById('ontUlSelect').selectedOptions[0].label;
            let text = `${name} (${optionValue})`;
            let li = spawnLi(`${optionValue}`,'ontLi',undefined,text);
            let rmButton = spawnInput (undefined,"ul_rm_button","button","X","ulInterface.removeLi(this.parentElement.id)");
            rmButton.style = "margin-left:25px;width:20px;height:20px;font-size:10px;";
            li.name = optionValue;

            if (queryInterface.queryByOnt.queryInst[li.id]) {
                return;
            }

            li.appendChild(rmButton);
            ul.appendChild(li);

            queryInterface.addOntToQuery(queryObjOnt);
            return;
        }
    }
    removeLi = function(liID) {
        let li = document.getElementById(liID);
        let ulID = li.parentElement.id;
        li.parentElement.removeChild(li);
        console.log(li.id);
        if (queryInterface.queryById.queryInst[li.id]) {
            delete queryInterface.queryById.queryInst[li.id];
        }
        if (queryInterface.queryByAgreement.queryInst[li.id]) {
            delete queryInterface.queryByAgreement.queryInst[li.id];
        }
        if (queryInterface.queryByOnt.queryInst[li.id]) {
            delete queryInterface.queryByOnt.queryInst[li.id];
        }

        this.updateOnDisplay(ulID);
    }
    updateOnDisplay = function (ulID) { //maybe this should be removed
        this.onDisplay[ulID] = {};
        let className;
        if (ulID === "logistics_ul_pool") {
            className = ".logistics_pool_li";
        }
        if (ulID === "logistics_ul_pool_agreement") {
            className = ".logistics_pool_li_agreement";
        }
        let lis = document.querySelectorAll(className);
        for (let li of lis) {
            
            if (ulID === "logistics_ul_pool") {
                this.onDisplay[ulID][li.id].type = li.type;
                this.onDisplay[ulID][li.id].name = li.name;
            } else {
                this.onDisplay[ulID][li.id] = {};
            }
        }
    }
    removeAllLis = function (className) {
        //this.onDisplay[ulID] = {};
        let lis = document.querySelectorAll(className);
        for (let li of lis) {
            document.getElementById('queryUlPool').removeChild(li);
        }
        
    }
    resetLis = function() {
        ulInterface.removeAllLis('.idLi');
        ulInterface.removeAllLis('.agreementLi');
        ulInterface.removeAllLis('.ontLi');
    }
}

class DownloadInterface {
    constructor() {
        this.id2name    = {};
        this.id2type    = {};
        this.id2dev     = {};
        this.id2map     = {};
        this.gene2urna  = {};
        this.gene2map   = {};
        this.gene2tf    = {};
        this.tf2gene    = {};
        this.tf2prot    = {};
        this.tf2map     = {};
        this.urna2gene  = {};
        this.urna2map   = {};
        this.prot2urna  = {};
        this.prot2tf    = {};
        this.prot2map   = {};
        this.urna2prot  = {};
        this.gene2dev   = {};
        this.urna2dev   = {};
        this.meta2dev   = {};
        this.prot2dev   = {};
        this.meta2map   = {};
        this.meth2dev   = {};
        this.tf2dev     = {};
        this.chroma2dev = {};
        this.Text = "";
    }
}

class QueryInterface {

    constructor() {
        this.status = false;
        this.queryById = {
            queryInst: {}
        };
        this.queryByAgreement = {
            queryInst: {}
            //validPathways: {}
        };
        this.queryByOnt = {
            queryInst: {}
        };
        this.validPathwayIDs = {};
        this.validComplexIDs = {};
    }

    queryExec = function() {

        highLightInterface.enableAllMapOptions();
        let pathwayIDsTmp = Object.keys(pathwayObjs);
        for (let key of pathwayIDsTmp) {
            this.validPathwayIDs[key] = {};
            for (let complex of pathwayObjs[key].complexes) {
                this.validComplexIDs[complex.id] = {};
            }
        }


        this.queryExecById();
        this.queryExecByAgreement();
        this.queryExecByOnt();

        document.getElementById('mapselectDefault').style.display = "none";
        document.getElementById('mapselectDynamic').style.display = "block";
        
        if (document.getElementById('mapselectDynamic').options.length === 0) {
            document.getElementById('mapselectDefault').style.display = "block";
            document.getElementById('mapselectDynamic').style.display = "none";
            alert('Your query returned nothing :(');
        }


        //if (document.getElementById('mapselectDefault').style.display === "block") {
        //    changemap(document.getElementById('mapselectDefault'));
        //}
        

        highLightInterface.fillHighlighters();
        selectorInterface.updateEnabled('mapselectDynamic');

        this.status = true;
        document.getElementById('select_type_main').dispatchEvent(changeEvent);
        if (document.getElementById('mapselectDynamic').style.display === "block") {
            changemap(document.getElementById('mapselectDynamic'));
        }
    }
    queryExecById = function() {

        let validation = 0;
        for (let idQuery in this.queryById.queryInst) {
            for (let pathwayID in this.validPathwayIDs) {
                let currentPathway = pathwayObjs[pathwayID];
                validation = 0;
                for (let complex of currentPathway.complexes) {
                    if (this.queryById.queryInst[idQuery].type === "gene") {
                        if (complex.hasDeg === false && complex.hasNoDeg === false) {
                            continue;
                        }
                    }
                    if (this.queryById.queryInst[idQuery].type === "prot") {
                        if (complex.hasProt === false) {
                            continue;
                        }
                    }
                    if (this.queryById.queryInst[idQuery].type === "urna") {
                        if (complex.hasmiRNA === false) {
                            continue;
                        }
                    }
                    if (this.queryById.queryInst[idQuery].type === "meth") {
                        if (complex.hasMeth === false) {
                            continue;
                        }
                    }
                    if (this.queryById.queryInst[idQuery].type === "chroma") {
                        if (complex.hasChroma === false) {
                            continue;
                        }
                    }
                    if (this.queryById.queryInst[idQuery].type === "tf") {
                        if (complex.hasTF === false) {
                            continue;
                        }
                    }
                    if (this.queryById.queryInst[idQuery].type === "meta") {
                        if (complex.hasMeta === false) {
                            continue;
                        }
                    }

                    for (let complexComponent of complex.components) {
                        if (complexComponent.id === idQuery || complexComponent.name === idQuery) {
                            validation++;
                            complex.highLight();
                            break;
                        }
                        if (complexComponent.urnas) {
                            for (let urnaComponent of complexComponent.urnas) {
                                if (urnaComponent.id === idQuery) {
                                    validation++;
                                    complex.highLight();
                                    break;
                                }
                            }
                        }
                        
                        if (complexComponent.tfs) {
                            for (let tfComponent of complexComponent.tfs) {
                                if (tfComponent.id === idQuery) {
                                    validation++;
                                    complex.highLight();
                                    break;
                                }
                            }
                        }
                        
                    }
                }
                //perform validation here and reset
                if (validation === 0) {
                    delete this.validPathwayIDs[pathwayID];
                    let complexesToPurge = document.getElementById(`${pathwayID}_complexes`).querySelectorAll(".complex");
                    for (let complexToPurge of complexesToPurge) {
                        if (this.validComplexIDs[complexToPurge.id]) {
                            delete this.validComplexIDs[complexToPurge.id];
                        }
                    }
                    selectorInterface.removeOption('mapselectDynamic',pathwayID);
                }
            }
        }
    }
    queryExecByAgreement = function() {
    
        let validation = 0;
        for (let idQuery in this.queryByAgreement.queryInst) {
            let lookingFor = {};
            lookingFor[this.queryByAgreement.queryInst[idQuery].first] = {};
            lookingFor[this.queryByAgreement.queryInst[idQuery].second] = {};
            lookingFor[this.queryByAgreement.queryInst[idQuery].type] = {};
            console.log(lookingFor);
            for (let pathwayID in this.validPathwayIDs) {
                let currentPathway = pathwayObjs[pathwayID];
                validation = 0;
                for (let complex of currentPathway.complexes) {
                    if (!this.validComplexIDs[complex.id]) {
                        complex.hide();
                        continue;
                    }
                    if (lookingFor['gene']) {
                        if (complex.hasDeg === false && complex.hasNoDeg === false) {
                            delete this.validComplexIDs[complex.id];
                            complex.hide();
                            continue;
                        }
                    }
                    if (lookingFor['prot']) {
                        if (complex.hasProt === false) {
                            delete this.validComplexIDs[complex.id];
                            complex.hide();
                            continue;
                        }
                    }
                    if (lookingFor['urna']) {
                        if (complex.hasmiRNA === false) {
                            delete this.validComplexIDs[complex.id];
                            complex.hide();
                            continue;
                        }
                    }
                    if (lookingFor['meth']) {
                        if (complex.hasMeth === false) {
                            delete this.validComplexIDs[complex.id];
                            complex.hide();
                            continue;
                        }
                    }
                    if (lookingFor['chroma']) {
                        if (complex.hasChroma === false) {
                            delete this.validComplexIDs[complex.id];
                            complex.hide();
                            continue;
                        }
                    }
                    if (lookingFor['tf']) {
                        if (complex.hasTF === false) {
                            delete this.validComplexIDs[complex.id];
                            complex.hide();
                            continue;
                        }
                    }
                    if (lookingFor['meta']) {
                        if (complex.hasMeta === false) {
                            delete this.validComplexIDs[complex.id];
                            complex.hide();
                            continue;
                        }
                    }
                    if (lookingFor['gene'] && lookingFor['prot']) {
                        let geneID = "";
                        let protID = "";
                        let geneDev;
                        let protDev;
                        for (let complexComponent of complex.components) {
                            if (complexComponent.type === "deg") {
                                geneID = complexComponent.id;
                                geneDev = complexComponent.dev;
                                console.log(`Gene Found: ${geneID}`);
                            }
                            if (complexComponent.type === "prot") {
                                protID = complexComponent.name;
                                protDev = complexComponent.dev;
                                console.log(`Protein Found: ${protID}`);
                            }
                            if (geneID === protID) {
                                console.log(`Found Same Gene and Protein`);
                                if (lookingFor['+'] && geneDev > 0 && protDev > 0) {
                                    this.validComplexIDs[complex.id] = {};
                                    validation++;
                                    complex.show();
                                    break;
                                }
                                if (lookingFor['+'] && geneDev < 0 && protDev < 0) {
                                    this.validComplexIDs[complex.id] = {};
                                    validation++;
                                    complex.show();
                                    break;
                                }
                                if (lookingFor['-'] && geneDev < 0 && protDev > 0) {
                                    this.validComplexIDs[complex.id] = {};
                                    validation++;
                                    complex.show();
                                    break;
                                }
                                if (lookingFor['-'] && geneDev > 0 && protDev < 0) {
                                    this.validComplexIDs[complex.id] = {};
                                    validation++;
                                    complex.show();
                                    break;
                                }
                            }
                            delete this.validComplexIDs[complex.id];
                            complex.hide();
                        }
                        continue;
                    }
                    for (let complexComponent of complex.components) {
                        let mainDev = complexComponent.dev;
                        if (lookingFor['urna'] && complexComponent.urnas.length > 0) {
                            for (let urnaObj of complexComponent.urnas) {
                                if (mainDev < 0 && urnaObj.dev > 0 && lookingFor['-']) {
                                    complex.show();
                                    validation++;
                                    this.validComplexIDs[complex.id] = {};
                                    
                                    break;
                                }
                                if (mainDev > 0 && urnaObj.dev < 0 && lookingFor['-']) {
                                    complex.show();
                                    validation++;
                                    this.validComplexIDs[complex.id] = {};
                                    break;
                                }
                                if (mainDev > 0 && urnaObj.dev > 0 && lookingFor['+']) {
                                    complex.show();
                                    validation++;
                                    this.validComplexIDs[complex.id] = {};
                                    break;
                                }
                                if (mainDev < 0 && urnaObj.dev < 0 && lookingFor['+']) {
                                    complex.show();
                                    validation++;
                                    this.validComplexIDs[complex.id] = {};
                                    break;
                                }
                                delete this.validComplexIDs[complex.id];
                                complex.hide();
                            }
                        }
                        if (lookingFor['tf'] && complexComponent.tfs.length > 0) {
                            for (let tfObj of complexComponent.tfs) {
                                if (mainDev < 0 && tfObj.dev > 0 && lookingFor['-']) {
                                    complex.show();
                                    validation++;
                                    this.validComplexIDs[complex.id] = {};
                                    break;
                                }
                                if (mainDev > 0 && tfObj.dev < 0 && lookingFor['-']) {
                                    complex.show();
                                    validation++;
                                    this.validComplexIDs[complex.id] = {};
                                    break;
                                }
                                if (mainDev > 0 && tfObj.dev > 0 && lookingFor['+']) {
                                    complex.show();
                                    validation++;
                                    this.validComplexIDs[complex.id] = {};
                                    break;
                                }
                                if (mainDev < 0 && tfObj.dev < 0 && lookingFor['+']) {
                                    complex.show();
                                    validation++;
                                    this.validComplexIDs[complex.id] = {};
                                    break;
                                }
                                delete this.validComplexIDs[complex.id];
                                complex.hide();
                            }
                        }
                        if (lookingFor['meth']) {
                            if (mainDev < 0 && complexComponent.meth > 0 && lookingFor['-']) {
                                complex.show();
                                validation++;
                                this.validComplexIDs[complex.id] = {};
                                break;
                            }
                            if (mainDev > 0 && complexComponent.meth < 0 && lookingFor['-']) {
                                complex.show();
                                validation++;
                                this.validComplexIDs[complex.id] = {};
                                break;
                            }
                            if (mainDev > 0 && complexComponent.meth > 0 && lookingFor['+']) {
                                complex.show();
                                validation++;
                                this.validComplexIDs[complex.id] = {};
                                break;
                            }
                            if (mainDev < 0 && complexComponent.meth < 0 && lookingFor['+']) {
                                complex.show();
                                validation++;
                                this.validComplexIDs[complex.id] = {};
                                break;
                            }
                            delete this.validComplexIDs[complex.id];
                            complex.hide();
                        }
                        if (lookingFor['chroma']) {
                            if (mainDev < 0 && complexComponent.chroma > 0 && lookingFor['-']) {
                                complex.show();
                                validation++;
                                this.validComplexIDs[complex.id] = {};
                                break;
                            }
                            if (mainDev > 0 && complexComponent.chroma < 0 && lookingFor['-']) {
                                complex.show();
                                validation++;
                                this.validComplexIDs[complex.id] = {};
                                break;
                            }
                            if (mainDev > 0 && complexComponent.chroma > 0 && lookingFor['+']) {
                                complex.show();
                                validation++;
                                this.validComplexIDs[complex.id] = {};
                                break;
                            }
                            if (mainDev < 0 && complexComponent.chroma < 0 && lookingFor['+']) {
                                complex.show();
                                validation++;
                                this.validComplexIDs[complex.id] = {};
                                break;
                            }
                            delete this.validComplexIDs[complex.id];
                            complex.hide();
                        }
                    }
                }
                if (validation === 0) {
                    //console.log(`Found Nothing in ${pathwayID}!`)
                    delete this.validPathwayIDs[pathwayID];
                    selectorInterface.removeOption('mapselectDynamic',pathwayID);
                }
            }
            //console.log(this.validComplexIDs);
        }
    }
    queryExecByOnt = function(){

        for (let ontQueryId in this.queryByOnt.queryInst) {
            for (let pathwayID in this.validPathwayIDs) {
                let currentPathway = pathwayObjs[pathwayID];
                let mapValidation = false;
                for (let complex of currentPathway.complexes) {
                    let complexValidation = false;
                    if (!this.validComplexIDs[complex.id]) {
                        complex.hide();
                        continue;
                    }
                    if (complex.hasMeta === true) {
                        delete this.validComplexIDs[complex.id];
                        complex.hide();
                        continue;
                    }
                    let idsTmp = {};
                    for (let complexComponent of complex.components) {
                        idsTmp[complexComponent.id] = {};
                    }
                    for (let geneLinked of ont2gene[ontQueryId]) {
                        if (idsTmp[geneLinked]) {
                            complexValidation = true;
                            mapValidation = true;
                        }
                    }
                    if (complexValidation === false) {
                        delete this.validComplexIDs[complex.id];
                        complex.hide();
                    }
                }
                if (mapValidation === false) {
                    delete this.validPathwayIDs[pathwayID];
                    selectorInterface.removeOption('mapselectDynamic',pathwayID);
                }
            }
        }
    }
    addIdToQuery = function(queryObj) {
        this.queryById.queryInst[queryObj.id] = {};
        this.queryById.queryInst[queryObj.id].id = queryObj.id;
        this.queryById.queryInst[queryObj.id].type = queryObj.type;
    }
    addAgreementToQuery = function(queryObj) {
        this.queryByAgreement.queryInst[queryObj.id] = {};
        this.queryByAgreement.queryInst[queryObj.id].first = queryObj.first;
        this.queryByAgreement.queryInst[queryObj.id].second = queryObj.second;
        this.queryByAgreement.queryInst[queryObj.id].type = queryObj.type;
    }
    addOntToQuery = function(queryObj) {
        this.queryByOnt.queryInst[queryObj.id] = {};
        this.queryByOnt.queryInst[queryObj.id].type = queryObj.type;
    }
    removeIdFromQuery = function(id) {
        delete this.queryById.queryInst[id];
    }
    removeAgreementFromQuery = function(id) {
        delete this.queryById.queryInst[id];
    }
    removeOntFromQuery = function(id) {
        delete this.queryByOnt.queryInst[id];
    }
    reset = function() {
        //selectorInterface.restoreDefaultAll();
        //ulInterface.removeAllLis('logistics_ul_pool');
        //ulInterface.removeAllLis('logistics_ul_pool_agreement');
        
        highLightInterface.enableAllMapOptions();
        selectorInterface.restoreDefaultAll();
        highLightInterface.restoreByHLType('red');
        
        let complexes = document.querySelectorAll(".complex");
        for (let complex of complexes) {
            complex.style.display = "block";
            complex.style.border = '0px dotted red';
        }
        this.status = false;
        this.queryById.queryInst = {};
        this.queryByAgreement.queryInst = {};
        this.queryByOnt.queryInst = {};
        document.getElementById('select_type_main').dispatchEvent(changeEvent);

    }
}

var ulInterface = new UlInterface();
var selectorInterface = new SelectorInterface();
var queryInterface = new QueryInterface();
var highLightInterface = new HighLightInterface();
var downloadInterface = new DownloadInterface();