function submitForm (task) {
	var input = document.getElementById('ope');
	input.setAttribute("value", task);
	if (task == 'add') {
		var r = window.confirm("You are about to register a new account");
		if (r == false) {
			return;
		}
	}
	document.getElementById('main').submit();
}

doit = function (what) {
   	var input = document.getElementById('ope');
   	input.setAttribute("value", what);
   	document.getElementById('main').submit();
}