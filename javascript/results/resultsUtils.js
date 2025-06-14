function toggleOverDiv(targetId) {
	
	var containerDiv = document.getElementById('container3');
	var targetDivId = document.getElementById(targetId);

	if (targetDivId.style.display == "flex") {
		containerDiv.style.display = "none";
		targetDivId.style.display = "none";
		return;
	}

	var overDivSections = document.getElementsByClassName("overDivSection");
	for (overDivSection of overDivSections) {
		overDivSection.style.display = "none";
	}
	containerDiv.style.display = "flex";
	targetDivId.style.display = "flex";
	return;
}

function changemap(selector) {
	//var all = document.getElementsByTagName("div")
	var all = document.getElementsByClassName("pathway_div")
	for(var i = 0; i < all.length; i++) {
//		if (all[i].style.visibility == "visible") {
		if (all[i].style.display == "block") {
		//	all[i].style.visibility="hidden";
			all[i].style.display="none";
			var child1 = document.getElementById(all[i].id).children;
			for(var k = 0; k < child1.length; k++) {
		//		child1[k].style.visibility="hidden";
				child1[k].style.display="none";
			}
		}
	}
    //console.log(selector.value);
	var sel = document.getElementById(selector.value);
	//console.log(sel);
//	sel.style.visibility="visible"
	sel.style.display="block"
    imgToDrag = sel.children[0];
	var child2 = document.getElementById(selector.value).children
	for(var j = 0; j < child2.length; j++) {
//		child2[j].style.visibility="visible"
		child2[j].style.display="block"
	}
}

async function change(action,dir) {
    let indicators = document.querySelectorAll(".complex");
    for(let indicator of indicators) {
        var selected = false;
        var highlighted = false;
        if (indicator.style.border === "3px dotted blue") {
            indicator.style.border = "";
            selected = true;
        }
        if (indicator.style.border === "3px dotted magenta") {
            indicator.style.border = "";
            highlighted = true;
        }
        

        if (action == "trasp") {
            op = parseFloat(indicator.style.opacity)
            if (dir == "u") {
                op -= 0.1
            }
            if (dir == "d") {
                op += 0.1
            }
            indicator.style.opacity = op
        }
        if (action == "size") {
            if (dir == "u") {
                indicator.width += 5
                indicator.height += 5
                indicator.style.top = parseFloat(indicator.style.top)-2.5+"px"
                indicator.style.left = parseFloat(indicator.style.left)-2.5+"px"
            }
            if (dir == "d") {
                indicator.width -= 5
                indicator.height -= 5
                indicator.style.top = parseFloat(indicator.style.top)+2.5+"px"
                indicator.style.left = parseFloat(indicator.style.left)+2.5+"px"
            }
        }
        if (selected === true) {
            indicator.style.border = "3px dotted blue";
        }
        if (highlighted === true) {
            indicator.style.border = "3px dotted magenta";
        }
        
    }
}

function sortOptionsByValue (arrayOfOptions){

    let sortedOptions = arrayOfOptions.sort(function(a, b) {
        var nameA = a.innerText.toUpperCase(); // ignore upper and lowercase
        var nameB = b.innerText.toUpperCase(); // ignore upper and lowercase
        if (nameA < nameB) {
          return -1; //nameA comes first
        }
        if (nameA > nameB) {
          return 1; // nameB comes first
        }
        return 0;  // names must be equal
    });
    return(sortedOptions);
}

function addGlobalEventListener(type, selector, callback, options) {
    document.addEventListener(type, e => {
      if (e.target.closest(selector)) callback(e)
    }, options)
}

function showSecondParty(first_party) {

    // each function call wll firstly reset the logistics_div_selectors div
    if (document.getElementById('agreement_selector2')) {
        document.getElementById('logistics_div_agreement_selectors').removeChild(document.getElementById('agreement_selector2'));
    }
    if (document.getElementById('agreement_selector3')) {
        document.getElementById('logistics_div_agreement_selectors').removeChild(document.getElementById('agreement_selector3'));
    }
    if (document.getElementById('agreement_add_button')) {
        document.getElementById('logistics_div_agreement_selectors').removeChild(document.getElementById('agreement_add_button'));
    }
    if (document.getElementById('agreement_select_button')) {
        document.getElementById('logistics_div_agreement_selectors').removeChild(document.getElementById('agreement_select_button'));
    }
    if (document.getElementById('agreement_reset_button')) {
        document.getElementById('logistics_div_agreement_selectors').removeChild(document.getElementById('agreement_reset_button'));
    }


    var second_party_select = document.createElement("select");
    second_party_select.setAttribute("id","agreement_selector2");
    second_party_select.setAttribute("onchange","showAgreementType(this.selectedOptions[0].value)");
    second_party_select.setAttribute("title","Select Second Party");
    second_party_select.setAttribute("class","agreementSelector");
    //second_party_select.style = "margin-left:10px;";

    if (first_party === "none") {
        return;
    }

    const options_to_load = [];
    var option = document.createElement("option");
    option.value = "none";
    option.text = "";
    options_to_load.push(option);

    if (first_party === "gene") {

        //check if gene and proteins are enabled in this analysis
        if (enable_prot === 1) {
            var option = document.createElement("option");
            option.value = "prot";
            option.text = "Protein";
            options_to_load.push(option);
        }
        //check if urna are enabled in this analysis
        if (enable_urna === 1) {
            var option = document.createElement("option");
            option.value = "urna";
            option.text = "miRNA";
            options_to_load.push(option);
        }
        //check if meth are enabled in this analysis
        if (enable_meth === 1) {
            var option = document.createElement("option");
            option.value = "meth";
            option.text = "Methylation";
            options_to_load.push(option);
        }
        //check if tfs are enabled in this analysis
        if (enable_tfs === 1) {
            var option = document.createElement("option");
            option.value = "tf";
            option.text = "TF";
            options_to_load.push(option);
        }
        if (enable_chroma === 1) {
            var option = document.createElement("option");
            option.value = "chroma";
            option.text = "Chromatin";
            options_to_load.push(option);
        }
    }
    if (first_party === "prot") {
        //check if gene and proteins are enabled in this analysis
        if (enable_gene === 1) {
            var option = document.createElement("option");
            option.value = "gene";
            option.text = "Gene";
            options_to_load.push(option);
        }
        //check if urna are enabled in this analysis
        if (enable_urna === 1) {
            var option = document.createElement("option");
            option.value = "urna";
            option.text = "miRNA";
            options_to_load.push(option);
        }
        //check if meth are enabled in this analysis
        if (enable_meth === 1) {
            var option = document.createElement("option");
            option.value = "meth";
            option.text = "Methylation";
            options_to_load.push(option);
        }
        //check if tfs are enabled in this analysis
        if (enable_tfs === 1) {
            var option = document.createElement("option");
            option.value = "tf";
            option.text = "TF";
            options_to_load.push(option);
        }
        if (enable_chroma === 1) {
            var option = document.createElement("option");
            option.value = "chroma";
            option.text = "Chromatin";
            options_to_load.push(option);
        }
    }

    //fill second party selector with gene options
    for (let i = 0; i < options_to_load.length; i++) {
        second_party_select.add(options_to_load[i]);
    }
    //append second party selector to logistics_div_agreement_selectors div
    document.getElementById('logistics_div_agreement_selectors').appendChild(second_party_select);
    document.getElementById('agreement_selector2').selectedIndex = 0;
    selectorInterface.updateSelected("agreement_selector1");
    return;
}

function showAgreementType() {

    //console.log(second_party);

    if (document.getElementById('agreement_selector3')) {
        document.getElementById('logistics_div_agreement_selectors').removeChild(document.getElementById('agreement_selector3'));
    }
    if (document.getElementById('agreement_add_button')) {
        document.getElementById('logistics_div_agreement_selectors').removeChild(document.getElementById('agreement_add_button'));
    }
    if (document.getElementById('agreement_select_button')) {
        document.getElementById('logistics_div_agreement_selectors').removeChild(document.getElementById('agreement_select_button'));
    }
    if (document.getElementById('agreement_reset_button')) {
        document.getElementById('logistics_div_agreement_selectors').removeChild(document.getElementById('agreement_reset_button'));
    }

    var agreement_select = document.createElement("select");
    agreement_select.setAttribute("id","agreement_selector3");
    agreement_select.setAttribute("onchange","showAgreementButtons(this.selectedOptions[0].value)");
    agreement_select.setAttribute("title","Select Agreement Type");
    agreement_select.setAttribute("class","agreementSelector");
    //agreement_select.style = "margin-left:10px;";

    var option1 = document.createElement("option");
    option1.value = "none";
    option1.text = "";
    agreement_select.add(option1);

    var option2 = document.createElement("option");
    option2.value = "+";
    option2.text = "Positive";
    agreement_select.add(option2);

    var option3 = document.createElement("option");
    option3.value = "-";
    option3.text = "Negative";
    agreement_select.add(option3);

    document.getElementById('logistics_div_agreement_selectors').appendChild(agreement_select);
    document.getElementById('agreement_selector3').selectedIndex = 0;
    selectorInterface.updateSelected("agreement_selector2");

}

function showAgreementButtons() {

    if (document.getElementById('agreement_add_button')) {
        document.getElementById('logistics_div_agreement_selectors').removeChild(document.getElementById('agreement_add_button'));
    }
    if (document.getElementById('agreement_select_button')) {
        document.getElementById('logistics_div_agreement_selectors').removeChild(document.getElementById('agreement_select_button'));
    }
    if (document.getElementById('agreement_reset_button')) {
        document.getElementById('logistics_div_agreement_selectors').removeChild(document.getElementById('agreement_reset_button'));
    }

    var first_party = document.getElementById('agreement_selector1').selectedOptions[0].value;
    var second_party = document.getElementById('agreement_selector2').selectedOptions[0].value;
    var agreement_type = document.getElementById('agreement_selector3').selectedOptions[0].value;

    if (first_party !== "none" && second_party !== "none" && agreement_type !== "none") {
        //create an add button for the agreement selectors that can fill the pool
        var agreement_add_button = document.createElement("input");
        agreement_add_button.setAttribute("id","agreement_add_button");
        agreement_add_button.setAttribute("type","button");
        
        agreement_add_button.setAttribute("value","Add");
        agreement_add_button.setAttribute("title","Add Agreement to Pool");
        agreement_add_button.setAttribute("class","agreementButton");
        document.getElementById('logistics_div_agreement_selectors').appendChild(agreement_add_button);

        selectorInterface.updateSelected("agreement_selector3");
        agreement_add_button.addEventListener("click",function () {
            let optionValue = `${selectorInterface.selectedValues.agreement_selector1.value}|${selectorInterface.selectedValues.agreement_selector2.value}|${selectorInterface.selectedValues.agreement_selector3.value}`; 
            let optionType = "agreement";
    
            ulInterface.addLiFromSelector(optionValue,optionType,"queryUlPool");
        },false);
        return;
    }
    selectorInterface.updateSelected("agreement_selector3");
    
}

function cloneSelect(selectorToClone, secondSelector) {

    selectorInterface.emptySelector(secondSelector.id);

    for (let option of selectorToClone.options) {
        const clonedOption = option.cloneNode(true);
        secondSelector.appendChild(clonedOption);
    }

}

function downloadFromPool() {
    console.log("downloadFromPool()");
    var pool = document.getElementById("complex_pool_div");
    var field = document.getElementById("info_to_download");
    field.textContent = "ID\tTYPE\tSYMBOL\tEffect Size\tMethylation\tChromatin\tGene/miRNA Link\tGene/TF Link\tPathways\n";

    let miniComplexes = document.querySelectorAll('.minicomplex');
    for (let miniComplex of miniComplexes) {
        let complexObj = new Complex({id:miniComplex.id,parent:miniComplex.parentElement.id});
        console.log(complexObj.id);
        complexObj.loadContent2();
        complexObj.contentToTSV();
    }

    for (let mainID in downloadInterface.id2name) {
        field.textContent += `${mainID}\t${this.downloadInterface.id2type[mainID]}\t`;

        if (this.downloadInterface.id2name[mainID]) {
            for (let name in this.downloadInterface.id2name[mainID]) {
                field.textContent += `${name};`;
            }
            
        }
        

        if (this.downloadInterface.id2dev[mainID]) {
            field.textContent += `\t${this.downloadInterface.id2dev[mainID]}`;
        } else {
            field.textContent += `\tNA`;
        }

        if (this.downloadInterface.meth2dev[mainID]) {
            field.textContent += `\t${this.downloadInterface.meth2dev[mainID]}`;
        } else {
            field.textContent += `\tNA`;
        }

        if (this.downloadInterface.chroma2dev[mainID]) {
            field.textContent += `\t${this.downloadInterface.chroma2dev[mainID]}`;
        } else {
            field.textContent += `\tNA`;
        }

        
        if (this.downloadInterface.gene2urna[mainID] || this.downloadInterface.urna2gene[mainID]) {
            if (this.downloadInterface.urna2gene[mainID]) {
                field.textContent += `\t`;
                for (let geneID in this.downloadInterface.urna2gene[mainID]) {
                    field.textContent += `${geneID};`;
                }
            }
            if (this.downloadInterface.gene2urna[mainID]) {
                field.textContent += `\t`;
                for (let urnaID in this.downloadInterface.gene2urna[mainID]) {
                    field.textContent += `${urnaID};`;
                }
            }
        } else if (this.downloadInterface.prot2urna[mainID] || this.downloadInterface.urna2prot[mainID]) {
            if (this.downloadInterface.prot2urna[mainID]) {
                field.textContent += `\t`;
                for (let urnaID in this.downloadInterface.prot2urna[mainID]) {
                    field.textContent += `${urnaID};`;
                }
            }
            if (this.downloadInterface.urna2prot[mainID]) {
                field.textContent += `\t`;
                for (let protID in this.downloadInterface.urna2prot[mainID]) {
                    field.textContent += `${protID};`;
                }
            }
        } else {
            field.textContent += `\tNA`;
        }

        if (this.downloadInterface.gene2tf[mainID] || this.downloadInterface.tf2gene[mainID]) {
            if (this.downloadInterface.gene2tf[mainID]) {
                field.textContent += `\t`;
                for (let tfID in this.downloadInterface.gene2tf[mainID]) {
                    field.textContent += `${tfID};`;
                }
            }
            if (this.downloadInterface.tf2gene[mainID]) {
                field.textContent += `\t`;
                for (let geneID in this.downloadInterface.tf2gene[mainID]) {
                    field.textContent += `${geneID};`;
                }
            }
            
        } else if (this.downloadInterface.prot2tf[mainID] || this.downloadInterface.tf2prot[mainID]) {
            if (this.downloadInterface.prot2tf[mainID]) {
                field.textContent += `\t`;
                for (let tfID in this.downloadInterface.prot2tf[mainID]) {
                    field.textContent += `${tfID};`;
                }
            }
            if (this.downloadInterface.tf2prot[mainID]) {
                field.textContent += `\t`;
                for (let protID in this.downloadInterface.tf2prot[mainID]) {
                    field.textContent += `${protID};`;
                }
            }
        } else {
            field.textContent += `\tNA`;
        }
        if (this.downloadInterface.id2map[mainID]) {
            field.textContent += `\t`;
            for (let mapID in this.downloadInterface.id2map[mainID]) {
                field.textContent += `${mapID};`;
            }
        } else {
            field.textContent += `\tNA`;
        }
        field.textContent += `\n`;
    }
    submitFormForPool();
}

function spawnMethSelectors(){
    console.log("spawnMeth")
    let selectHLDefault = document.createElement("select");
    let optionsArray = [];
    for (let methID in meth2name) {
        console.log(methID)
        let opt = document.createElement("option");
        //let optID = document.createElement("option");
        opt.value = methID;
        opt.text  = `${meth2name[methID]} (${methID})`;
        optionsArray.push(opt);
    }
    let optionsSorted = sortOptionsByValue(optionsArray);
    for (let opt of optionsSorted) {
        selectHLDefault.add(opt);
    }
    let firstOpt = document.createElement("option");
    firstOpt.value = "all";
    firstOpt.text = "Methylations";

    selectHLDefault.add(firstOpt,0);
    let selectHLDynamic = selectHLDefault.cloneNode(true);
    let selectID = selectHLDefault.cloneNode(true);
    selectID.id = "methIDSelect";
    selectHLDefault.id = "methHLDefault";
    selectHLDynamic.id = "methHLDynamic";

    selectID.className = "logistics_selector";
    selectHLDefault.className = "higlightSelector defaultSelect";
    selectHLDynamic.className = "highlightSelector dynamicSelect";

    selectID.selectedIndex = 0;
    selectHLDefault.selectedIndex = 0;
    selectHLDynamic.selectedIndex = 0;

    document.getElementById("idselectors").appendChild(selectHLDefault);
    document.getElementById("idselectors").appendChild(selectHLDynamic);
    document.getElementById("logistics_div_selectors").appendChild(selectID);

    selectorInterface.initDefault("methIDSelect");
    selectorInterface.initDefault("methHLDefault");
    selectorInterface.initDefault("methHLDynamic");

    document.getElementById("methIDSelect").addEventListener("change",function () {
        selectorInterface.updateSelected("methIDSelect");
    });
    document.getElementById("methHLDefault").addEventListener("change",function () {
        selectorInterface.updateSelected("methHLDefault");
    });
    document.getElementById("methHLDynamic").addEventListener("change",function () {
        selectorInterface.updateSelected("methHLDynamic");
    });
}
function spawnChromaSelectors(){
    let selectHLDefault = document.createElement("select");
    //let select = document.createElement("select");
    let optionsArray = [];
    for (let chromaID in chroma2name) {
        let opt = document.createElement("option");
        //let optID = document.createElement("option");
        opt.value = chromaID;
        opt.text  = `${chroma2name[chromaID]} (${chromaID})`;
        optionsArray.push(opt);
    }
    let optionsSorted = sortOptionsByValue(optionsArray);
    //selectHLDefault.options = optionsSorted;
    for (let opt of optionsSorted) {
        selectHLDefault.add(opt);
    }
    let firstOpt = document.createElement("option");
    firstOpt.value = "all";
    firstOpt.text = "Chromatin";

    selectHLDefault.add(firstOpt,0);
    let selectHLDynamic = selectHLDefault.cloneNode(true);
    let selectID = selectHLDefault.cloneNode(true);
    selectID.id = "chromaIDSelect";
    selectHLDefault.id = "chromaHLDefault";
    selectHLDynamic.id = "chromaHLDynamic";

    selectID.className = "logistics_selector";
    selectHLDefault.className = "higlightSelector defaultSelect";
    selectHLDynamic.className = "highlightSelector dynamicSelect";

    selectID.selectedIndex = 0;
    selectHLDefault.selectedIndex = 0;
    selectHLDynamic.selectedIndex = 0;

    document.getElementById("idselectors").appendChild(selectHLDefault);
    document.getElementById("idselectors").appendChild(selectHLDynamic);
    document.getElementById("logistics_div_selectors").appendChild(selectID);
    selectorInterface.initDefault("chromaIDSelect");
    selectorInterface.initDefault("chromaHLDefault");
    selectorInterface.initDefault("chromaHLDynamic");

    document.getElementById("chromaIDSelect").addEventListener("change",function () {
        selectorInterface.updateSelected("chromaIDSelect");
    });
    document.getElementById("chromaHLDefault").addEventListener("change",function () {
        selectorInterface.updateSelected("chromaHLDefault");
    });
    document.getElementById("chromaHLDynamic").addEventListener("change",function () {
        selectorInterface.updateSelected("chromaHLDynamic");
    });
}
function spawnTFSelectors(){
    let selectHLDefault;
    if (!document.getElementById("tfHLDefault")) {
        selectHLDefault = document.createElement("select");
    } else {
        selectHLDefault = document.getElementById("tfHLDefault");
    }
    
    //let select = document.createElement("select");
    let optionsArray = [];
    for (let tfID in tf2name) {
        let opt = document.createElement("option");
        //let optID = document.createElement("option");
        opt.value = tfID;
        opt.text  = `${tf2name[tfID]} (${tfID})`;
        optionsArray.push(opt);
    }
    let optionsSorted = sortOptionsByValue(optionsArray);
    //selectHLDefault.options = optionsSorted;
    for (let opt of optionsSorted) {
        selectHLDefault.add(opt);
    }
    let firstOpt = document.createElement("option");
    firstOpt.value = "all";
    firstOpt.text = "TFs";

    selectHLDefault.add(firstOpt,0);
    let selectHLDynamic = selectHLDefault.cloneNode(true);
    let selectID = selectHLDefault.cloneNode(true);
    selectID.id = "tfIDSelect";
    selectHLDefault.id = "tfHLDefault";
    selectHLDynamic.id = "tfHLDynamic";

    selectID.className = "logistics_selector";
    selectHLDefault.className = "higlightSelector defaultSelect";
    selectHLDynamic.className = "highlightSelector dynamicSelect";

    selectID.selectedIndex = 0;
    selectHLDefault.selectedIndex = 0;
    selectHLDynamic.selectedIndex = 0;

    if (!document.getElementById(selectHLDefault.id)) {
        document.getElementById("idselectors").appendChild(selectHLDefault);
    }
    if (!document.getElementById(selectHLDynamic.id)) {
        document.getElementById("idselectors").appendChild(selectHLDynamic);
    }
    document.getElementById("logistics_div_selectors").appendChild(selectID);

    selectorInterface.initDefault("tfIDSelect");
    selectorInterface.initDefault("tfHLDefault");
    selectorInterface.initDefault("tfHLDynamic");

    document.getElementById("tfIDSelect").addEventListener("change",function () {
        selectorInterface.updateSelected("tfIDSelect");
    });
    document.getElementById("tfHLDefault").addEventListener("change",function () {
        selectorInterface.updateSelected("tfHLDefault");
    });
    document.getElementById("tfHLDynamic").addEventListener("change",function () {
        selectorInterface.updateSelected("tfHLDynamic");
    });
}

function spawnIDSelector(type) {
    let selectHLDefault = document.createElement("select");
    selectHLDefault.title = `Select ${referenceTable[type].aliasForIDSelector} to Higlight (Select \"${referenceTable[type].aliasForIDSelector}\" to Reset)`;
    let optionsArray = [];
    for (let id in referenceTable[type].ids) {
        let opt = document.createElement("option");
        opt.value = id;
        if (type === "meth" || type === "chroma") {
            opt.text  = `${referenceTable[type].ids[id].name} (${id})`;
        } else if (type === "urna") {
            opt.text  = `${id}`;
        } else {
            opt.text  = `${referenceTable[type].ids[id].name} (${id})`;
        }
        optionsArray.push(opt);
    }
    let optionsSorted = sortOptionsByValue(optionsArray);
    for (let opt of optionsSorted) {
        selectHLDefault.add(opt);
    }
    let firstOpt = document.createElement("option");
    firstOpt.value = "all";
    firstOpt.text = referenceTable[type].aliasForIDSelector;

    selectHLDefault.add(firstOpt,0);
    let selectHLDynamic = selectHLDefault.cloneNode(true);
    let selectID = selectHLDefault.cloneNode(true);
    selectID.id = `${type}IDSelect`;
    selectHLDefault.id = `${type}HLDefault`;
    selectHLDynamic.id = `${type}HLDynamic`;

    selectID.className = "logistics_selector";
    selectHLDefault.className = "higlightSelector defaultSelect";
    selectHLDynamic.className = "highlightSelector dynamicSelect";

    selectID.selectedIndex = 0;
    selectHLDefault.selectedIndex = 0;
    selectHLDynamic.selectedIndex = 0;

    document.getElementById("idselectors").appendChild(selectHLDefault);
    document.getElementById("idselectors").appendChild(selectHLDynamic);
    document.getElementById("logistics_div_selectors").appendChild(selectID);

    selectorInterface.initDefault(`${type}IDSelect`);
    selectorInterface.initDefault(`${type}HLDefault`);
    selectorInterface.initDefault(`${type}HLDynamic`);

    document.getElementById(`${type}IDSelect`).addEventListener("change",function () {
        selectorInterface.updateSelected(`${type}IDSelect`);
    });
    document.getElementById(`${type}HLDefault`).addEventListener("change",function () {
        selectorInterface.updateSelected(`${type}HLDefault`);
    });
    document.getElementById(`${type}HLDynamic`).addEventListener("change",function () {
        selectorInterface.updateSelected(`${type}HLDynamic`);
    });
}

function logic_list_handler(type) {


    console.log("logic_list_handler - start");
    const selectors_available = [];

    //active_logical_selected_element = {id:undefined,name:undefined,type:undefined};

    ["gene","meta","prot","urna","meth","chroma","tf"].forEach((t) => {
        if (document.getElementById(`${t}IDSelect`)) {
            selectors_available.push(document.getElementById(`${t}IDSelect`));
        }
    })


    for (let i = 0; i < selectors_available.length; i++) {
        selectors_available[i].selectedIndex = 0;
        selectors_available[i].style.display = 'none';
    }
    if (document.getElementById(`${type}IDSelect`)) {
        document.getElementById(`${type}IDSelect`).style.display = 'flex';
        document.getElementById(`${type}IDSelect`).after(document.getElementById("add_element_to_logic_button"))
    }
    
    
    
    console.log("logic_list_handler - stop");
}



