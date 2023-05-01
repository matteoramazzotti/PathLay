function spawnDiv (id,className){
    var divToSpawn = document.createElement("div");
    divToSpawn.setAttribute("id",id);
    divToSpawn.setAttribute("class",className);
    return divToSpawn;
}
function spawnInput (id,className,type,value,onClickFunction){
    var inputToSpawn = document.createElement("input");
    inputToSpawn.setAttribute("id",id);
    inputToSpawn.setAttribute("class",className);
    inputToSpawn.setAttribute("type",type);
    inputToSpawn.setAttribute("value",value);
    inputToSpawn.setAttribute("onclick",onClickFunction);
    
    return inputToSpawn;

}
function spawnUl(id,className) {
    var ulToSpawn = document.createElement("ul");
    ulToSpawn.setAttribute("id",id);
    ulToSpawn.setAttribute("class",className);
    return ulToSpawn;
}
function spawnLi(id,className,onClickFunction,text) {
    var liToSpawn = document.createElement("li");
    liToSpawn.setAttribute("id",id);
    liToSpawn.setAttribute("class",className);
    if (text) {
        liToSpawn.innerHTML = text;
    }
    if (onClickFunction) {
        liToSpawn.setAttribute("onclick",onClickFunction);
    }
    return liToSpawn;
}
function spawnImg(id,className,source,onClickFunction) {
    var imgToSpawn = document.createElement("img");
    imgToSpawn.setAttribute("id",id);
    imgToSpawn.setAttribute("class",className);
    imgToSpawn.setAttribute("src",source);
    if (onClickFunction) {
        imgToSpawn.setAttribute("onclick",onClickFunction);
    }
    return imgToSpawn;
}

function spawnFont(id,className,text) {
    var fontToSpawn = document.createElement("font");

    fontToSpawn.setAttribute("id",id);
    fontToSpawn.setAttribute("class",className);
    fontToSpawn.innerHTML = text;
    return fontToSpawn
}