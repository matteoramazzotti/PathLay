function screenshot() {
	// Get all elements with the class name "pathway_div"
	var all = document.getElementsByClassName("pathway_div");
	var target;

	// Loop through the elements to find the one that is displayed as "block"
	for (var i = 0; i < all.length; i++) {
			if (all[i].style.display === "block") {
					target = all[i]; // Save the visible div
					break; // Exit the loop once the visible div is found
			}
	}

	// Check if a visible target div is found
	if (target) {
			// Use html2canvas to take a snapshot of the target div
			html2canvas(target).then(function (canvas) {
					// Convert the canvas to a data URL
					var dataURL = canvas.toDataURL("image/png");

					// Create a download link
					var link = document.createElement("a");
					link.href = dataURL;
					link.download = "screenshot.png";

					// Programmatically click the link to trigger the download
					link.click();
			});
	} else {
			console.log("No visible div found with the class 'pathway_div'.");
	}
}
