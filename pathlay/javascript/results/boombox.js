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

    //var indicatorContent = exploadIndicatorSrc(dblclickedIndicator.src);
    //indicatorContent = assignImg(indicatorContent);
    //buildBoomBoxLis(indicatorContent);
    populateBoomBox(dblclickedIndicator);


}

function populateBoomBox(dblclickedIndicator) {

    var mainBoomBoxUl = document.getElementById("mainBoomBoxUl"); 

    for (let component of complexObjs[dblclickedIndicator.id].components) {
        var mainLi = spawnLi(component.id + "_Li","mainBoomBoxLi","toggleExtraBoomBoxUl(\""+ component.id + "_Ul" +"\")");
        var extraUl = spawnUl(component.id + "_Ul","extraBoomBoxUl");

        var mainText = "ID: "+ component.id + "<br>";
        mainText += "Name: " + component.name +"<br>";

        if (component.type === "deg" || component.type === "prot" || component.type === "meta") {
            if (component.type === "deg") {
                mainText += "Type: mRNA<br>";
            }
            if (component.type === "prot") {
                mainText += "Type: Protein<br>";
            }
            if (component.type === "meta") {
                mainText += "Type: Metabolite<br>";
            }
            mainText += "Effect Size: " + component.dev +"<br>";
        }

        if (component.type === "nodeg") {
            mainText += "Type: noDEG<br>";
        }

        var mainFont = spawnFont(component.id +"_Li_Font" ,"boomBoxFont",mainText);
        mainLi.appendChild(mainFont);
        mainLi.style.backgroundImage = `url('../src/${component.img}')`;
        mainBoomBoxUl.appendChild(mainLi);
        document.getElementById("extraBoomBoxDivSection").appendChild(extraUl);

        if (component.methImg) {
            let extraLi = spawnLi(`${component.id}_meth_Li`,"mainBoomBoxLi");

            let extraText = "Type: Methylation<br>"; 
            extraText += `Effect Size:  ${component.meth}<br>`;
            let extraFont = spawnFont(`${component.id}_meth_Li_Font` ,"boomBoxFont",extraText);
            extraLi.style.backgroundImage = `url('../src/${component.methImg}')`;
            extraLi.appendChild(extraFont);
            extraUl.appendChild(extraLi);
        }
        if (component.chromaImg) {
            let extraLi = spawnLi(`${component.id}_chroma_Li`,"mainBoomBoxLi");

            let extraText = "Type: Chromatin<br>"; 
            extraText += `Effect Size:  ${component.chroma}<br>`;
            let extraFont = spawnFont(`${component.id}_chroma_Li_Font` ,"boomBoxFont",extraText);
            extraLi.style.backgroundImage = `url('../src/${component.chromaImg}')`;
            extraLi.appendChild(extraFont);
            extraUl.appendChild(extraLi);
        }
        if (component.urnas && component.urnas.length > 0) {
            for (const urnaObj of component.urnas) {
                let extraLi = spawnLi(component.id + "_" + urnaObj.id + "_Li","mainBoomBoxLi");
                
                let extraText = "ID: "+ urnaObj.id + "<br>";
                extraText += "MIRT ID: " + urnaObj.mirt +"<br>";
                extraText += "Type: miRNA<br>"; 
                extraText += "Effect Size: " + urnaObj.dev +"<br>";
                let extraFont = spawnFont(component.id + "_" + urnaObj.id + "_Li_Font","boomBoxFont", extraText);
                extraLi.style.backgroundImage = "url('../src/"+urnaObj.img+"')";;
                extraLi.appendChild(extraFont);
                extraUl.appendChild(extraLi);
            }
        }
        if (component.tfs && component.tfs.length > 0) {
            for (const tfObj of component.tfs) {
                let extraLi = spawnLi(component.id + "_" + tfObj.id + "_Li","mainBoomBoxLi");

                let extraText = "ID: "+ tfObj.id + "<br>";
                extraText += "Name: " + tfObj.name +"<br>";
                extraText += "Type: TF<br>"; 
                extraText += "Effect Size: " + tfObj.dev +"<br>";
                let extraFont = spawnFont(component.id + "_" + tfObj.id + "_Li_Font","boomBoxFont", extraText);
                extraLi.style.backgroundImage = "url('../src/"+tfObj.img+"')";;
                extraLi.appendChild(extraFont);
                extraUl.appendChild(extraLi);
            }
        }
        mainLi.addEventListener("click",function() {
            highLightBbLi(this.id);
        });
    }
}


function closeBoomBox() {

    document.getElementById("boomBoxDiv").remove();
    return;
}

function highLightBbLi(bbLiToHighLightId) {
    console.log("highlight bbli");
    let bbLiToHighLight = document.getElementById(bbLiToHighLightId);
    let bbLis = document.querySelectorAll(".mainBoomBoxLi");

    for (let bbLi of bbLis) {
        bbLi.style.backgroundColor = "";
    }
    bbLiToHighLight.style.backgroundColor = "rgb(160, 236, 255, .5)";
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