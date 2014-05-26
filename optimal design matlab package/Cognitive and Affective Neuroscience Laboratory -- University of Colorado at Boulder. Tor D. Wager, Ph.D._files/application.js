// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function switchMenu(caller, obj) {
	var el = document.getElementById(obj);
	if ( el.style.display != 'none' ) {
		el.style.display = 'none';
	}
	else {
		el.style.display = '';
	}
	// Toggle plus/minus image
	if (caller.id == 'expand') {
		if (caller.src.match('plus')) {
			caller.src = 'images/minus.png';
		} else {
			caller.src = 'images/plus.png';
		}
	}
}

// Show/hide paper types (article, review, chapter, etc.)
function switchType(caller) {
	var papers = document.getElementsByClassName('paper_' + caller.value);
	for (var i=0; i<papers.length; i++) {
		var el = papers[i];
		if (caller.checked) {
			el.style.display = '';
		}
		else {
			el.style.display = 'none';
		}
	}
}