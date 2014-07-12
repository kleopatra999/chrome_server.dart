import 'dart:html';

void main() {
	var webview = querySelector('#foo');
	var sb = new StringBuffer();
	var q = window.location.search;
	Map qMap = Uri.splitQueryString(q.substring(1));
	String port = qMap['port'];
  var url = 'http://localhost:$port/mock/solar.html';
  var request = new HttpRequest();
  request.responseType = 'blob';
  request.open('GET', url, async:true);
  request.onLoadEnd.listen((e){
    if(request.status == 200) {
      webview.attributes['src'] = Url.createObjectUrlFromBlob(request.response);
    }
  });

  request.send();
}
