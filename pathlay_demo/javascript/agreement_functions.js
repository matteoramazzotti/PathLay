//interface logic_handler
var active_agreements = {};
var agreement_pool_content = {content:0};


function showSecondParty(first_party) {

    console.log(first_party);
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
    }

    //fill second party selector with gene options
    for (let i = 0; i < options_to_load.length; i++) {
        second_party_select.add(options_to_load[i]);
    }
    //append second party selector to logistics_div_agreement_selectors div
    document.getElementById('logistics_div_agreement_selectors').appendChild(second_party_select);
    document.getElementById('agreement_selector2').selectedIndex = 0;
    return;
}


function showAgreementType(second_party) {

    console.log(second_party);

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

}


function showAgreementButtons(agreement_type) {

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

    if (first_party !== "none" && second_party !== "none" && agreement_type !== "none") {
        //create an add button for the agreement selectors that can fill the pool
        var agreement_add_button = document.createElement("input");
        agreement_add_button.setAttribute("id","agreement_add_button");
        agreement_add_button.setAttribute("type","button");
        agreement_add_button.setAttribute(
            "onclick",
            "addAgreementToPool(document.getElementById('agreement_selector1').selectedOptions[0].value,document.getElementById('agreement_selector2').selectedOptions[0].value,document.getElementById('agreement_selector3').selectedOptions[0].value)"
        );
        agreement_add_button.setAttribute("value","Add");
        agreement_add_button.setAttribute("title","Add Agreement to Pool");
        agreement_add_button.setAttribute("class","agreementButton");
        //agreement_add_button.style = "margin-left:10px;";
        document.getElementById('logistics_div_agreement_selectors').appendChild(agreement_add_button);

        //create a select button that can hide indicators using agreements from the agreement in the pool
        var agreement_select_button = document.createElement("input");
        agreement_select_button.setAttribute("id","agreement_select_button");
        agreement_select_button.setAttribute("type","button");
        agreement_select_button.setAttribute("onclick",'pathfilterAgreements(document.getElementById("logistics_ul_pool_agreement").childNodes,"run")');
        agreement_select_button.setAttribute("value","Select");
        agreement_select_button.setAttribute("title","Select by Agreement");
        agreement_select_button.setAttribute("class","agreementButton");
        //agreement_select_button.style = "margin-left:10px;";
        document.getElementById('logistics_div_agreement_selectors').appendChild(agreement_select_button);

        var agreement_reset_button = document.createElement("input");
        agreement_reset_button.setAttribute("id","agreement_reset_button");
        agreement_reset_button.setAttribute("type","button");
        agreement_reset_button.setAttribute("onclick",'pathfilterAgreements(document.getElementById("logistics_ul_pool_agreement").childNodes,"reset")');
        agreement_reset_button.setAttribute("value","Reset");
        agreement_reset_button.setAttribute("title","Reset Agreements Processed");
        agreement_reset_button.setAttribute("class","agreementButton");
        //agreement_reset_button.style = "margin-left:10px;";
        document.getElementById('logistics_div_agreement_selectors').appendChild(agreement_reset_button);
        return;
    }
}

function addAgreementToPool(first_party,second_party,agreement_type) {
    console.log(`Going to add ${first_party},${second_party},${agreement_type}`);

    var target = "";
    var title = "";

    if (second_party === "prot" || second_party === "gene" || second_party === "tf") {
        // Positive -> logFCs must be of the same sign
        // Negative -> logFCs must be of different sign
        if (agreement_type === "+") {
            target = `${first_party}|${second_party}|+`;
            title = `Target: ${first_party} - ${second_party}\nCorrelation: Positive\n`;
        }
        if (agreement_type === "-") {
            target = `${first_party}|${second_party}|-`;
            title = `Target: ${first_party} - ${second_party}\nCorrelation: Negative\n`;
        }
    }

    if (second_party === "meth" || second_party === "urna") {
        // Positive -> logFCs must be of different sign
        // Negative -> logFCs must be of the same sign
        if (agreement_type === "+") {
            target = `${first_party}|${second_party}|-`;
            title = `Target: ${first_party} - ${second_party}\nCorrelation: Negative\n`;
        }
        if (agreement_type === "-") {
            target = `${first_party}|${second_party}|+`;
            title = `Target: ${first_party} - ${second_party}\nCorrelation: Positive\n`;
        }
    }

    console.log("addAgreementToPool - start");

    if (agreement_pool_content[target + "_li"] === 1) {
        console.log("element already in pool: abort");
        return
    }
    //logical_pool_content.push(element);

    console.log("creating li");
    var ul = document.getElementById('logistics_ul_pool_agreement');
    var li = document.createElement('li');
    li.id = target + "_li";
    li.className = "logistics_pool_li";
//    li.innerHTML = element.id + " (" + element.name + ") " + '<input id="" class="ul_rm_button" name="" type="button" value="X" title="" style="margin-left:25px;width:20px;height:20px;font-size:10px;"/>'
    li.innerHTML = title + '<input id="" class="ul_rm_button" name="" type="button" value="X" title="" style="margin-left:25px;width:20px;height:20px;font-size:8px;" onClick="removeAgreementFromPool(this.parentElement)"/>'
    //li.style.backgroundColor = '#e6faff';
    //<li id="GO:0000120" class="ont_li" style="">RNA polymerase I transcription regulator complex (<a target="_blank" style="text-decoration:none;" href="http://amigo.geneontology.org/amigo/term/GO:0000120">GO!</a>)<input type='hidden' name='onts' value='GO:0000120@'/><input id="" class="ul_add_button" name="" type="button" value="+" title="" style="margin-left:25px;width:20px;height:20px;font-size:10px;"/></li>
    //if (element.type === "gene") {
    //    li.style.backgroundColor = '#e6faff';
    //}
    //if (element.type === "urna") {
    //    li.style.backgroundColor = '#ffb3b3';
    //}
    //if (element.type === "meta") {
    //    li.style.backgroundColor = '#ffffb3';
    //}
    ul.appendChild(li);
    agreement_pool_content[target + "_li"] = 1;
    agreement_pool_content["content"]++;
    console.log(li);
    console.log("addAgreementToPool - stop");
}

function removeAgreementFromPool(agreement_li) {
    console.log(agreement_li);
    //const li_regex = new RegExp(/(.+?)_li$/);
    //const id = li_regex.exec(li.id)[1];
    console.log(agreement_li.id);
    //logical_pool_content[id + "_li"] = 0;
    agreement_pool_content[agreement_li.id] = 0;
    agreement_pool_content["content"]--;
    console.log(agreement_pool_content[agreement_li.id]);
    agreement_li.parentElement.removeChild(agreement_li);
    return;
}

function pathfilterAgreements(pool_content,task) {

    var complexes = {};
    var maps_to_hide = {};

    if (task === "run") {

        var complexes = document.querySelectorAll(".complex");
        for (let i = 0; i < complexes.length; i++) {
            complexes[i].style.display = "block";
            //console.log(complexes[i].id);
        }
        if (document.getElementById("pruned_select")) {
            document.getElementById("pruned_select").parentNode.removeChild(document.getElementById("pruned_select"));
        }
        document.getElementById('mapselect').style.display = "block";

        var active_map_ids = {};
        var agreements = [];

        const mode_regex = new RegExp(/mode:(.+?)$/);
        const li_remover_regex = new RegExp(/(.+?)_li$/);

        // check active maps to stack up selections
        if (document.getElementById('pruned_select')) {
            for (let i = 0; i < document.getElementById('pruned_select').options.length;i++) {
                //console.log(document.getElementById('pruned_select').options[i].value);
                active_map_ids[document.getElementById('pruned_select').options[i].value] = 1;
            }
        } else {
            for (let i = 0; i < document.getElementById('mapselect').options.length;i++) {
                //console.log(document.getElementById('mapselect').options[i].value);
                active_map_ids[document.getElementById('mapselect').options[i].value] = 1;
            }
        }
        // check agreements received as input
        for (let i = 0;i < pool_content.length;i++) {
            //console.log("Agreement received: " + pool_content[i].id);
            agreements.push(li_remover_regex.exec(pool_content[i].id)[1]);
            //console.log("Agreement to process: " + agreement);
        }
        //console.log(agreements.length);
            for (const map_id in active_map_ids) {
                console.log(map_id);
                complexes[map_id] = {};
                //console.log(complexes[map_id]);
                var map_to_check_div = document.getElementById(map_id+"_complexes");
                //console.log(map_to_check_div);
                for (let c = 0; c < map_to_check_div.childNodes.length;c++) {
                    var lines = [];
                    if (map_to_check_div.childNodes[c].className === "complex animate-right") {
                        //console.log(map_to_check_div.childNodes[c].id);
                        complexes[map_id][map_to_check_div.childNodes[c].id] = {};
                        //console.log(map_to_check_div.childNodes[c].id);
                        let complex_src = map_to_check_div.childNodes[c].src;
                        lines = complex_src.split("%0A");
                        let mode;
                        if (mode_regex.test(lines[2]) === true) {
                            mode = mode_regex.exec(lines[2])[1];
                        }
                        if (mode === "id_only") {
                            alert("You have selected ID Only Mode, cannot Select by Agreement");
                            return;
                        }
                        complexes[map_id][map_to_check_div.childNodes[c].id] = makeComponents(lines,agreements);
                        console.log(complexes[map_id][map_to_check_div.childNodes[c].id]);
                        //check if map should be disabled
                        if (Object.keys(complexes[map_id][map_to_check_div.childNodes[c].id]).length == 0) {
                            delete complexes[map_id][map_to_check_div.childNodes[c].id];
                            document.getElementById(map_to_check_div.childNodes[c].id).style.display = "none";
                        }
                    }
                }

                if (complexes[map_id]) {
                    //printComplexes(complexes,map_id);
                    complexes = checkAgreement(complexes,map_id,agreements);
                } else {
                    console.log(map_id + "is now empty!!!");
                    maps_to_hide[map_id] = 1;
                }
                //check if map should be disabled
                if (complexes[map_id]) {
                    if (Object.keys(complexes[map_id]).length == 0) {
                        delete complexes[map_id];
                        maps_to_hide[map_id] = 1;
                    }
                }
                //printComplexes(complexes,map_id);
            }

            var op = document.getElementById('mapselect').options;
            if (Object.keys(maps_to_hide).length != op.length) {
                //hide maps and build pruned_selector
                var pruned_select = document.createElement("select");
                document.getElementById('mapselect').style.display = "none";
                pruned_select.setAttribute("id","pruned_select");
                pruned_select.setAttribute("onchange","changemap(this)");

                //console.log(maps_to_hide);
                for (let o = 0; o < op.length; o++) {
                    if (maps_to_hide[op[o].value]) {
                        continue;
                    } else {
                        var option = document.createElement("option");
                        option.value = op[o].value;
                        option.text = op[o].text;
                        pruned_select.add(option);
                    }
                }
                document.getElementById('mapselect').parentNode.appendChild(pruned_select);
                pruned_select.style.display = "block";
            } else {
                pathfilterAgreements(pool_content,"reset");
                return;
            }
    }

    if (task === "reset") {
        var filters = document.querySelectorAll(".logistics_pool_li");
        for (let i = 0; i < filters.length; i++) {
            filters[i].parentNode.removeChild(filters[i]);
        }
        for (key in agreement_pool_content) {
            agreement_pool_content[key] = 0;
        }

        var complexes = document.querySelectorAll(".complex");
        for (let i = 0; i < complexes.length; i++) {
            complexes[i].style.display = "block";
        }
        if (document.getElementById("pruned_select")) {
            document.getElementById("pruned_select").parentNode.removeChild(document.getElementById("pruned_select"));
        }
        document.getElementById('mapselect').style.display = "block";
        return;
    }
}

function makeComponents(lines,agreements) {

    //var terms = agreement.split("|");
    var looking_for = {};
    for (let i = 0; i < agreements.length;i++) {
        var terms = agreements[i].split("|");
        looking_for[terms[0]] = 1;
        looking_for[terms[1]] = 1;
    }

    const type_regex = new RegExp(/type:(.+?)$/);
    const id_regex = new RegExp(/id:(.+?)$/);
    const name_regex = new RegExp(/name:(.+?)$/);
    const mirt_regex = new RegExp(/mirt:(.+?)$/);
    const dev_regex = new RegExp(/dev:(.+?)$/);
    const meth_regex = new RegExp(/meth:(.+?)$/);
    const prot_regex = new RegExp(/prot:(.+?)$/);

    var type;
    var cn = 0;
    var un = 0;
    var tn = 0;
    var complex_components = {};
    //var complex_components = {1:{type:"",id:"",name:"",dev:"",meth:"",urnas:{},tfs:{}}};

    //console.log("makeComponents -> start");
    //console.log(`${terms[0]} | ${terms[1]} | ${terms[2]}`);
    //console.log("lines length -> "+lines.length);
    for (let i = 3; i < lines.length; i++) {
        var tags = lines[i].split("|");
        for (let c = 0; c < tags.length;c++) {
            //console.log("makeComponents -> tag -> "+tags[c]);
            if (type_regex.test(tags[c]) === true) {
                type = type_regex.exec(tags[c])[1];
                if (type === "deg") {
                    type = "gene";
                    //main component found
                    if (looking_for[type]) {
                        cn++;
                        tn = 0;
                        un = 0;
                        complex_components[cn] = {type:"gene",id:"",name:"",dev:"",meth:"",urnas:{},tfs:{}};
                    }
                }
                if (type === "prot") {
                    //main component found
                    if (looking_for[type]) {
                        tn = 0;
                        un = 0;
                        cn++;
                        complex_components[cn] = {type:"prot",id:"",name:"",dev:"",meth:"",urnas:{},tfs:{}};
                    }
                }
                if (type === "urna") {
                    if (looking_for[type]) {
                        if (complex_components[cn]) {
                            un++;
                            complex_components[cn].urnas[un] = {};
                        }
                    }
                }
                if (type === "tf") {
                    if (looking_for[type]) {
                        if (complex_components[cn]) {
                            tn++;
                            complex_components[cn].tfs[tn] = {};
                        }
                    }
                }
                //console.log("makeComponents -> found type -> "+ type);
            }
            if (!looking_for[type]) {
                //console.log("makeComponents -> next");
                continue;
            } else {
                //console.log(lines[i]);
                if (type === "gene" || type === "prot") {
                    if (id_regex.test(tags[c]) === true ) {
                        complex_components[cn].id = id_regex.exec(tags[c])[1];
                    }
                    if (name_regex.test(tags[c]) === true ) {
                        complex_components[cn].name = name_regex.exec(tags[c])[1];
                    }
                    if (dev_regex.test(tags[c]) === true ) {
                        complex_components[cn].dev = dev_regex.exec(tags[c])[1];
                    }
                    if (meth_regex.test(tags[c]) === true ) {
                        complex_components[cn].meth = meth_regex.exec(tags[c])[1];
                    }
                }
                if (complex_components[cn]) {
                    if (type === "urna") {
                        if (id_regex.test(tags[c]) === true ) {
                            complex_components[cn].urnas[un].id = id_regex.exec(tags[c])[1];
                        }
                        if (mirt_regex.test(tags[c]) === true ) {
                            complex_components[cn].urnas[un].mirt = mirt_regex.exec(tags[c])[1];
                        }
                        if (dev_regex.test(tags[c]) === true ) {
                            complex_components[cn].urnas[un].dev = dev_regex.exec(tags[c])[1];
                        }
                    }
                    if (type === "tf") {
                        if (id_regex.test(tags[c]) === true ) {
                            complex_components[cn].tfs[tn].id = id_regex.exec(tags[c])[1];
                        }
                        if (name_regex.test(tags[c]) === true ) {
                            complex_components[cn].tfs[tn].name = name_regex.exec(tags[c])[1];
                        }
                        if (dev_regex.test(tags[c]) === true ) {
                            complex_components[cn].tfs[tn].dev = dev_regex.exec(tags[c])[1];
                        }
                    }
                }
            }
        }

    }
    //console.log("makeComponents -> stop");
    return(complex_components);
}

function checkAgreement(complexes,map_id,agreements) {
    var p1 = [];
    var p2 = [];
    var t1 = [];
    for (let i = 0; i < agreements.length; i++) {
        var terms = agreements[i].split("|");
        p1.push(terms[0]);
        p2.push(terms[1]);
        t1.push(terms[2]);
    }
    console.log(`${p1.length} ${p2.length} ${t1.length}`);

    for (const complex_id in complexes[map_id]) {
        var seen_main_gene = {};
        var seen_main_prot = {};
        var main_devs_gene = {};
        var main_devs_prot = {};
        var validations = {};
        for (let n = 0; n < p1.length; n++) {
            validations[n] = 1;
        }
        for (const cn in complexes[map_id][complex_id]) {
            //console.log(complexes[map_id][complex_id][cn].id);
            //console.log(complexes[map_id][complex_id][cn].type);
            if (complexes[map_id][complex_id][cn].type === "gene") {
                seen_main_gene[complexes[map_id][complex_id][cn].id] = 1;
                main_devs_gene[complexes[map_id][complex_id][cn].id] = complexes[map_id][complex_id][cn].dev;
                //console.log(main_devs_gene[complexes[map_id][complex_id][cn].id]);
                // check for protein gene agreement
                if (seen_main_gene[complexes[map_id][complex_id][cn].id] && seen_main_prot[complexes[map_id][complex_id][cn].id]) {
                    for (let n = 0; n < p1.length; n++) {
                        var party1 = p1[n];
                        var party2 = p2[n];
                        var cond = t1[n];
                        if (party1 === "gene" && party2 ==="prot") {
                            if (cond === "+" && main_devs_gene[complexes[map_id][complex_id][cn].id] > 0 && main_devs_prot[complexes[map_id][complex_id][cn].id] > 0) {
                                validations[n]++;
                            }
                            if (cond === "+" && main_devs_gene[complexes[map_id][complex_id][cn].id] < 0 && main_devs_prot[complexes[map_id][complex_id][cn].id] < 0) {
                                validations[n]++;
                            }
                            if (cond === "-" && main_devs_gene[complexes[map_id][complex_id][cn].id] < 0 && main_devs_prot[complexes[map_id][complex_id][cn].id] < 0) {
                                validations[n]++;
                            }
                            if (cond === "-" && main_devs_gene[complexes[map_id][complex_id][cn].id] > 0 && main_devs_prot[complexes[map_id][complex_id][cn].id] < 0) {
                                validations[n]++;
                            }
                        }
                        if (party1 === "prot" && party2 ==="gene") {
                            if (cond === "+" && main_devs_gene[complexes[map_id][complex_id][cn].id] > 0 && main_devs_prot[complexes[map_id][complex_id][cn].id] > 0) {
                                validations[n]++;
                            }
                            if (cond === "+" && main_devs_gene[complexes[map_id][complex_id][cn].id] < 0 && main_devs_prot[complexes[map_id][complex_id][cn].id] < 0) {
                                validations[n]++;
                            }
                            if (cond === "-" && main_devs_gene[complexes[map_id][complex_id][cn].id] < 0 && main_devs_prot[complexes[map_id][complex_id][cn].id] < 0) {
                                validations[n]++;
                            }
                            if (cond === "-" && main_devs_gene[complexes[map_id][complex_id][cn].id] > 0 && main_devs_prot[complexes[map_id][complex_id][cn].id] < 0) {
                                validations[n]++;
                            }
                        }
                    }
                }
            }

            if (complexes[map_id][complex_id][cn].type === "prot") {
                seen_main_prot[complexes[map_id][complex_id][cn].name] = 1;
                main_devs_prot[complexes[map_id][complex_id][cn].name] = complexes[map_id][complex_id][cn].dev;
                // check for protein gene agreement
                if (seen_main_prot[complexes[map_id][complex_id][cn].name] && seen_main_gene[complexes[map_id][complex_id][cn].name]) {
                    for (let n = 0; n < p1.length; n++) {
                        var party1 = p1[n];
                        var party2 = p2[n];
                        var cond = t1[n];
                        if (party1 === "gene" && party2 ==="prot") {
                            if (cond === "+" && main_devs_gene[complexes[map_id][complex_id][cn].name] > 0 && main_devs_prot[complexes[map_id][complex_id][cn].name] > 0) {
                                validations[n]++;
                            }
                            if (cond === "+" && main_devs_gene[complexes[map_id][complex_id][cn].name] < 0 && main_devs_prot[complexes[map_id][complex_id][cn].name] < 0) {
                                validations[n]++;
                            }
                            if (cond === "-" && main_devs_gene[complexes[map_id][complex_id][cn].name] < 0 && main_devs_prot[complexes[map_id][complex_id][cn].name] < 0) {
                                validations[n]++;
                            }
                            if (cond === "-" && main_devs_gene[complexes[map_id][complex_id][cn].name] > 0 && main_devs_prot[complexes[map_id][complex_id][cn].name] < 0) {
                                validations[n]++;
                            }
                        }
                        if (party1 === "prot" && party2 ==="gene") {
                            if (cond === "+" && main_devs_gene[complexes[map_id][complex_id][cn].name] > 0 && main_devs_prot[complexes[map_id][complex_id][cn].name] > 0) {
                                validations[n]++;
                            }
                            if (cond === "+" && main_devs_gene[complexes[map_id][complex_id][cn].name] < 0 && main_devs_prot[complexes[map_id][complex_id][cn].name] < 0) {
                                validations[n]++;
                            }
                            if (cond === "-" && main_devs_gene[complexes[map_id][complex_id][cn].name] < 0 && main_devs_prot[complexes[map_id][complex_id][cn].name] < 0) {
                                validations[n]++;
                            }
                            if (cond === "-" && main_devs_gene[complexes[map_id][complex_id][cn].name] > 0 && main_devs_prot[complexes[map_id][complex_id][cn].name] < 0) {
                                validations[n]++;
                            }
                        }
                    }
                }
            }

            // check for a methylation agreement
            var meth_dev = complexes[map_id][complex_id][cn].meth;
            for (let n = 0; n < p1.length; n++) {
                var party1 = p1[n];
                var party2 = p2[n];
                var cond = t1[n];
                if (party1 === "gene" && party2 ==="meth") {
                    if (cond === "+" && meth_dev > 0 && main_devs_gene[complexes[map_id][complex_id][cn].id] > 0) {
                        validations[n]++;
                    }
                    if (cond === "+" && meth_dev < 0 && main_devs_gene[complexes[map_id][complex_id][cn].id] < 0) {
                        validations[n]++;
                    }
                    if (cond === "-" && meth_dev > 0 && main_devs_gene[complexes[map_id][complex_id][cn].id] < 0) {
                        validations[n]++;
                    }
                    if (cond === "-" && meth_dev < 0 && main_devs_gene[complexes[map_id][complex_id][cn].id] > 0) {
                        validations[n]++;
                    }
                }
                if (party1 === "prot" && party2 ==="meth") {
                    if (cond === "+" && meth_dev > 0 && main_devs_prot[complexes[map_id][complex_id][cn].id] > 0) {
                        validations[n]++;
                    }
                    if (cond === "+" && meth_dev < 0 && main_devs_prot[complexes[map_id][complex_id][cn].id] < 0) {
                        validations[n]++;
                    }
                    if (cond === "-" && meth_dev < 0 && main_devs_prot[complexes[map_id][complex_id][cn].id] > 0) {
                        validations[n]++;
                    }
                    if (cond === "-" && meth_dev > 0 && main_devs_prot[complexes[map_id][complex_id][cn].id] < 0) {
                        validations[n]++;
                    }
                }
            }

            var urna_devs = [];
            var tf_devs = [];

            // check for a urna agreement
            for (const un in complexes[map_id][complex_id][cn].urnas) {
                //console.log(complexes[map_id][complex_id][cn].urnas[un].id);
                //console.log(complexes[map_id][complex_id][cn].urnas[un].dev);
                urna_devs.push(complexes[map_id][complex_id][cn].urnas[un].dev);
            }
            //console.log("urna_devs -> " + urna_devs.length);
            if (urna_devs.length > 0){
                //console.log("checkAgreement ->" + complex_id + " -> " + cn + " -> checking urnas");
                for (let n = 0; n < p1.length; n++) {
                    var party1 = p1[n];
                    var party2 = p2[n];
                    var cond = t1[n];
                    //console.log("condition -> "+cond);
                    if (party1 === "gene" && party2 ==="urna") {
                        for (const un in urna_devs) {
                            //console.log(urna_devs[un] + "vs" + main_devs_gene[complexes[map_id][complex_id][cn].id]);
                            if (cond === "+" && main_devs_gene[complexes[map_id][complex_id][cn].id] > 0 && urna_devs[un] > 0) {
                                validations[n]++;
                            }
                            if (cond === "+" && main_devs_gene[complexes[map_id][complex_id][cn].id] < 0 && urna_devs[un] < 0) {
                                validations[n]++;
                            }
                            if (cond === "-" && main_devs_gene[complexes[map_id][complex_id][cn].id] < 0 && urna_devs[un] > 0) {
                                console.log("VALIDATION FOUND alpha");
                                validations[n]++;
                            }
                            if (cond === "-" && main_devs_gene[complexes[map_id][complex_id][cn].id] > 0 && urna_devs[un] < 0) {
                                console.log("VALIDATION FOUND beta");
                                validations[n]++;
                            }
                        }
                    }
                    if (party1 === "prot" && party2 ==="urna") {
                        for (const un in urna_devs) {
                            if (cond === "+" && main_devs_prot[complexes[map_id][complex_id][cn].name] > 0 && urna_devs[un] > 0) {
                                validations[n]++;
                            }
                            if (cond === "+" && main_devs_prot[complexes[map_id][complex_id][cn].name] < 0 && urna_devs[un] < 0) {
                                validations[n]++;
                            }
                            if (cond === "-" && main_devs_prot[complexes[map_id][complex_id][cn].name] < 0 && urna_devs[un] > 0) {
                                validations[n]++;
                            }
                            if (cond === "-" && main_devs_prot[complexes[map_id][complex_id][cn].name] > 0 && urna_devs[un] < 0) {
                                validations[n]++;
                            }
                        }
                    }
                }

            }

            // check for a tf agreement
            for (const tn in complexes[map_id][complex_id][cn].tfs) {
                tf_devs.push(complexes[map_id][complex_id][cn].tfs[tn].dev);
            }
            if (tf_devs.length > 0) {
                //console.log("checkAgreement -> checking tfs");
                for (let n = 0; n < p1.length; n++) {
                    var party1 = p1[n];
                    var party2 = p2[n];
                    var cond = t1[n];
                    if (party1 === "gene" && party2 ==="tf") {
                        for (const tn in tf_devs) {
                            if (cond === "+" && main_devs_gene[complexes[map_id][complex_id][cn].id] > 0 && tf_devs[tn] > 0) {
                                validations[n]++;
                            }
                            if (cond === "+" && main_devs_gene[complexes[map_id][complex_id][cn].id] < 0 && tf_devs[tn] < 0) {
                                validations[n]++;
                            }
                            if (cond === "-" && main_devs_gene[complexes[map_id][complex_id][cn].id] > 0 && tf_devs[tn] < 0) {
                                validations[n]++;
                            }
                            if (cond === "-" && main_devs_gene[complexes[map_id][complex_id][cn].id] < 0 && tf_devs[tn] > 0) {
                                validations[n]++;
                            }
                        }
                    }
                    if (party1 === "prot" && party2 ==="tf") {
                        for (const tn in tf_devs) {
                            console.log(main_devs_prot[complexes[map_id][complex_id][cn].name]+" vs "+tf_devs[tn]);
                            if (cond === "+" && main_devs_prot[complexes[map_id][complex_id][cn].name] > 0 && tf_devs[tn] > 0) {
                                validations[n]++;
                                console.log("Validation Found");
                            }
                            if (cond === "+" && main_devs_prot[complexes[map_id][complex_id][cn].name] < 0 && tf_devs[tn] < 0) {
                                validations[n]++;
                                console.log("Validation Found");
                            }
                            if (cond === "-" && main_devs_prot[complexes[map_id][complex_id][cn].name] > 0 && tf_devs[tn] < 0) {
                                validations[n]++;
                                console.log("Validation Found");
                            }
                            if (cond === "-" && main_devs_prot[complexes[map_id][complex_id][cn].name] < 0 && tf_devs[tn] > 0) {
                                validations[n]++;
                                console.log("Validation Found");
                            }
                        }
                    }
                }
            }

        }

        var display = 1;
        //console.log("checkAgreement -> validations found -> "+ validations.length);
        for (const vn in validations) {
            //console.log("checkAgreement -> validation #"+vn+" -> " + validations[vn]);
            if (validations[vn] > 1) {
                continue;
            } else {
                //console.log(complex_id + "will be hidden!!");
                display = 0;
                document.getElementById(complex_id).style.display = "none";
                delete complexes[map_id][complex_id];
                break;
            }
        }
        //if (display === 1) {
        //    console.log(complex_id + "will be displayed!!");
        //    continue;
        //}
    }
    return(complexes);
}

function printComplexes (complexes,map_id) {
    console.log("printComplexes -> " + map_id);
    for (const complex_id in complexes[map_id]) {
        console.log(`  -- ${complex_id} --`);
        for (const cn in complexes[map_id][complex_id]) {
            if (complexes[map_id][complex_id][cn].type === "prot") {
            console.log(`    -- component #${cn}`);
            console.log(`     Type: ${complexes[map_id][complex_id][cn].type}`);
            console.log(`     ID: ${complexes[map_id][complex_id][cn].id}`);
            console.log(`     Name: ${complexes[map_id][complex_id][cn].name}`);
            console.log(`     DEV: ${complexes[map_id][complex_id][cn].dev}`);
            console.log(`     Meth: ${complexes[map_id][complex_id][cn].meth}`);
            console.log(`     miRNAs:`);
            for (const un in complexes[map_id][complex_id][cn].urnas) {
                console.log(`      -- miRNA #${un}`);
                console.log(`       ID: ${complexes[map_id][complex_id][cn].urnas[un].id}`);
                console.log(`       MIRT ID: ${complexes[map_id][complex_id][cn].urnas[un].mirt}`);
                console.log(`       DEV: ${complexes[map_id][complex_id][cn].urnas[un].dev}`);
            }
            console.log(`     TFs:`);
            for (const tn in complexes[map_id][complex_id][cn].tfs) {
                console.log(`      -- TF #${tn}`);
                console.log(`       ID: ${complexes[map_id][complex_id][cn].tfs[tn].id}`);
                console.log(`       Name: ${complexes[map_id][complex_id][cn].tfs[tn].name}`);
                console.log(`       DEV: ${complexes[map_id][complex_id][cn].tfs[tn].dev}`);
            }
        }
        }
    }
    console.log("printComplexes -> stop");
}
