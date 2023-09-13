
var active_logical_selected_element = {id:undefined,name:undefined,type:undefined};
var logical_pool_content = {content:0};

function logic_list_handler(type) {


    console.log("logic_list_handler - start");
    const selectors_available = [];
    //active_logical_selected_element = undefined;
    //active_logical_selected_element_type = undefined;
    active_logical_selected_element = {id:undefined,name:undefined,type:undefined};

    if (document.getElementById("select1b")) {
        selectors_available.push(document.getElementById("select1b"));
    }
    if (document.getElementById("select2b")) {
        selectors_available.push(document.getElementById("select2b"));
    }
    if (document.getElementById("select3b")) {
        selectors_available.push(document.getElementById("select3b"));
    }
    if (document.getElementById("select6b")) {
        selectors_available.push(document.getElementById("select6b"));
    }
    console.log("selector_available -> " + selectors_available.length);
    console.log("argument type -> " + type);

    for (let i = 0; i < selectors_available.length; i++) {
        console.log("hiding selector number" + i);
        selectors_available[i].selectedIndex = 0;
        selectors_available[i].style.display = 'none';
    }

    if (type === "gene") {
        console.log("displaying selector select1b");
        active_logical_selected_element.type = "gene";
        document.getElementById("select1b").style.display = 'block';
    }
    if (type === "urna") {
        console.log("displaying selector select2b");
        active_logical_selected_element.type = "urna";
        document.getElementById("select2b").style.display = 'block';
    }
    if (type === "meta") {
        console.log("displaying selector select3b");
        active_logical_selected_element.type = "meta";
        document.getElementById("select3b").style.display = 'block';
    }
    if (type === "prot") {
        console.log("displaying selector select6b");
        active_logical_selected_element.type = "prot";
        document.getElementById("select6b").style.display = 'block';
    }
    console.log("logic_list_handler - stop");
}

function activate_element_for_logic(element) {
    active_logical_selected_element.id = element;
}

function add_element_to_logic(element) {
    console.log("add_element_to_logic - start");
    console.log("element " + element.id);
    console.log("element " + element.type);
    if (element.id === undefined || element.id === "all") {
        return
    }
    if (logical_pool_content[element.id + "_li"] === 1) {
        console.log("element already in pool: abort");
        return
    }
    //logical_pool_content.push(element);

    console.log("creating li");
    var ul = document.getElementById('logistics_ul_pool');
    var li = document.createElement('li');
    li.id = element.id + "_li";
    li.className = "logistics_pool_li";
//    li.innerHTML = element.id + " (" + element.name + ") " + '<input id="" class="ul_rm_button" name="" type="button" value="X" title="" style="margin-left:25px;width:20px;height:20px;font-size:10px;"/>'
    li.innerHTML = element.id + '<input id="" class="ul_rm_button" name="" type="button" value="X" title="" style="margin-left:25px;width:20px;height:20px;font-size:10px;" onClick="remove_element_from_logic(this.parentElement)"/>'

    //<li id="GO:0000120" class="ont_li" style="">RNA polymerase I transcription regulator complex (<a target="_blank" style="text-decoration:none;" href="http://amigo.geneontology.org/amigo/term/GO:0000120">GO!</a>)<input type='hidden' name='onts' value='GO:0000120@'/><input id="" class="ul_add_button" name="" type="button" value="+" title="" style="margin-left:25px;width:20px;height:20px;font-size:10px;"/></li>
    if (element.type === "gene") {
        li.style.backgroundColor = '#e6faff';
    }
    if (element.type === "urna") {
        li.style.backgroundColor = '#ffb3b3';
    }
    if (element.type === "meta") {
        li.style.backgroundColor = '#ffffb3';
    }
    if (element.type === "prot") {
        li.style.backgroundColor = '#e6b3ff';
    }
    ul.appendChild(li);
    logical_pool_content[element.id + "_li"] = 1;
    logical_pool_content["content"]++;
    console.log(li);
    console.log("add_element_to_logic - stop");
}

function remove_element_from_logic(li) {
    console.log(li);
    const li_regex = new RegExp(/(.+?)_li$/);
    const id = li_regex.exec(li.id)[1];
    console.log(id);
    logical_pool_content[id + "_li"] = 0;
    logical_pool_content["content"]--;
    console.log(logical_pool_content[id + "_li"]);
    li.parentElement.removeChild(li);
    return
}

function pathfilter_logic(logical_pool_content,task) {

    if (task === "run") {

        if (logical_pool_content.content === 0) {
            console.log("array logical_pool_content is empty: abort");
            return
        }
        console.log("logical_pool_content: " + logical_pool_content.length);
        var filters = document.querySelectorAll(".logistics_pool_li");
        var logical_selection = [];
        var map_count = {};
        for (let i = 0; i < filters.length; i++) {
            console.log(filters[i]);
            const li_regex = new RegExp(/(.+?)_li$/);
            const id = li_regex.exec(filters[i].id)[1];
            console.log(id);
            //if (genesel[id] && !tfsel[id]) {
                //console.log("Checking genesel");
                //for (let c = 0; c < genesel[id].length;c++) {
                //    if (!map_count[genesel[id][c]]) {
                //        map_count[genesel[id][c]] = 0;
                //    }
                //    map_count[genesel[id][c]] += 1;
                //    console.log(map_count[genesel[id][c]]);
                //    if (map_count[genesel[id][c]] >= filters.length) {
                //        logical_selection.push(genesel[id][c]);
                //    }
                //}
            //}
            //if (tfsel[id] && !genesel[id]) {
                //console.log("Checking tfsel");
                //for (let c = 0; c < tfsel[id].length;c++) {
                    //if (!map_count[tfsel[id][c]]) {
                    //    map_count[tfsel[id][c]] = 0;
                    //}
                    //map_count[tfsel[id][c]] += 1;
                    //console.log(map_count[tfsel[id][c]]);
                    //if (map_count[tfsel[id][c]] >= filters.length) {
                        //logical_selection.push(tfsel[id][c]);
                    //}
                //}
            //}

            if (urnasel[id]) {
                console.log("Checking urnasel");
                for (let c = 0; c < urnasel[id].length;c++) {
                    if (!map_count[urnasel[id][c]]) {
                        map_count[urnasel[id][c]] = 0;
                    }
                    map_count[urnasel[id][c]] += 1;
                    console.log(map_count[urnasel[id][c]]);
                    if (map_count[urnasel[id][c]] >= filters.length) {
                        logical_selection.push(urnasel[id][c]);
                    }
                }
            }
            if (metasel[id]) {
                console.log("Checking metasel");
                for (let c = 0; c < metasel[id].length;c++) {
                    if (!map_count[metasel[id][c]]) {
                        map_count[metasel[id][c]] = 0;
                    }
                    map_count[metasel[id][c]] += 1;
                    console.log(map_count[metasel[id][c]]);
                    if (map_count[metasel[id][c]] >= filters.length) {
                        logical_selection.push(metasel[id][c]);
                    }
                }
            }
            if (tfsel[id] && genesel[id] && !protsel[id]) {
                console.log("Checking genesel and tfsel");
                //console.log(genesel[id].length);
                //console.log(tfsel[id].length);
                var tmp_map = {};
                for (let c = 0; c < tfsel[id].length;c++) {
                    tmp_map[tfsel[id][c]] = 1;
                }
                for (let c = 0; c < genesel[id].length;c++) {
                    tmp_map[genesel[id][c]] = 1;
                }
                for (const key in tmp_map) {
                    //console.log(key);
                    if (!map_count[key]) {
                        map_count[key] = 0;
                    }
                    map_count[key] += 1;
                    console.log(map_count[key]);
                    if (map_count[key] >= filters.length) {
                        logical_selection.push(key);
                    }
                }
            }
            if (tfsel[id] && !genesel[id] && protsel[id]) {
                console.log("Checking tfsel and protsel");
                //console.log(genesel[id].length);
                //console.log(tfsel[id].length);
                var tmp_map = {};
                for (let c = 0; c < tfsel[id].length;c++) {
                    tmp_map[tfsel[id][c]] = 1;
                }
                for (let c = 0; c < protsel[id].length;c++) {
                    tmp_map[protsel[id][c]] = 1;
                }
                for (const key in tmp_map) {
                    //console.log(key);
                    if (!map_count[key]) {
                        map_count[key] = 0;
                    }
                    map_count[key] += 1;
                    console.log(map_count[key]);
                    if (map_count[key] >= filters.length) {
                        logical_selection.push(key);
                    }
                }

            }
            if (!tfsel[id] && genesel[id] && protsel[id]) {
                console.log("Checking tfsel and protsel");
                //console.log(genesel[id].length);
                //console.log(tfsel[id].length);
                var tmp_map = {};
                for (let c = 0; c < genesel[id].length;c++) {
                    tmp_map[genesel[id][c]] = 1;
                }
                for (let c = 0; c < protsel[id].length;c++) {
                    tmp_map[protsel[id][c]] = 1;
                }
                for (const key in tmp_map) {
                    //console.log(key);
                    if (!map_count[key]) {
                        map_count[key] = 0;
                    }
                    map_count[key] += 1;
                    console.log(map_count[key]);
                    if (map_count[key] >= filters.length) {
                        logical_selection.push(key);
                    }
                }
            }
            if (tfsel[id] && genesel[id] && protsel[id]) {
                console.log("Checking tfsel and protsel");
                //console.log(genesel[id].length);
                //console.log(tfsel[id].length);
                var tmp_map = {};
                for (let c = 0; c < genesel[id].length;c++) {
                    tmp_map[genesel[id][c]] = 1;
                }
                for (let c = 0; c < protsel[id].length;c++) {
                    tmp_map[protsel[id][c]] = 1;
                }
                for (let c = 0; c < tfsel[id].length;c++) {
                    tmp_map[tfsel[id][c]] = 1;
                }
                for (const key in tmp_map) {
                    //console.log(key);
                    if (!map_count[key]) {
                        map_count[key] = 0;
                    }
                    map_count[key] += 1;
                    console.log(map_count[key]);
                    if (map_count[key] >= filters.length) {
                        logical_selection.push(key);
                    }
                }
            }
            if (genesel[id] && !protsel[id] && !tfsel[id]) {
                console.log("Checking genesel");
                for (let c = 0; c < genesel[id].length;c++) {
                    if (!map_count[genesel[id][c]]) {
                        map_count[genesel[id][c]] = 0;
                    }
                    map_count[genesel[id][c]] += 1;
                    console.log(map_count[genesel[id][c]]);
                    if (map_count[genesel[id][c]] >= filters.length) {
                        logical_selection.push(genesel[id][c]);
                    }
                }
            }
            if (!genesel[id] && protsel[id] && !tfsel[id]) {
                console.log("Checking protsel");
                for (let c = 0; c < protsel[id].length;c++) {
                    if (!map_count[protsel[id][c]]) {
                        map_count[protsel[id][c]] = 0;
                    }
                    map_count[protsel[id][c]] += 1;
                    console.log(map_count[protsel[id][c]]);
                    if (map_count[protsel[id][c]] >= filters.length) {
                        logical_selection.push(protsel[id][c]);
                    }
                }
            }
            if (!genesel[id] && !protsel[id] && tfsel[id]) {
                console.log("Checking tfsel");
                for (let c = 0; c < tfsel[id].length;c++) {
                    if (!map_count[tfsel[id][c]]) {
                        map_count[tfsel[id][c]] = 0;
                    }
                    map_count[tfsel[id][c]] += 1;
                    console.log(map_count[tfsel[id][c]]);
                    if (map_count[tfsel[id][c]] >= filters.length) {
                        logical_selection.push(tfsel[id][c]);
                    }
                }
            }
            console.log(logical_selection);
        }
        if (document.getElementById("pruned_select")) {
            document.getElementById("pruned_select").parentNode.removeChild(document.getElementById("pruned_select"));
        }
        var pruned_select = document.createElement("select");
        var op = document.getElementById('mapselect').options;
        document.getElementById('mapselect').style.display = "none";
        pruned_select.setAttribute("id","pruned_select");
        pruned_select.setAttribute("onchange","changemap(this)");

        for (var i = 0; i < logical_selection.length; i++) {
            var option = document.createElement("option");
            option.value = op[logical_selection[i]].value;

            option.text = op[logical_selection[i]].text;
            pruned_select.add(option);
        }
        document.getElementById('mapselect').parentNode.appendChild(pruned_select);
        document.getElementById('pruned_select').selectedIndex = 0;
        changemap(document.getElementById('pruned_select'));
    }
    if (task === "reset") {

        var filters = document.querySelectorAll(".logistics_pool_li");
        for (let i = 0; i < filters.length; i++) {
            filters[i].parentNode.removeChild(filters[i]);
        }
        for (key in logical_pool_content) {
            logical_pool_content[key] = 0;
        }
        if (document.getElementById("pruned_select")) {
            if (current_option_value != undefined) {
                var current_option_value = document.getElementById("pruned_select").selectedOptions[0].value;
                var op = document.getElementById('mapselect').options;
                var current_option_index = 0;
                for (var i = 0; i < op.length;i++) {
                    if (op[i].value === current_option_value) {
                        var current_option_index = i;
                    }
                }
                document.getElementById("pruned_select").parentNode.removeChild(document.getElementById("pruned_select"));
                document.getElementById('mapselect').selectedIndex = current_option_index;
            } else {
                document.getElementById("pruned_select").parentNode.removeChild(document.getElementById("pruned_select"));
                document.getElementById('mapselect').selectedIndex = 0;
            }
            document.getElementById('mapselect').style.display = "block";
            changemap(document.getElementById('mapselect'));
        }
        return;
    }
}
