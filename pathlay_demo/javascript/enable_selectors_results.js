document.addEventListener("DOMContentLoaded", function() {
	console.log('DOMContentLoaded -> PREPARED SELECTORS');
    enable_selectors_results(document.getElementById("select_type_main").value)
})


var active_selector_number;

function enable_selectors_results (choice) {
	console.log("enable_selectors_results");
    console.log(choice);
    var sels = [
        document.getElementById("select1"),
        document.getElementById("select2"),
        document.getElementById("select3"),
        document.getElementById("select4"),
		document.getElementById("select5"),
		document.getElementById("select6")
    ];
    for (var i = 0; i < sels.length; i++) {
        if (sels[i]) {
			console.log("HIDING: " + sels[i].id);
            sels[i].style.display = "none";
			sels[i].selectedIndex = 0;
		}
    }
    //var sel1 = document.getElementById("select1");
    //var sel2 = document.getElementById("select2");
    //var sel3 = document.getElementById("select3");
    //var sel5 = document.getElementById("select5");
    if (choice === "gene") {
        sels[0].style.display = "block";
		sels[3].selectedIndex = 0;
		active_selector_number = 1;
		pathfilter(4);
    }
    if (choice === "urna") {
        sels[1].style.display = "block";
		sels[3].selectedIndex = 0;
		active_selector_number = 2;
		pathfilter(4);
    }
    if (choice === "meta") {
        sels[2].style.display = "block";
		if (sels[3]) {
			sels[3].selectedIndex = 0;
			active_selector_number = 3;
			pathfilter(4);
		}
    }
    if (choice === "ont") {
        sels[3].style.display = "block";
    }
	if (choice === "tf") {
		sels[4].style.display = "block";
		if (sels[3]) {
			sels[3].selectedIndex = 0;
			active_selector_number = 5;
			pathfilter(4);
		}
	}

	if (choice === "prot") {
		sels[5].style.display = "block";
		if (sels[3]) {
			sels[3].selectedIndex = 0;
			active_selector_number = 5;
			pathfilter(4);
		}
	}

}
