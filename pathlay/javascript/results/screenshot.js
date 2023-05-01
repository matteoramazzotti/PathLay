function screenshot() {
//	var all = document.getElementsByTagName("div")
	var all = document.getElementsByClassName("pathway_div");
	for(var i = 0; i < all.length; i++) {
//		if (all[i].style.visibility == "visible") {
		if (all[i].style.display == "block") {
			var vis = all[i].id
		}
		console.log(vis);
	}
	var target = document.getElementById(vis)
	html2canvas(target, {
		onrendered: function(canvas) {
			var data = canvas.toDataURL();
			window.open(data);
		}
	});
}
