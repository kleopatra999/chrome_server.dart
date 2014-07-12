import 'dart:html';
import 'dart:convert';
import 'dart:async';

void main() {
	var host = window.location.host;
	HttpRequest.getString("http://$host/mock/mock.json")
	.then((String content){
		var map = JSON.decode(content);
		map.forEach((k,v){
			var id = k;
			var imgUrl = v;
			var img = new Element.img();
			img.src = "http://$host/$v";
			var tooltip = new Element.div();
			tooltip.text = k;
			tooltip.style.display = "none";

			img.onMouseOver.listen((event){
				tooltip.style.display = "inline";
			});

			img.onMouseOut.listen((event){
				tooltip.style.display = "none";
			});

			querySelector("#$id")
			..append(img)
			..append(tooltip);
		});
	});

}

