function toggleSettings(action){
	console.log('toggleSettings');

	var containerDiv = document.getElementById('container3');
	var settingsDiv = document.getElementById('settings_div');
	var logisticsDiv = document.getElementById('logistics_div');
	var idselectorDiv = document.getElementById('idselectors');

	if (containerDiv && settingsDiv && logisticsDiv && idselectorDiv) {
		if (logisticsDiv.style.display == "block" || idselectorDiv.style.display == "block") {
			logisticsDiv.style.display = "none";
			idselectorDiv.style.display == "none";
			containerDiv.style.display = "block";
			settingsDiv.style.display = "block";
			return;
		}
	
		if (containerDiv.style.display == "none" || containerDiv.style.display == "") {
			containerDiv.style.display = "block";
			settingsDiv.style.display = "block";
			return;
		}
		if (containerDiv.style.display == "block") {
			containerDiv.style.display = "none";
			settingsDiv.style.display = "none";
			return;
		}	
	}

}

function toggleLogistics(action) {
	console.log('toggleLogistics');

	var containerDiv = document.getElementById('container3');
	var settingsDiv = document.getElementById('settings_div');
	var logisticsDiv = document.getElementById('logistics_div');
	var idselectorDiv = document.getElementById('idselectors');

	if (containerDiv && settingsDiv && logisticsDiv && idselectorDiv) {
		if (settingsDiv.style.display == "block" || idselectorDiv.style.display == "block") {
			settingsDiv.style.display = "none";
			idselectorDiv.style.display = "none";
			containerDiv.style.display = "block";
			logisticsDiv.style.display = "block";
			return;
		}
	
		if (containerDiv.style.display == "none" || containerDiv.style.display == "") {
			containerDiv.style.display = "block";
			logisticsDiv.style.display = "block";
			return;
		}
		if (containerDiv.style.display == "block") {
			containerDiv.style.display = "none";
			logisticsDiv.style.display = "none";
			return;
		}	
	}
}





function toggleOverDiv(targetId) {
	
	var containerDiv = document.getElementById('container3');
	var targetDivId = document.getElementById(targetId);

	if (targetDivId.style.display == "block") {
		containerDiv.style.display = "none";
		targetDivId.style.display = "none";
		return;
	}

	var overDivSections = document.getElementsByClassName("overDivSection");
	for (overDivSection of overDivSections) {
		overDivSection.style.display = "none";
	}
	containerDiv.style.display = "block";
	targetDivId.style.display = "block";
	return;
}

function changemap(name) {
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
	var sel = document.getElementById(name.value);
	console.log(sel);
//	sel.style.visibility="visible"
	sel.style.display="block"
	var child2 = document.getElementById(name.value).children
	for(var j = 0; j < child2.length; j++) {
//		child2[j].style.visibility="visible"
		child2[j].style.display="block"
	}
}

//function change(action,dir) {
//    //	var all = document.getElementsByTagName("div")
//        var all = document.getElementsByClassName("complexes_div");
//        for(var i = 0; i < all.length; i++) {
//    //		if (all[i].style.visibility == "visible") {
//               var child = document.getElementById(all[i].id).children
//                //console.log(child);
//                for(var k = 0; k < child.length; k++) {
//                    if (child[k].alt == "complex") {
 //                       if (action == "trasp") {
//                            op = parseFloat(child[k].style.opacity)
//                            if (dir == "u") {
//                                op -= 0.1
//                            }
//                            if (dir == "d") {
//                                op += 0.1
//                            }
//                            child[k].style.opacity = op
//                        }
//                        if (action == "size") {
//                            if (dir == "u") {
//                                child[k].width += 5
//                                child[k].height += 5
//                                child[k].style.top = parseFloat(child[k].style.top)-2.5
//                                child[k].style.left = parseFloat(child[k].style.left)-2.5
//                            }
//                            if (dir == "d") {
//                                child[k].width -= 5
//                                child[k].height -= 5
//                                child[k].style.top = parseFloat(child[k].style.top)+2.5
//                                child[k].style.left = parseFloat(child[k].style.left)+2.5
//                            }
//                        }
//                    }
//                }
            //}
//        }
//}


function change(action,dir) {
    let indicators = document.querySelectorAll(".complex");
    for(let indicator of indicators) {
        var selected = false;
        if (indicator.style.border === "3px dotted blue") {
            indicator.style.border = "";
            selected = true;
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
                indicator.style.top = parseFloat(indicator.style.top)-2.5
                indicator.style.left = parseFloat(indicator.style.left)-2.5
            }
            if (dir == "d") {
                indicator.width -= 5
                indicator.height -= 5
                indicator.style.top = parseFloat(indicator.style.top)+2.5
                indicator.style.left = parseFloat(indicator.style.left)+2.5
            }
        }
        if (selected === true) {
            indicator.style.border = "3px dotted blue";
        }
        
    }
}















choices = [];
choice_g0 = "none";
choice_g1 = "none";
choice_g2 = "none";



function pathfilter(e,sel_pool) {

    var check1 = document.getElementById('select1'); //genes
    var check2 = document.getElementById('select2'); //mirnas
    var check3 = document.getElementById('select3');
    var checkp = document.getElementById('pruned_select'); //temporal selector for each selection made
    var check4 = document.getElementById('select4'); //ontologies
    var check5 = document.getElementById('select5');
    var check7 = document.getElementById('select6'); //proteins

    if (checkp) {document.getElementById('mapselect').parentNode.removeChild(checkp);}

    var op = document.getElementById('mapselect').options;
    var choice;
    if (e == 1) {
        if (sel_pool) {
            console.log("Selecting From Pool:" + sel_pool);
            choice = sel_pool;
        } else {
            choice = document.getElementById('select1').value;

        }
        console.log(choice);
        if (check2) {document.getElementById('select2').selectedIndex = 0;}
        if (check3) {document.getElementById('select3').selectedIndex = 0;}
        if (check5) {document.getElementById('select5').selectedIndex = 0;}
        //for (var i = 0; i < op.length; i++) {
		//	op[i].disabled = true ;
		//}
        deactivate_all('select1','gene');
        if (choice == 'all') {
            for (var i = 0; i < op.length; i++) {
                op[i].disabled = false ;
            }

            document.getElementById('mapselect').style.display = "block";
            document.getElementById('mapselect').selectedIndex = 0;
            changemap(document.getElementById('mapselect'));
            return;
        }
        var pruned_select = document.createElement("select");
        document.getElementById('mapselect').style.display = "none";

        pruned_select.setAttribute("id","pruned_select");
        pruned_select.setAttribute("onchange","changemap(this)");

        for (var d = 0; d < gene2comp[choice].length; d++) {
            highlight_complex(gene2comp[choice][d]);
        }

        var array = genesel[choice];
        console.log(array);
        for (var i = 0; i < array.length; i++) {
            console.log(op[array[i]]);
            var option = document.createElement("option");
            option.value = op[array[i]].value;

            option.text = op[array[i]].text;
            pruned_select.add(option);
        }
        document.getElementById('mapselect').parentNode.appendChild(pruned_select);
        document.getElementById('pruned_select').selectedIndex = 0;
        changemap(document.getElementById('pruned_select'));
    }

    if (e == 2) {

        if (sel_pool) {
            console.log("Selecting From Pool:" + sel_pool);
            choice = sel_pool;
        } else {
            console.log(choice);
            choice = document.getElementById('select2').value;
        }
        if (check1) {document.getElementById('select1').selectedIndex = 0;}
        if (check3) {document.getElementById('select3').selectedIndex = 0;}
        if (check5) {document.getElementById('select5').selectedIndex = 0;}
        //for (var i = 0; i < op.length; i++) {
		//	op[i].disabled = true ;
		//}
        deactivate_all('select2','urna');
        if (choice == 'all') {
            for (var i = 0; i < op.length; i++) {
                op[i].disabled = false ;
            }

            document.getElementById('mapselect').style.display = "block";
            document.getElementById('mapselect').selectedIndex = 0;
            changemap(document.getElementById('mapselect'));
            return;
        }
        var pruned_select = document.createElement("select");
        document.getElementById('mapselect').style.display = "none";

        pruned_select.setAttribute("id","pruned_select");
        pruned_select.setAttribute("onchange","changemap(this)");
        var array = urnasel[choice];
        console.log(array);
        for (var i = 0; i < array.length; i++) {
            console.log(op[array[i]]);
            var option = document.createElement("option");
            option.value = op[array[i]].value;

            option.text = op[array[i]].text;
            pruned_select.add(option);
        }

        for (var d = 0; d < urna2comp[choice].length; d++) {
            highlight_complex(urna2comp[choice][d]);
        }
        document.getElementById('mapselect').parentNode.appendChild(pruned_select);
        document.getElementById('pruned_select').selectedIndex = 0;
        changemap(document.getElementById('pruned_select'));
    }

    if (e == 3) {
        if (sel_pool) {
            console.log("Selecting From Pool:" + sel_pool);
            choice = sel_pool;
        } else {
            choice = document.getElementById('select3').value;
            console.log(choice);
        }
        if (check1) {document.getElementById('select1').selectedIndex = 0;}
        if (check2) {document.getElementById('select2').selectedIndex = 0;}
        if (check5) {document.getElementById('select5').selectedIndex = 0;}
        //for (var i = 0; i < op.length; i++) {
		//	op[i].disabled = true ;
		//}
        deactivate_all('select3','meta');
        if (choice == 'all') {
            for (var i = 0; i < op.length; i++) {
                op[i].disabled = false ;
            }

            document.getElementById('mapselect').style.display = "block";
            document.getElementById('mapselect').selectedIndex = 0;
            changemap(document.getElementById('mapselect'));
            return;
        }
        var pruned_select = document.createElement("select");
        document.getElementById('mapselect').style.display = "none";

        pruned_select.setAttribute("id","pruned_select");
        pruned_select.setAttribute("onchange","changemap(this)");
        var array = metasel[choice];
        console.log(array);
        for (var d = 0; d < meta2comp[choice].length; d++) {
            highlight_complex(meta2comp[choice][d]);
        }
        for (var i = 0; i < array.length; i++) {
            console.log(op[array[i]]);
            var option = document.createElement("option");
            option.value = op[array[i]].value;

            option.text = op[array[i]].text;
            pruned_select.add(option);
        }
        document.getElementById('mapselect').parentNode.appendChild(pruned_select);
        document.getElementById('pruned_select').selectedIndex = 0;
        changemap(document.getElementById('pruned_select'));
    }
    if (e == 4) {
        var op = document.getElementById('mapselect').options;
        var current_map_index = document.getElementById('mapselect').selectedIndex;
        if (sel_pool) {
            console.log("Selecting From Pool:" + sel_pool);
            choice = sel_pool;
        } else {
            choice = document.getElementById('select4').value;
            console.log(choice);
        }
        if (check1) {document.getElementById('select1').selectedIndex = 0;}
        if (check2) {document.getElementById('select2').selectedIndex = 0;}
        if (check3) {document.getElementById('select3').selectedIndex = 0;}
        if (check5) {document.getElementById('select5').selectedIndex = 0;}
        if (choice == 'none') {
            for (var i = 0; i < op.length; i++) {
                op[i].disabled = false ;
            }
            var comps = document.getElementsByClassName('complex');
            for (var i = 0; i < comps.length; i++) {
                comps[i].style.visibility = "visible";
            }
            document.getElementById('mapselect').style.display = "block";
            document.getElementById('mapselect').selectedIndex = 0;
            changemap(document.getElementById('mapselect'));
            return;
        }
        var pruned_select = document.createElement("select");
        document.getElementById('mapselect').style.display = "none";
        pruned_select.setAttribute("id","pruned_select");
        pruned_select.setAttribute("onchange","changemap(this)");

        var genes_array = ont2gene[choice];

        let tmp_maps_sel = {};
        let tmp_comp_sel = {};

        if (!tmp_maps_sel[choice]) {
            tmp_maps_sel[choice] = {};
        }
        if (!tmp_comp_sel[choice]) {
            tmp_comp_sel[choice] = {};
        }
        var seen = {};
        var values = [];
        var values2 = [];
        for (var i = 0; i < genes_array.length; i++) {
            //console.log("genes_array:"+genes_array[i]);

            if (genesel[genes_array[i]]) {
                for (var c = 0; c < genesel[genes_array[i]].length; c++) {
                    //console.log("genesel "+genesel[genes_array[i]][c]);
                    if (!seen[genesel[genes_array[i]][c]]) {
                        var item1 = genesel[genes_array[i]][c];
                        seen[item1] = {};
                        values.push(item1);
                        tmp_maps_sel[choice] = values;
                        //console.log(tmp_maps_sel);
                        //console.log("new");
                    }
                }
            }
            if (gene2comp[genes_array[i]]) {
                for (var c = 0; c < gene2comp[genes_array[i]].length; c++) {
                    //console.log("gene2comp "+gene2comp[genes_array[i]][c]);
                    if (!seen[gene2comp[genes_array[i]][c]]) {
                        var item2 = gene2comp[genes_array[i]][c];
                        seen[item2] = {};
                        values2.push(item2);
                        tmp_comp_sel[choice] = values2;
                    }
                }
            }
        }
        for (var d = 0; d < tmp_maps_sel[choice].length; d++) {
            //console.log(op[tmp_maps_sel[choice][d]]);
            //console.log("Adding Option");
            var option = document.createElement("option");
            option.value = op[tmp_maps_sel[choice][d]].value;
            option.text = op[tmp_maps_sel[choice][d]].text;
            pruned_select.add(option);
        }
        var current_option = document.createElement("option");
        current_option.value = op[current_map_index].value;
        current_option.text = op[current_map_index].text;
        pruned_select.add(current_option);
        var comps = document.getElementsByClassName('complex');
        for (var d = 0; d < comps.length; d++) {
            //console.log(comps[d]);
            comps[d].style.visibility = "hidden";
        }
        console.log(tmp_comp_sel[choice].length);
        for (var d = 0; d < tmp_comp_sel[choice].length; d++) {
            //console.log(tmp_comp_sel[choice][d]);
            document.getElementById(tmp_comp_sel[choice][d]).style.visibility = "visible";
        }
        document.getElementById('mapselect').parentNode.appendChild(pruned_select);
        document.getElementById('pruned_select').selectedIndex = document.getElementById('pruned_select').options.length - 1;

        //changemap(document.getElementById('pruned_select'));
    }

    if (e == 5) {
        if (sel_pool) {
            console.log("Selecting From Pool:" + sel_pool);
            choice = sel_pool;
        } else {
            choice = document.getElementById('select5').value;

        }
        console.log(choice);
        if (check2) {document.getElementById('select2').selectedIndex = 0;}
        if (check3) {document.getElementById('select3').selectedIndex = 0;}
        if (checkp) {document.getElementById('select4').selectedIndex = 0;}
        //for (var i = 0; i < op.length; i++) {
        //	op[i].disabled = true ;
        //}
        deactivate_all('select5','tf');
        if (choice == 'all') {
            for (var i = 0; i < op.length; i++) {
                op[i].disabled = false ;
            }

            document.getElementById('mapselect').style.display = "block";
            document.getElementById('mapselect').selectedIndex = 0;
            changemap(document.getElementById('mapselect'));
            return;
        }
        var pruned_select = document.createElement("select");
        document.getElementById('mapselect').style.display = "none";

        pruned_select.setAttribute("id","pruned_select");
        pruned_select.setAttribute("onchange","changemap(this)");

        for (var d = 0; d < tf2comp[choice].length; d++) {
            highlight_complex(tf2comp[choice][d]);
        }

        var array = tfsel[choice];
        console.log(array);
        for (var i = 0; i < array.length; i++) {
            console.log(op[array[i]]);
            var option = document.createElement("option");
            option.value = op[array[i]].value;

            option.text = op[array[i]].text;
            pruned_select.add(option);
        }
        document.getElementById('mapselect').parentNode.appendChild(pruned_select);
        document.getElementById('pruned_select').selectedIndex = 0;
        changemap(document.getElementById('pruned_select'));
    }

    if (e == 6) {
        if (sel_pool) {
            console.log("Selecting From Pool:" + sel_pool);
            choice = sel_pool;
        } else {
            choice = document.getElementById('select6').value;

        }
        console.log(choice);
        if (check1) {document.getElementById('select1').selectedIndex = 0;}
        if (check2) {document.getElementById('select2').selectedIndex = 0;}
        if (check3) {document.getElementById('select3').selectedIndex = 0;}
        if (check4) {document.getElementById('select4').selectedIndex = 0;}
        //for (var i = 0; i < op.length; i++) {
		//	op[i].disabled = true ;
		//}
        deactivate_all('select6','prot');
        if (choice == 'all') {
            for (var i = 0; i < op.length; i++) {
                op[i].disabled = false ;
            }

            document.getElementById('mapselect').style.display = "block";
            document.getElementById('mapselect').selectedIndex = 0;
            changemap(document.getElementById('mapselect'));
            return;
        }
        var pruned_select = document.createElement("select");
        document.getElementById('mapselect').style.display = "none";

        pruned_select.setAttribute("id","pruned_select");
        pruned_select.setAttribute("onchange","changemap(this)");

        for (var d = 0; d < prot2comp[choice].length; d++) {
            highlight_complex(prot2comp[choice][d]);
        }

        var array = protsel[choice];
        console.log(array);
        for (var i = 0; i < array.length; i++) {
            console.log(op[array[i]]);
            var option = document.createElement("option");
            option.value = op[array[i]].value;

            option.text = op[array[i]].text;
            pruned_select.add(option);
        }
        document.getElementById('mapselect').parentNode.appendChild(pruned_select);
        document.getElementById('pruned_select').selectedIndex = 0;
        changemap(document.getElementById('pruned_select'));

    }

}

    