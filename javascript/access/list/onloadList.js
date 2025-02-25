import {performAction} from "../accessUtils.js";

Array.from(document.getElementsByClassName("configure-button")).forEach(element => {
	element.addEventListener("click", function() {
		console.log(element.expId);
		performAction("editConf",element.getAttribute("expId"));
	});
});
Array.from(document.getElementsByClassName("run-last-button")).forEach(element => {
	element.addEventListener("click", function() {
		performAction("runLast",element.getAttribute("expId"));
	});
});