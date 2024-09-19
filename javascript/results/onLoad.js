
function loadPathwayObjs() {
    console.log('loadPathwayObjs()');
    for (let pathwayDiv of document.querySelectorAll(".pathway_div")){
        let pathwayObj = new Pathway(pathwayDiv.id,pathwayDiv.name);
        pathwayObj.loadComplexes();
        pathwayObjs[pathwayDiv.id] = pathwayObj;
    }
}
function loadDefaultSelectors() {
    let selectorIDs = [
        'mapselectDefault', //default mapselect
        'select_type_main', //type to highlight
        'geneHLDefault', //highlight genes
        'protHLDefault', // highlight proteins
        'urnaHLDefault', // highlight miRNAs
        'metaHLDefault', // highlight metabolites
        'tfHLDefault', // highlight TFs
        'ontUlSelect', // onthologies
        'type_for_logical', // type for logical selection
        'select1b', // gene logical selection
        'select6b', // protein logical selection
        'select2b', // miRNA logical selection
        'select3b', // metabolite logical selection
        'methIDSelect',
        'chromaIDSelect',
        'agreement_selector_1', // agreement selection 1
        'agreement_selector_2', // agreement selection 2
        'agreement_selector_3' // agreement selection type
    ];
    for (let selectorID of selectorIDs) {
        if (document.getElementById(selectorID)) {
            selectorInterface.initDefault(selectorID);
            document.getElementById(selectorID).addEventListener("change",function () {
                selectorInterface.updateSelected(selectorID);
            });
        }
    }
}
function loadDynamicSelectors() {
    let dynamicSelectorIDs = [
        'mapselectDynamic', //default mapselect
        'geneHLDynamic', //highlight genes
        'protHLDynamic', // highlight proteins
        'urnaHLDynamic', // highlight miRNAs
        'metaHLDynamic', // highlight metabolites
    ];

    for (let id of dynamicSelectorIDs) {
        let select = document.createElement("select");
        select.id = id;
        select.name = id;
        select.style.display = "none";

        if (id === "mapselectDynamic") {
            select.className = "dynamicSelect";
            select.addEventListener("change",function(){
                changemap(document.getElementById("mapselectDynamic"));
            });
            document.getElementById("mapselectors").appendChild(select);
        } else {
            select.className = "highlightSelector dynamicSelect";
            if (!document.getElementById(select.id)) {
                document.getElementById("idselectors").appendChild(select);
            }
              
        }

        selectorInterface.initDefault(id);
    }
}

function loadEventsOnHLSelectors(type) {
    if (document.getElementById(`${type}HLDefault`)) {
        cloneSelect(document.getElementById(`${type}HLDefault`),document.getElementById(`${type}HLDynamic`));
        //highLightInterface.restoreByHLType('magenta');
        document.getElementById(`${type}HLDefault`).addEventListener("change", function(){
            highLightInterface.restoreByHLType('magenta');
            highLightInterface.highLightById(this.value,type);
        })
        document.getElementById(`${type}HLDynamic`).addEventListener("change", function(){
            highLightInterface.restoreByHLType('magenta');
            highLightInterface.highLightById(this.value,type);
        })
        document.getElementById(`${type}HLDefault`).addEventListener("change",function () {
            selectorInterface.updateSelected(`${type}HLDefault`);
        });
    }
}

document.addEventListener('DOMContentLoaded', function() {

    console.log('Load Pathways Objs');
    loadPathwayObjs();
    console.log('Load Default Selectors');
    loadDefaultSelectors();
    
    //loadDynamicSelectors();
    let select = document.createElement("select");
    select.id = "mapselectDynamic";
    select.name = "mapselectDynamic";
    select.style.display = "none";
    select.className = "dynamicSelect";
    select.addEventListener("change",function(){
        changemap(document.getElementById("mapselectDynamic"));
    });
    document.getElementById("mapselectors").appendChild(select);
    console.log('Cloning map selector');
    cloneSelect(document.getElementById("mapselectDefault"),document.getElementById("mapselectDynamic"));
    selectorInterface.initDefault("mapselectDynamic");
    //spawnMethSelectors();
    //spawnChromaSelectors();
    //spawnTFSelectors();
    console.log('Load HL Selectors for');
    for  (let type of dataTypesTot) {
        console.log(type)
        spawnIDSelector(type);
        loadEventsOnHLSelectors(type);
    }
    
    //Selection By Id
    if (document.getElementById('add_element_to_logic_button')) {
        document.getElementById('add_element_to_logic_button').addEventListener("click", function(){
            let optionType;
            let optionValue;

            if (selectorInterface.selectedValues.type_for_logical.value === "gene") {
                optionValue = selectorInterface.selectedValues.geneIDSelect.value;
                optionType = "gene";
            }
            if (selectorInterface.selectedValues.type_for_logical.value === "meta") {
                optionValue = selectorInterface.selectedValues.metaIDSelect.value;
                optionType = "meta";
            }
            if (selectorInterface.selectedValues.type_for_logical.value === "urna") {
                optionValue = selectorInterface.selectedValues.urnaIDSelect.value;
                optionType = "urna";
            }
            if (selectorInterface.selectedValues.type_for_logical.value === "prot") {
                optionValue = selectorInterface.selectedValues.protIDSelect.value;
                optionType = "prot";
            }
            if (selectorInterface.selectedValues.type_for_logical.value === "meth") {
                optionValue = selectorInterface.selectedValues.methIDSelect.value;
                optionType = "meth";
            }
            if (selectorInterface.selectedValues.type_for_logical.value === "chroma") {
                optionValue = selectorInterface.selectedValues.chromaIDSelect.value;
                optionType = "chroma";
            }
            if (selectorInterface.selectedValues.type_for_logical.value === "tf") {
                optionValue = selectorInterface.selectedValues.tfIDSelect.value;
                optionType = "tf";
            }
            
            ulInterface.addLiFromSelector(optionValue,optionType,"queryUlPool");
        });
    }
    if (document.getElementById('runlogic')) {
        document.getElementById('runlogic').addEventListener("click", function(){
            queryInterface.queryExec();
        });
    }
    if (document.getElementById('resetlogic')) {
        document.getElementById('resetlogic').addEventListener("click", function(){
            queryInterface.reset();
            ulInterface.resetLis();
        });
    }

    if (document.getElementById('ontUlAddButton')) {
        document.getElementById('ontUlAddButton').addEventListener("click", function(){
            let optionType;
            let optionValue;

            if (selectorInterface.selectedValues.ontUlSelect.value === "none") {
                return;
            } else {
                optionValue = selectorInterface.selectedValues.ontUlSelect.value;
                optionType = "ontology";
            }
            
            ulInterface.addLiFromSelector(optionValue,optionType,"queryUlPool");
        });
    }
    if (document.getElementById('select_type_main')) {
        if (enable_meth === 1) {
            let opt = document.createElement("option");
            opt.value = "meth";
            opt.text = "Methylations";
            document.getElementById('select_type_main').add(opt);
        }
        if (enable_chroma === 1) {
            let opt = document.createElement("option");
            opt.value = "chroma";
            opt.text = "Chromatin";
            document.getElementById('select_type_main').add(opt);
        }
        document.getElementById('select_type_main').addEventListener("change", function(){
            let typeSelected = document.getElementById('select_type_main').value;
            let types = [
                "gene",
                "prot",
                "meta",
                "urna",
                "tf",
                "meth",
                "chroma"
            ];
            for (let type of types) {
                if (document.getElementById(`${type}HLDefault`)) {
                    document.getElementById(`${type}HLDefault`).style.display = "none";
                }
                if (document.getElementById(`${type}HLDynamic`)) {
                    document.getElementById(`${type}HLDynamic`).style.display = "none";
                }
            }
            if (queryInterface.status === true) {
                document.getElementById(`${typeSelected}HLDynamic`).style.display = "block";
            } else {
                document.getElementById(`${typeSelected}HLDefault`).style.display = "block";
            }
        });
    }
    if (document.getElementById('type_for_logical')) {
        if (enable_meth === 1) {
            let opt = document.createElement("option");
            opt.value = "meth";
            opt.text = "Methylation";
            document.getElementById('type_for_logical').add(opt);
        }
        if (enable_chroma === 1) {
            let opt = document.createElement("option");
            opt.value = "chroma";
            opt.text = "Chromatin";
            document.getElementById('type_for_logical').add(opt);
        }
        if (enable_tfs === 1) {
            let opt = document.createElement("option");
            opt.value = "tf";
            opt.text = "TFs";
            document.getElementById('type_for_logical').add(opt);
        }
        logic_list_handler("none");
    }
    if (document.getElementById('select_maps_from_icon_button')) {

        const clonedReset = document.getElementById('resetlogic').cloneNode(true);
        clonedReset.title = "Restore Map Selector and Reset Queries";
        document.getElementById('select_maps_from_icon_button').parentElement.appendChild(clonedReset);
        clonedReset.addEventListener("click", function(){
            queryInterface.reset();
            ulInterface.resetLis();
        });

        document.getElementById('select_maps_from_icon_button').addEventListener("click", function() {

            if (document.getElementById(active_complex_id).parentElement.className === "complex_pool_map_div") {
                queryInterface.reset();
                highLightInterface.enableAllMapOptions();
                let tmpObj = new Complex (active_complex_id,document.getElementById(active_complex_id).parentElement.id)
                tmpObj.loadContent2();
                let tmpQueryObj = new queryObj ("id",tmpObj.components[0].id,tmpObj.components[0].type);
                queryInterface.addIdToQuery(tmpQueryObj);
                queryInterface.queryExec();
            }
            
        });
    }

    if (document.getElementById('download_info_button')) {
        document.getElementById('download_info_button').addEventListener("click", function(){
            
            downloadFromPool();
        });
    }

    document.getElementById('select_type_main').dispatchEvent(changeEvent);




},false);
