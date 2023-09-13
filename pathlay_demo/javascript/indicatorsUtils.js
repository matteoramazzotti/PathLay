var active_complex_id = ""; //global?
var active_complex_title = ""; //global?
var active_complex_src = ""; //global?
var active_complex_obj;
function complex_selector(complex) {
	console.log("Complex passed: " + complex);
	console.log("Complex ID passed: " + complex.id);


	if (complex.id === active_complex_id) {
		//console.log("Doing Nothing: Id");
		return;
	}
	if (complex.title === active_complex_title) {
		//console.log("Doing Nothing: Title");
		//return;
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
	fill_info_display(complex.src);
	active_complex_obj = complex;
	active_complex_id = complex.id;
	active_complex_title = complex.title;
	active_complex_src = complex.src;



	//check enabled selector_id
	var active_selector;
	if (document.getElementById('select1')){
		var check = document.getElementById('select1').style.display;
		if (check === "block") {
			active_selector = document.getElementById('select1');
		}
	}
	if (document.getElementById('select2')){
    	var check = document.getElementById('select2').style.display;
		if (check === "block") {
			active_selector = document.getElementById('select2');
		}
	}
	if (document.getElementById('select3')){
    	var check = document.getElementById('select3').style.display;
		if (check === "block") {
			active_selector = document.getElementById('select3');
		}
	}
	if (document.getElementById('select5')){
		var check = document.getElementById('select5').style.display;
		if (check === "block") {
			active_selector = document.getElementById('select5');
		}
	}
	for (var i = 1;i < active_selector.options.length;i++) {
		var status_break = 0;
		var current = active_selector.options[i];
		//console.log("CURRENT "+current.value);
		if (current.selected === true) {
			status_break = 1;
			if (active_selector.id === "select1") {
				for (d = 0;d < gene2comp[current.value].length;d++) {
					document.getElementById(gene2comp[current.value][d]).style.border = "3px dotted red";
				}
			}
			if (active_selector.id === "select2") {
				for (d = 0;d < urna2comp[current.value].length;d++) {
					document.getElementById(urna2comp[current.value][d]).style.border = "3px dotted red";
				}
			}
			if (active_selector.id === "select3") {
				for (d = 0;d < meta2comp[current.value].length;d++) {
					document.getElementById(meta2comp[current.value][d]).style.border = "3px dotted red";
				}
			}
		}
		if (status_break === 1) {
			break;
		}
	}

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

function spawnBoomBox(dblclickedIndicator) {

    if (document.getElementById("boomBoxDiv")) {
        closeBoomBox();
    }

    var boomBoxDiv = spawnDiv("boomBoxDiv","boomBoxDiv");
    var boomBoxDivHeader = spawnDiv("boomBoxDivHeader","boomBoxDivHeader");
    var mainBoomBoxDivSection = spawnDiv("mainBoomBoxDivSection","leftSection boomBoxDivSection");
    var extraBoomBoxDivSection = spawnDiv("extraBoomBoxDivSection","rightSection boomBoxDivSection");
    var closeBoomButton = spawnInput("closeBoomBoxButton","closeBoomBoxButton","button","X","closeBoomBox()");
    var mainBoomBoxUl = spawnUl("mainBoomBoxUl","mainBoomBoxUl");

    boomBoxDiv.appendChild(boomBoxDivHeader);
    boomBoxDiv.appendChild(mainBoomBoxDivSection);
    boomBoxDiv.appendChild(extraBoomBoxDivSection);
    boomBoxDivHeader.appendChild(closeBoomButton);
    mainBoomBoxDivSection.appendChild(mainBoomBoxUl);

    document.getElementById("container6").appendChild(boomBoxDiv);

    var indicatorContent = exploadIndicatorSrc(dblclickedIndicator.src);
    indicatorContent = assignImg(indicatorContent);
    buildBoomBoxLis(indicatorContent);
    
}
function closeBoomBox() {

    document.getElementById("boomBoxDiv").remove();
    return;
}
function exploadIndicatorSrc(indicatorSrc) {
    
    var content = {};
    var lines = indicatorSrc.split("%0A");

    lines.shift();
    lines.shift();
    var mode = lines.shift();

    const type_regex = new RegExp(/type:(.+?)$/);
    const id_regex = new RegExp(/id:(.+?)$/);
    const name_regex = new RegExp(/name:(.+?)$/);
    const mirt_regex = new RegExp(/mirt:(.+?)$/);
    const dev_regex = new RegExp(/dev:(.+?)$/);
    const meth_regex = new RegExp(/meth:(.+?)$/);

    var mainEnabled = false;
    var metaEnabled = false;
    var urnaEnabled = false;
    var tfEnabled = false;

    for (line of lines) {
        var tags = line.split("|");
        for (var tag of tags) {
            if (type_regex.test(tag) === true) {
                var type = type_regex.exec(tag)[1];
                if (type ==="deg" || type ==="nodeg" || type === "prot") {
                    metaEnabled = false;
                    mainEnabled = true;
                    urnaEnabled = false;
                    tfEnabled = false;
                    var urnaNum = -1;
                    var tfNum = -1;
                    continue;
                }
                if (type ==="urna") {
                    metaEnabled = false;
                    mainEnabled = false;
                    urnaEnabled = true;
                    tfEnabled = false;
                    urnaNum++;
                    content[mainId].urnas[urnaNum] = {};
                    continue;
                }
                if (type ==="tf") {
                    metaEnabled = false;
                    mainEnabled = false;
                    urnaEnabled = false;
                    tfEnabled = true;
                    tfNum++;
                    content[mainId].tfs[tfNum] = {};
                    continue;
                }
                if (type ==="meta") {
                    metaEnabled = true;
                    mainEnabled = false;
                    urnaEnabled = false;
                    tfEnabled = false;
                    continue;
                }
            }
            if (id_regex.test(tag) === true) {
                if (mainEnabled === true) {
                    var mainId = id_regex.exec(tag)[1];
                    content[mainId] = {};
                    content[mainId].urnas = [];
                    content[mainId].tfs = [];
                    content[mainId].type = type;
                    continue;
                }
                if (urnaEnabled === true) {
                    var urnaId = id_regex.exec(tag)[1];
                    content[mainId].urnas[urnaNum].id = urnaId;
                    continue;
                }
                if (tfEnabled === true) {
                    var tfId = id_regex.exec(tag)[1];
                    content[mainId].tfs[tfNum].id = tfId;
                    continue;
                }
                if (metaEnabled === true) {
                    var metaId = id_regex.exec(tag)[1];
                    content[metaId] = {};
                    content[metaId].type = type;
                    continue;
                }
            }
            if (name_regex.test(tag) === true) {
                if (mainEnabled === true) {
                    var mainName = name_regex.exec(tag)[1];
                    content[mainId].name = mainName;
                    continue;
                }
                if (urnaEnabled === true) {
                    var urnaName = name_regex.exec(tag)[1];
                    content[mainId].urnas[urnaNum].name = urnaName;
                    continue;
                }
                if (tfEnabled === true) {
                    var tfName = name_regex.exec(tag)[1];
                    content[mainId].tfs[tfNum].name = tfName;
                    continue;
                }
                if (metaEnabled === true) {
                    var metaName = name_regex.exec(tag)[1];
                    content[metaId].name = metaName;
                    continue;
                }
            }
            if (dev_regex.test(tag) === true) {
            
                if (mainEnabled === true) {
                    var mainDev = dev_regex.exec(tag)[1];
                    content[mainId].dev = mainDev;
                    continue;
                }
                if (urnaEnabled === true) {
                    var urnaDev = dev_regex.exec(tag)[1];
                    content[mainId].urnas[urnaNum].dev = urnaDev;
                    continue;
                }
                if (tfEnabled === true) {
                    var tfDev = dev_regex.exec(tag)[1];
                    content[mainId].tfs[tfNum].dev = tfDev;
                    continue;
                }
                if (metaEnabled === true) {
                    var metaDev = dev_regex.exec(tag)[1];
                    content[metaId].dev = metaDev;
                    continue;
                }
            }
            if (mirt_regex.test(tag) === true) {
                var urnaMirt = mirt_regex.exec(tag)[1];
                content[mainId].urnas[urnaNum].mirt = urnaMirt;
                continue;
            }
            if (meth_regex.test(tag) === true) {
                var mainMeth = meth_regex.exec(tag)[1];
                content[mainId].meth = mainMeth;
                continue;
            }
        }
    }
    return content;
}
function assignImg(indicatorContent) {
    for (mainId in indicatorContent) {
        if (indicatorContent[mainId].dev && indicatorContent[mainId].type === "meta") {
            if (indicatorContent[mainId].dev > 0) {
                indicatorContent[mainId].mainImg = "../src/meta_up.png";
            }
            if (indicatorContent[mainId].dev < 0) {
                indicatorContent[mainId].mainImg = "../src/meta_down.png";
            }
            continue;
        }
        if (indicatorContent[mainId].dev && indicatorContent[mainId].type != "meta") {
            if (indicatorContent[mainId].dev > 0) {
                indicatorContent[mainId].mainImg = "../src/red_square.png";
            }
            if (indicatorContent[mainId].dev < 0) {
                indicatorContent[mainId].mainImg = "../src/green_square.png";
            }

        }
        if (!indicatorContent[mainId].dev){
            indicatorContent[mainId].mainImg = "../src/grey_square.png";
        }
        if (indicatorContent[mainId].meth) {
            if (indicatorContent[mainId].meth > 0) {
                indicatorContent[mainId].methImg = "../src/yellow_meth.png";
            }
            if (indicatorContent[mainId].meth < 0) {
                indicatorContent[mainId].methImg = "../src/blue_meth.png";
            }
        }
        if (indicatorContent[mainId].urnas) {
            for (const urnaObj of indicatorContent[mainId].urnas) {
                if (urnaObj.dev > 0) {
                    urnaObj.img = "../src/yellow_circle.png";
                }
                if (urnaObj.dev < 0) {
                    urnaObj.img = "../src/blue_circle.png";
                }
            }
        }
        if (indicatorContent[mainId].tfs) {
            for (const tfObj of indicatorContent[mainId].tfs) {
                if (tfObj.dev > 0) {
                    tfObj.img = "../src/yellow_tf.png";
                }
                if (tfObj.dev < 0) {
                    tfObj.img = "../src/blue_tf.png";
                }
            }
        }
    }
    return indicatorContent
}
function buildBoomBoxLis(indicatorContent) {

    var mainBoomBoxUl = document.getElementById("mainBoomBoxUl"); 

    for (mainId in indicatorContent) {
        var mainLi = spawnLi(mainId + "_Li","mainBoomBoxLi","toggleExtraBoomBoxUl(\""+ mainId + "_Ul" +"\")");
        var extraUl = spawnUl(mainId + "_Ul","extraBoomBoxUl");

        var mainText = "ID: "+ mainId + "<br>";
        mainText += "Name: " + indicatorContent[mainId].name +"<br>";

        if (indicatorContent[mainId].type === "deg" || indicatorContent[mainId].type === "prot" || indicatorContent[mainId].type === "meta") {
            if (indicatorContent[mainId].type === "deg") {
                mainText += "Type: mRNA<br>";
            }
            if (indicatorContent[mainId].type === "prot") {
                mainText += "Type: Protein<br>";
            }
            if (indicatorContent[mainId].type === "meta") {
                mainText += "Type: Metabolite<br>";
            }
            mainText += "Effect Size: " + indicatorContent[mainId].dev +"<br>";
        }

        if (indicatorContent[mainId].type === "nodeg") {
            mainText += "Type: noDEG<br>";
        }

        var mainFont = spawnFont(mainId +"_Li_Font" ,"boomBoxFont",mainText);

        mainLi.appendChild(mainFont);
        mainLi.style.backgroundImage = "url('"+indicatorContent[mainId].mainImg+"')";

        mainBoomBoxUl.appendChild(mainLi);
        document.getElementById("extraBoomBoxDivSection").appendChild(extraUl);

        if (indicatorContent[mainId].methImg) {
            let extraLi = spawnLi(mainId + "_meth" + "_Li","mainBoomBoxLi");

            let extraText = "Type: Methylation<br>"; 
            extraText += "Effect Size: " + indicatorContent[mainId].meth +"<br>";
            let extraFont = spawnFont(mainId +"math_Li_Font" ,"boomBoxFont",extraText);
            extraLi.style.backgroundImage = "url('"+indicatorContent[mainId].methImg+"')";
            extraLi.appendChild(extraFont);
            extraUl.appendChild(extraLi);
        }
        if (indicatorContent[mainId].urnas.length > 0) {
            for (const urnaObj of indicatorContent[mainId].urnas) {
                let extraLi = spawnLi(mainId + "_" + urnaObj.id + "_Li","mainBoomBoxLi");
                
                let extraText = "ID: "+ urnaObj.id + "<br>";
                extraText += "MIRT ID: " + urnaObj.mirt +"<br>";
                extraText += "Type: miRNA<br>"; 
                extraText += "Effect Size: " + urnaObj.dev +"<br>";
                let extraFont = spawnFont(mainId + "_" + urnaObj.id + "_Li_Font","boomBoxFont", extraText);
                extraLi.style.backgroundImage = "url('"+urnaObj.img+"')";;
                extraLi.appendChild(extraFont);
                extraUl.appendChild(extraLi);
            }
        }
        if (indicatorContent[mainId].tfs.length > 0) {
            for (const tfObj of indicatorContent[mainId].tfs) {
                let extraLi = spawnLi(mainId + "_" + tfObj.id + "_Li","mainBoomBoxLi");

                let extraText = "ID: "+ tfObj.id + "<br>";
                extraText += "Name: " + tfObj.name +"<br>";
                extraText += "Type: TF<br>"; 
                extraText += "Effect Size: " + tfObj.dev +"<br>";
                let extraFont = spawnFont(mainId + "_" + tfObj.id + "_Li_Font","boomBoxFont", extraText);
                extraLi.style.backgroundImage = "url('"+tfObj.img+"')";;
                extraLi.appendChild(extraFont);
                extraUl.appendChild(extraLi);
            }
        } 

    }

}
function toggleExtraBoomBoxUl(extraUlId) {
    var extraBoomBoxUls = document.getElementsByClassName("extraBoomBoxUl");
    for (extraBoomBoxUl of extraBoomBoxUls) {
        if (extraBoomBoxUl.id === extraUlId) {
            extraBoomBoxUl.style.display = "block";    
        } else {
            extraBoomBoxUl.style.display = "none";
        }
    }
    return
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
function highlight_complex(name) {
	console.log("HIGHLIGHTING: "+name);
	var sel = document.getElementById(name);
	sel.style.border = '3px dotted red';
	return;
}