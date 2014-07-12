
chrome.app.runtime.onLaunched.addListener(function(){

	var scripts = document.scripts;
	var existingScript = scripts["main"];
	if(existingScript == undefined || existingScript == null) {
		script = document.createElement('script');
		script.id = "main";
		script.src = "main.dart";
		script.type = "application/dart";
		document.body.appendChild(script);
	}
});