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
        //agreement_add_button.setAttribute(
        //    "onclick",
        //    "addAgreementToPool(document.getElementById('agreement_selector1').selectedOptions[0].value,document.getElementById('agreement_selector2').selectedOptions[0].value,document.getElementById('agreement_selector3').selectedOptions[0].value)"
        //);
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


function checkForPositiveAgreement(first_party,second_party,agreement_type) {
    if (second_party === "prot" || second_party === "gene" || second_party === "tf" || second_party ==="chroma") {
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
    } else {
        return;
    }
    return [target,title];

}


function checkForNegativeAgreement(first_party,second_party,agreement_type) {
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
    } else {
        return;
    }
    return [target,title];
}


function addAgreementToPool(first_party,second_party,agreement_type) {
    console.log(`Going to add ${first_party},${second_party},${agreement_type}`);

    //var target = "";
    //var title = "";
    let agreementInfo;

    agreementInfo = checkForPositiveAgreement(first_party,second_party,agreement_type);
    agreementInfo = checkForNegativeAgreement(first_party,second_party,agreement_type);
    

    console.log("addAgreementToPool - start");

    if (agreement_pool_content[agreementInfo[0] + "_li"] === 1) {
        console.log("element already in pool: abort");
        return
    }
    //logical_pool_content.push(element);

    console.log("creating li");
    var ul = document.getElementById('logistics_ul_pool_agreement');
    var li = document.createElement('li');
    li.id = target + "_li";
    li.className = "logistics_pool_li";
    li.innerHTML = title + '<input id="" class="ul_rm_button" name="" type="button" value="X" title="" style="margin-left:25px;width:20px;height:20px;font-size:8px;" onClick="removeAgreementFromPool(this.parentElement)"/>'
    
    ul.appendChild(li);
    agreement_pool_content[target + "_li"] = 1;
    agreement_pool_content["content"]++;
    console.log(li);
    console.log("addAgreementToPool - stop");
}

function removeAgreementFromPool(agreement_li) {
    console.log(agreement_li);
    console.log(agreement_li.id);
    agreement_pool_content[agreement_li.id] = 0;
    agreement_pool_content["content"]--;
    console.log(agreement_pool_content[agreement_li.id]);
    agreement_li.parentElement.removeChild(agreement_li);
    return;
}