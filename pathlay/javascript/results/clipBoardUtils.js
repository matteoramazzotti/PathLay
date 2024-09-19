//setAttribute("contenteditable", false);
//document.getElementById("shoppingBasket").innerText


function fill_info_display(active) {

	console.log("fill_info_display")

	//var div = document.getElementById("info_display_div");
	//div.setAttribute("contenteditable", true);
	
	let tmpObj = new Complex (active.id,active.parentElement.id);
    tmpObj.loadContent();

	tmpObj.fillInfoDisplay(tmpObj.id);
	//const info = get_info(text)
	//console.log(info)
	//div.innerHTML = info;
	//div.setAttribute("contenteditable", false);
}

function get_info(text) {

	//console.log("get_info");
	const mode_regex = new RegExp(/mode:(.+?)$/);

	//const mylines = text.split("\n");
	const mylines = text.split("%0A");
	let info = '';
	let mode;
	if (mode_regex.test(mylines[2]) === true) {
		mode = mode_regex.exec(mylines[2])[1];
	}

	for (let i = 3; i < mylines.length; i++) {
		//console.log(mylines[i]);
		//console.log(mode_regex.exec(mylines[i]));
		//if (mode === "id_only") {
			info = parse_info(info,mylines[i]);
		//}
		//if (mode === "full") {
			//info = parse_info(info,mylines[i]);
		//}
		//if (mode === "id_de") {
			//info = parse_info(info,mylines[i]);
		//}
	}
	return info;
}

function full_test(mylines,d) {

	console.log("full_test");
	const deg_regex =  new RegExp(/^deg: (.+?) \((.+?)\) logFC:(.+)/);
	const meth_regex = new RegExp(/^deg: (.+?) \((.+?)\) Methylation:(.+)/);
	const deg_meth_regex = new RegExp(/^deg: (.+?) \((.+?)\) logFC:(.+?) Methylation:(.+)/);
	const nodeg_regex =  new RegExp(/^nodeg: (.+?) \((.+)\)/);
	const meta_regex = new RegExp(/^meta: (.+?)\((.+?)\) logFC:(.+)/);
	const urna_regex = new RegExp(/miRNA: (.+?)\((.+?)\) logFC: (.+)/);

	let info = '';

	for (let i = d+1; i < mylines.length; i++) {
		if (meta_regex.test(mylines[i]) === true) {
			console.log("meta")
			let match = meta_regex.exec(mylines[i])
			console.log(`What do we have here? ${match[1]} ${match[2]} ${match[3]}`);
			let link = `<a target="_blank" href=\"https://www.kegg.jp/entry/${match[1]}\">${match[1]} (${match[2]}) </a>`
			//info += '<p style="font-size:12px;">' + match[1] + " (" + match[2] + ")" + "<br> logFC: " + match[3]  + "</p>";
			info += '<p style="font-size:13px;">' + link + "<br> logFC: " + match[3]  + "</p>";
		}
		if (deg_regex.test(mylines[i]) === true) {
			if (deg_meth_regex.test(mylines[i]) === true) {
				console.log("deg_meth")
				let match = deg_meth_regex.exec(mylines[i])
				console.log(`What do we have here? ${match[1]} ${match[2]} ${match[3]} ${match[4]}`);
				let link = `<a target="_blank" href=\"https://www.ncbi.nlm.nih.gov/gene/${match[1]}\">${match[1]} (${match[2]}) </a>`
				//info += '<p style="font-size:12px;">' + match[1] + " (" + match[2] + ")" + "<br> logFC: " + match[3] + "<br>Methylation: " + match[4] + "</p>";
				info += '<p style="font-size:13px;">' + link + "<br> logFC: " + match[3] + "<br>Methylation: " + match[4] + "</p>";
			} else {
				console.log("deg")
				let match = deg_regex.exec(mylines[i])
				console.log(`What do we have here? ${match[1]} ${match[2]} ${match[3]}`);
				let link = `<a target="_blank" href=\"https://www.ncbi.nlm.nih.gov/gene/${match[1]}\">${match[1]} (${match[2]}) </a>`
				//info += '<p style="font-size:12px;">' + match[1] + " (" + match[2] + ")" + "<br> logFC: " + match[3] + "</p>";
				info += '<p style="font-size:13px;">' + link + "<br> logFC: " + match[3] + "</p>";
			}
		}
		if (meth_regex.test(mylines[i]) === true) {

			console.log("meth")
			let match = meth_regex.exec(mylines[i])
			console.log(`What do we have here? ${match[1]} ${match[2]} ${match[3]}`);
			let link = `<a target="_blank" href=\"https://www.ncbi.nlm.nih.gov/gene/${match[1]}\">${match[1]} (${match[2]}) </a>`
			info += '<p style="font-size:13px;">' + link + "<br>" + "Methylation: " + match[3] + "</p>";

		}
		if (nodeg_regex.test(mylines[i]) === true) {
			console.log("nodeg")
			let match = nodeg_regex.exec(mylines[i])
			console.log(`What do we have here? ${match[1]} ${match[2]}`);

			let link = `<a target="_blank" href=\"https://www.ncbi.nlm.nih.gov/gene/${match[1]}\">${match[1]} (${match[2]}) </a>`
			//info += '<p style="font-size:12px;">' + match[1] + " (" + match[2] + ")" + "</p>";
			info += '<p style="font-size:13px;">' + link + "</p>";
		}
		if (urna_regex.test(mylines[i]) === true) {
			console.log("urna")
			let urna_match = urna_regex.exec(mylines[i])
			console.log(`What do we have here? ${urna_match[1]} ${urna_match[2]} ${urna_match[3]}`);
			let link = `<a target="_blank" href=\"https://mirtarbase.cuhk.edu.cn/~miRTarBase/miRTarBase_2022/php/detail.php?mirtid=${urna_match[2]}\"> (${urna_match[2]}) </a>`
			//info += '<p style="font-size:12px;">' + urna_match[1] + " (" + urna_match[2] + ")" + " logFC: " + urna_match[3] + "</p>";
			info += '<p style="font-size:13px;">' + urna_match[1] + link + " logFC: " + urna_match[3] + "</p>";
		}
	}
	return info;
}

function parse_info(info,line) {
	//console.log("id_only_test");
	const type_regex = new RegExp(/type:(.+?)$/);
  	const id_regex = new RegExp(/id:(.+?)$/);
  	const name_regex = new RegExp(/name:(.+?)$/);
  	const mirt_regex = new RegExp(/mirt:(.+?)$/);
	const dev_regex = new RegExp(/dev:(.+?)$/);
	const meth_regex = new RegExp(/meth:(.+?)$/);
	const prot_regex = new RegExp(/prot:(.+?)$/);

	//console.log(line);
	var tags = line.split("|");
  	var id;
  	var name;
  	var type;
  	var mirt;
	var dev = "";
	var meth = "";
	for (i = 0; i < tags.length; i++) {
  		//console.log(tags[i]);
	  	if (type_regex.test(tags[i]) === true) {
	    	type = type_regex.exec(tags[i])[1];
	    }
		if (id_regex.test(tags[i]) === true) {
	    	id = id_regex.exec(tags[i])[1];
	    }
	    if (name_regex.test(tags[i]) === true) {
	    	name = name_regex.exec(tags[i])[1];
	    }
	    if (mirt_regex.test(tags[i]) === true) {
	    	mirt = mirt_regex.exec(tags[i])[1];
	    }
		if (dev_regex.test(tags[i]) === true) {
			dev = dev_regex.exec(tags[i])[1];
		}
		if (meth_regex.test(tags[i]) === true) {
			meth = meth_regex.exec(tags[i])[1];
		}
	}
	if (type === "deg") {
	  	info = deg_info_constructor(info,id,name,dev,meth);
	}
  	if (type === "meta") {
  		info = meta_info_constructor(info,id,name,dev);
	}
	if (type === "nodeg") {
  		info = nodeg_info_constructor(info,id,name,meth);
  	}
	if (type === "urna") {
  		info = urna_info_constructor(info,id,mirt,dev);
  	}
	if (type === "tf") {
		info = tf_info_constructor(info,id,name,dev);
	}
	if (type === "prot") {
		info = prot_info_constructor(info,id,name,dev,meth);
	}
  	return info;
}

function deg_info_constructor (info,id,name,dev,meth) {
	//console.log("deg_info_constructor" + " " + id + " " + name);
	let link = `<a target="_blank" href=\"https://www.ncbi.nlm.nih.gov/gene/${id}\">${id} (${name}) </a>`
	info += '<p style="font-size:13px;">' + link + "<br>";
	if (meth != "") {
		info += ' Methylation: ' + meth + "<br>";
	}
	if (dev != "") {
		info += ' logFC: ' + dev + "<br>";;
	}
	info += "</p>";
	return info;
}


function prot_info_constructor (info,id,name,dev,meth) {

	let link = `<a target="_blank" href=\" https://www.uniprot.org/uniprotkb/${id}/entry\">${id}</a><a target="_blank" href=\"https://www.ncbi.nlm.nih.gov/gene/${name}\">(${name}) </a>`
	info += '<p style="font-size:13px;">' + link + "<br>";
	if (meth != "") {
		info += ' Methylation: ' + meth + "<br>";
	}
	if (dev != "") {
		info += ' logFC: ' + dev + "<br>";;
	}
	info += "</p>";
	return info;
}

function meta_info_constructor (info,id,name,dev) {
	//console.log("meta_info_constructor" + " " + id + " " + name);
	let link = `<a target="_blank" href=\"https://www.kegg.jp/entry/${id}\">${id} (${name}) </a>`
	info += '<p style="font-size:13px;">' + link + "<br>";
	if (dev != "") {
		info += ' logFC: ' + dev + "<br>";;
	}
	info += "</p>";
	return info;
}

function nodeg_info_constructor (info,id,name,meth) {
	//console.log("nodeg_info_constructor" + " " + id + " " + name)
	let link = `<a target="_blank" href=\"https://www.ncbi.nlm.nih.gov/gene/${id}\">${id} (${name}) </a>`
	info += '<p style="font-size:13px;">' + link + "<br>";
	if (meth != "") {
		info += ' Methylation: ' + meth + "<br>";
	}
	info += "</p>";
	return info;
}

function urna_info_constructor (info,id,mirt,dev) {
	let link = `<a target="_blank" href=\"https://mirtarbase.cuhk.edu.cn/~miRTarBase/miRTarBase_2022/php/detail.php?mirtid=${mirt}\"> (${mirt}) </a>`
	info += '<p style="font-size:13px;">' + id + link + "<br>";
	if (dev != "") {
		info += ' logFC: ' + dev + "<br>";;
	}
	info += "</p>";
	return info;
}

function tf_info_constructor (info,id,name,dev) {
	//console.log("tf_info_constructor" + " " + id + " " + name)
	let link = `<a target="_blank" href=\"http://www.gsea-msigdb.org/gsea/msigdb/cards/${name}_TARGET_GENES\"> (${name}) </a>`
	info += '<p style="font-size:13px;"> TF: ' + id + link + "<br>";
	if (dev != "") {
		info += ' logFC: ' + dev + "<br>";;
	}
	info += "</p>";
	return info;
}


var complex_pool = {};

function fill_complex_pool(complex) {

	console.log("Fill pool with:"+complex);
	var mini_regex = new RegExp(/_mini$/);
	var map_id_regex = new RegExp(/^(.+?)_/);
	var map_name_regex = new RegExp(/map_name:(.+?)%0A/);

	if (mini_regex.test(complex) === true) {
		complex = complex.replace(/_mini/g,"");
	}

	var map_id = map_id_regex.exec(document.getElementById(complex).id)[1];

	var map_name = document.getElementById(map_id).attributes.name.nodeValue;

	console.log(map_id);
	console.log(complex);
	console.log(complex_pool[complex]);
	//if (complex_pool[document.getElementById(complex).name] === 1) { //
	if (complex_pool[complex] === 1) {
		console.log("Complex already in pool!" + document.getElementById(complex).id);
		return;
	}
	if (document.getElementById(complex) && mini_regex.test(document.getElementById(complex).id) === true) {
		console.log("Complex already in pool 2!");
		return;
	}

	//document.getElementById('complex_pool_div').setAttribute("contenteditable", true);
	//var img_tag = "<img id=\""+document.getElementById(complex).id+"mini\" name=\""+document.getElementById(complex).name+"\" class=\"minicomplex\" src=\""+document.getElementById(complex).src+"\" title=\""+document.getElementById(complex).title+"\" height=20px width=20px />";

	//document.getElementById('complex_pool_div').innerHTML = img_tag;
	//console.log(img_tag);
	//document.getElementById('complex_pool_div').setAttribute("contenteditable", false);
	if (!(document.getElementById(map_id + "_subpool"))) {
		var map_div = document.createElement("div");
		map_div.setAttribute("id",map_id + "_subpool");
		map_div.setAttribute("class","complex_pool_map_div");
		document.getElementById('complex_pool_div').appendChild(map_div);
		map_div.innerHTML = '<div class="textstyle_complex_pool">'+ '<p style="color:white;">' + map_name + " (" + map_id + ")</p>" +'</div>'
	}

	var img = document.createElement("img");
	img.setAttribute("id",document.getElementById(complex).id+"_mini");
	img.setAttribute("src",document.getElementById(complex).src);
	img.setAttribute("height",30);
	img.setAttribute("width",30);
	img.setAttribute("class","minicomplex");
	img.setAttribute("title",document.getElementById(complex).title);
	img.setAttribute("content",document.getElementById(complex).attributes.content.nodeValue);
	const regex = new RegExp('_mini');
	if (regex.test(document.getElementById(complex).id) === false) {
		img.setAttribute("onClick","complex_selector("+document.getElementById(complex).id+"_mini"+")");
	} else {
		img.setAttribute("onClick","complex_selector("+document.getElementById(complex).id+")");
	}
	img.setAttribute("name",document.getElementById(complex).name);
	//document.getElementById('complex_pool_div').appendChild(img);
	document.getElementById(map_id + '_subpool').appendChild(img);
	//complex_pool[document.getElementById(complex).name] = 1; //
	console.log(document.getElementById(complex).id);
	complex_pool[document.getElementById(complex).id] = 1;
}


//<img id="hsa04550_31" name="130399(ACVR1C)_91(ACVR1B)" class="complex" alt="complex" src="pathlayplot.pl?source=nodeg: 130399 ACVR1C%0A	miRNA: hsa-miR-22-3p MIRT005779 logFC:-1.18268126666667%0Anodeg: 91 ACVR1B%0A	miRNA: hsa-miR-135b-5p MIRT438735 logFC:-5.7619203%0A	miRNA: hsa-miR-24-3p MIRT003830 logFC:1.286141%0A" border="" height="50" width="50" usemap="" onClick="complex_selector(hsa04550_31)" onmouseover="" onmouseout="" style="position:absolute; top:805px; left:219px; visibility:visible; opacity:0.7;z-index:3;" title="nodeg: 130399 (ACVR1C)
//	miRNA: hsa-miR-22-3p(MIRT005779) logFC: -1.18268126666667
//nodeg: 91 (ACVR1B)
//	miRNA: hsa-miR-135b-5p(MIRT438735) logFC: -5.7619203
//	miRNA: hsa-miR-24-3p(MIRT003830) logFC: 1.286141
//"/>


function purge_complex_pool(complex) {

	/*const regex = new RegExp('_mini');
	console.log("purge_complex_pool:begin");
	console.log("var complex = " + complex);
	var id;
	if (regex.test(document.getElementById(complex).id) === false) {
		var mini_complex = document.getElementById(document.getElementById(complex).id+"_mini");
		id = mini_complex.id;
	} else {
		var mini_complex = document.getElementById(document.getElementById(complex).id);
		id = mini_complex.id.replace(/_mini$/,"");
	}
	console.log("var id = " + id);
	console.log("var mini_complex = " + mini_complex);
	console.log(mini_complex.id);
	var parent_map_div = mini_complex.parentNode;
	mini_complex.parentNode.removeChild(mini_complex);
	//complex_pool[id] = 0;
	console.log(id);
	complex_pool[id] = 0;
	complex_pool[mini_complex.id] = 0;
	if (parent_map_div.childNodes.length === 1) {
		document.getElementById('complex_pool_div').removeChild(parent_map_div);
	}
	console.log("purge_complex_pool:end");
	return;*/
	console.log("purge_complex_pool:begin");
	console.log("var complex = " + complex);
	const regex = new RegExp('_mini');
	deactivate(complex)
	
	if (complex_pool[complex] === 1) {
		console.log("dict complex_pool contains " + complex);
	}
	var minicomplex_id;
	if (regex.test(complex) === false) {
		minicomplex_id = complex + "_mini";
	} else {
		minicomplex_id = complex;
		complex = complex.replace(/_mini/g,"");
	}
	if (document.getElementById(minicomplex_id)) {
		console.log(minicomplex_id + " is in pool");
		var parent = document.getElementById(minicomplex_id).parentNode;
		document.getElementById(minicomplex_id).parentNode.removeChild(document.getElementById(minicomplex_id));
		//console.log(minicomplex_id + "removed from pool");
		complex_pool[complex] = 0;
		if (parent.childNodes.length === 1) {
			document.getElementById('complex_pool_div').removeChild(parent);
		}
	}
	if (complex_pool[complex] === 0) {
		console.log("dict complex_pool doesn't contain " + complex);
	}
	console.log("purge_complex_pool:end");
	return;
}

function select_from_pool (active_complex_obj) {
    console.log("ACTIVATED:" + active_complex_id); //from complex_selector.js
    var text = active_complex_obj.src;
    var id = active_complex_obj.id;
    var name = active_complex_obj.name;
    var type;
    var value;
    const type_regex = new RegExp(/type:(.+?)\|/);
    const mini_regex = new RegExp(/(.+?)_mini/);
    const value_regex = new RegExp(/(.+?)\(/);
    if (mini_regex.test(id) === true) {
        id = mini_regex.exec(id)[1];
    }
    if (value_regex.test(name) === true) {
        value = value_regex.exec(name)[1];
    }
    console.log(id);
    console.log(value);
    console.log(text);

    if (type_regex.test(text) === true) {
        type = type_regex.exec(text)[1];
        console.log(type);
    }
    if (type === "deg") {
        console.log("DEG:"+type);
        change_sel(type,value);
    }
    if (type === "nodeg") {
        console.log("NODEG:"+type);
        change_sel(type,value);
    }
    if (type === "urna") {
        console.log("URNA:"+type);
        change_sel(type,value);
    }
    if (type === "meta") {
        console.log("META:"+type);
        change_sel(type,value);
    }
}


function change_sel (type,value) {
    var select_num;
    console.log(type);
    console.log(value);
    if (type === "deg" || type === "nodeg") {
        select_num = 1;
        type = "gene";
    }
    if (type === "urna") {
        select_num = 2;
    }
    if (type === "meta") {
        select_num = 3;
    }
    console.log(select_num);
    for (var i = 0; i < document.getElementById("select_type_main").options.length; i++){
        if (document.getElementById("select_type_main").options[i].value === type) {
            document.getElementById("select_type_main").selectedIndex = i;
            console.log("VALUE SELECTED: "+document.getElementById("select_type_main").options[i].value);
            enable_selectors_results(document.getElementById("select_type_main").options[i].value);
        }
    }
    for (var i = 0; i < document.getElementById("select"+select_num).options.length; i++){
        if (document.getElementById("select"+select_num).options[i].value === value) {
            document.getElementById("select"+select_num).selectedIndex = i;
            pathfilter(select_num);
        }
    }
}

function download_from_pool() {
    console.log("download_from_pool()");
    var pool = document.getElementById("complex_pool_div");
    var field = document.getElementById("info_to_download");
    field.textContent = "";

    const type_regex = new RegExp(/type:(.+?)$/);
    const id_regex = new RegExp(/id:(.+?)$/);
    const name_regex = new RegExp(/name:(.+?)$/);
    const mirt_regex = new RegExp(/mirt:(.+?)$/);
    const dev_regex = new RegExp(/dev:(.+?)$/);
    const meth_regex = new RegExp(/meth:(.+?)$/);
    const map_name_regex = new RegExp(/map_name:(.+?)$/);
    var type;
    var id;
    var name;
    var mirt;
    var dev;
    var meth;

    var id2type = {};
    var id2name = {};
    var id2dev = {};
    var id2meth = {};
    var id2mirt = {};
    var id2map = {};
    var mirt2gene = {};

    if (pool.childNodes.length < 2){
        alert("Nothing to download :(");
        return;
    }
    //ID	NAME   TYPE    DEV	METH	miRNA/Gene	MAP	LINK
    for (var t = 0; t < pool.childNodes.length; t++) {
        var subpool = pool.childNodes[t];
        console.log("SUBPOOL: " + subpool.id);
    for (var i = 1; i < subpool.childNodes.length; i++) {
        console.log(subpool.childNodes[i].src);
        console.log(subpool.childNodes[i].id);
        var info = subpool.childNodes[i].src.split("%0A");
        var current_gene = "";
        console.log(map_name_regex.exec(info[1]));
        var map_name = map_name_regex.exec(info[1])[1];
        map_name = map_name.replace(/%20/g," ");
        for (var c = 3; c < info.length -1; c++) {
            tags = info[c].split("|");
            for (var d = 0; d < tags.length; d++) {
                if (type_regex.test(tags[d])) {
                    type = type_regex.exec(tags[d])[1];
                    //console.log(type);
                }
                if (id_regex.test(tags[d])) {
                    id = id_regex.exec(tags[d])[1];
                    //console.log(id);
                    if (type === "deg" || type === "nodeg") {
                        current_gene = id;
                        console.log("CURRENT GENE TO LINK: " + current_gene);
                    }
                    id2map[id] = map_name;
                }
                if (name_regex.test(tags[d])) {
                    name = name_regex.exec(tags[d])[1];
                    //console.log(name);
                }
                if (mirt_regex.test(tags[d])) {
                    mirt = mirt_regex.exec(tags[d])[1];
                    //console.log(mirt);
                    console.log("LINKING " + mirt + " TO " + current_gene);
                    mirt2gene[mirt] = current_gene;
                    id2map[mirt] = map_name;
                }
                if (dev_regex.test(tags[d])) {
                    dev = dev_regex.exec(tags[d])[1];
                    //console.log(dev);
                }
                if (meth_regex.test(tags[d])) {
                    meth = meth_regex.exec(tags[d])[1];
                    //console.log(meth);
                }
            }
            if (type != "urna") {
                if (!(id in id2type)) {
                    id2type[id] = type;
                }
                if (!(id in id2name)) {
                    id2name[id] = name;
                }
                if (!(id in id2dev)) {
                    id2dev[id] = dev;
                }
                if (!(id in id2meth) && id2type[id] != "meta") {
                    id2meth[id] = meth;
                }
            } else if (type === "urna"){
                if (!(mirt in id2type)) {
                    id2type[mirt] = type;
                }
                //console.log(id2name[mirt]);
                if (!(mirt in id2name)) {
                    id2name[mirt] = id;
                    console.log("urna name: "+id);
                }
                if (!(id in id2dev)) {
                    id2dev[mirt] = dev;
                }
            }
        }
    }
    for (var id in id2type){
        console.log("Processing: "+id);

        console.log("ID: "+id+"\t");
        field.textContent += id+"\t";
        if (id in id2name) {
            console.log("NAME: "+id2name[id]+"\t");
            field.textContent += id2name[id]+"\t";
        }
        console.log(id2type[id]+"\t");
        field.textContent += id2type[id]+"\t";
        if (id in id2dev && id2dev[id] != undefined) {
            console.log("DEV: "+id2dev[id]+"\t");
            field.textContent += id2dev[id]+"\t";
        } else {
            field.textContent += "NA\t";
        }
        if (id in id2meth && id2meth[id] != undefined) {
            console.log("METH: "+id2meth[id]+"\t");
            field.textContent += id2meth[id]+"\t";
        } else {
            field.textContent += "NA\t";
        }
        field.textContent += id2map[id] + "\t";
        if (id2type[id] === "urna") {
            console.log("TRYING "+id);
            field.textContent += mirt2gene[id] + "\t";
        } else {
            field.textContent += "NA\t";
        }
        field.textContent += "\n";
    }
    id2type = {}; // lazy reset DO NOT TRY THIS AT HOME
    id2map = {}; // lazy reset DO NOT TRY THIS AT HOME
    }

    submitFormForPool();
}

function submitFormForPool() {
    var input = document.getElementById('ope');
	input.setAttribute("value", "download_pool");
    document.getElementById('main').target="new";
    document.getElementById('main').submit();
}
