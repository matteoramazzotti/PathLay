function highlight_complex(name) {
	console.log("HIGHLIGHTING: "+name);
	var sel = document.getElementById(name);
	sel.style.border = '3px dotted red';
	return;
}
function complex_selector(complex) {
	console.log("Complex passed: " + complex);
	console.log("Complex ID passed: " + complex.id);

	if (complex.id === active_complex_id) {
		//console.log("Doing Nothing: Id");
		return;
	}
	if (active_complex_id != "") {
		deactivate(active_complex_id)
	}

	activate(complex.id);
	//fill_info_display("");
	//console.log(complex);
	//console.log("SELECTED" + complex.id);
	//console.log(complex.title);
	//console.log(complex.src);
	//fill_info_display(complex.title);
	active_complex_id = complex.id;
	active_complex_title = complex.title;
	active_complex_src = complex.src;
    //active_complex_obj = ;
    fill_info_display(complex);
    return;
	////
}
function deactivate(name) {
	console.log("deactivating " + name);
	if (name) {
		var sel = document.getElementById(name)
		sel.style.borderStyle='none';
	}
	active_complex_id = "";
	//return active;
}
function activate(name) {
	active_complex_id = name;
	console.log("ACTIVATING: "+name);
	var sel = document.getElementById(name);
	//sel.style.borderStyle='dotted';
	sel.style.border = '3px dotted blue';
	//console.log(sel.style.borderStyle);
	return;
}
function deactivate_all(selector_id,type) {
	var id2comp;
	if (type === "gene") {
		id2comp = gene2comp;
	}
	if (type === "urna") {
		id2comp = urna2comp;
	}
	if (type === "meta") {
		id2comp = meta2comp;
	}

	if (type === "tf") {
		id2comp = tf2comp;
	}
	if (type === "prot") {
		id2comp = prot2comp;
	}

	for (var i = 1; i < document.getElementById(selector_id).options.length;i++) {
		var current = document.getElementById(selector_id).options[i].value;
		for (var d = 0; d < id2comp[current].length; d++) {
			deactivate(id2comp[current][d]);
		}
	}
}




function enable_selectors_results (choice) {
	console.log("enable_selectors_results");
    console.log(choice);
    var sels = [
        document.getElementById("geneHLDefault"),
        document.getElementById("urnaHLDefault"),
        document.getElementById("metaHLDefault"),
		document.getElementById("tfHLDefault"),
		document.getElementById("protHLDefault")
    ];
    for (var i = 0; i < sels.length; i++) {
        if (sels[i]) {
			console.log("HIDING: " + sels[i].id);
            sels[i].style.display = "none";
			sels[i].selectedIndex = 0;
		}
    }
    
    if (choice === "gene") {
        sels[0].style.display = "block";
		active_selector_number = 1;
    }
    if (choice === "urna") {
        sels[1].style.display = "block";
		active_selector_number = 2;
    }
    if (choice === "meta") {
        sels[2].style.display = "block";	
    }
    
	if (choice === "tf") {
		sels[3].style.display = "block";
	}

	if (choice === "prot") {
		sels[5].style.display = "block";
	}

}