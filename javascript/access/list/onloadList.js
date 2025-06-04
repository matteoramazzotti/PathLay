import { performAction, getQueryParam} from "../accessUtils.js";
import { postJsonAndStock, postJsonByForm } from "../accessRequests.js";

Array.from(document.getElementsByClassName("configure-button")).forEach(element => {
	element.addEventListener("click", function() {
		console.log(element.expId);
		performAction("editConf",element.getAttribute("expId"));
	});
});
Array.from(document.getElementsByClassName("run-last-button")).forEach(element => {
	element.addEventListener("click", async function() {
		// performAction("runLast",element.getAttribute("expId"));
		let url = `../cgi-bin/pathlayIntegrator.pl?sid=${getQueryParam('sid')}&exp=${element.getAttribute("expId")}`;
		let {result,promise} = await postJsonAndStock(url,{sid:getQueryParam('sid'),exp:element.getAttribute("expId")});
		let data = JSON.parse(result);
		url = `../cgi-bin/pathlayMaps.pl?sid=${getQueryParam('sid')}&exp=${element.getAttribute("expId")}`;
		postJsonByForm(url,data.data);
	});
});