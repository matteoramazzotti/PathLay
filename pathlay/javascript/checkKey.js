document.onkeydown = checkKey;

function checkKey(e) {
	if (active == 'null') {
		return
	}
    e = e || window.event;
	var code = e.keyCode
	var sel = document.getElementById(active)
    if (code == '79') {
		 // o (opaque)
		e.preventDefault();
		if ((parseFloat(sel.style.opacity) + 0.1 <= 1)) {
			sel.style.opacity = parseFloat(sel.style.opacity) + 0.1;
		}
    }
    else if (code == '84') {
		// t (transparent)
		e.preventDefault();
		if ((parseFloat(sel.style.opacity) - 0.1) >= 0) {
			sel.style.opacity = parseFloat(sel.style.opacity) - 0.1;
		}
    }
    else if (code == '37') {
        // left arrow
		e.preventDefault();
		sel.style.left = parseFloat(sel.style.left)-2;
    }
    else if (code == '38') {
        // up arrow
		e.preventDefault();
		sel.style.top = parseFloat(sel.style.top)-2;
    }
    else if (code == '39') {
        // right arrow
		e.preventDefault();
		sel.style.left = parseFloat(sel.style.left)+2;
    }
    else if (code == '40') {
        // down arrow
		e.preventDefault();
		sel.style.top = parseFloat(sel.style.top)+2;
    }
    else if (code >= '48' && code <= '57') {
        // numbers
		sel.style.opacity = (code-48)/10;
    }
    else if (code == '66') {
        // b: bigger
		e.preventDefault();
		sel.width += 5;
		sel.height += 5;
		sel.style.top = parseFloat(sel.style.top)-2.5;
		sel.style.left = parseFloat(sel.style.left)-2.5;
	}
    else if (code == '83') {
        // s: smaller
		e.preventDefault();
		sel.width -= 5;
		sel.height -= 5;
		sel.style.top = parseFloat(sel.style.top)+2.5;
		sel.style.left = parseFloat(sel.style.left)+2.5;
	}
    else if (code == '13') {
        // s: smaller
		e.preventDefault()
		sel.width -= 5
		sel.height -= 5
		sel.style.top = parseFloat(sel.style.top)+2.5;
		sel.style.left = parseFloat(sel.style.left)+2.5;
	}
}
