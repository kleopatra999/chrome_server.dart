part of chrome_server;

class Request {

  List _headerLines;

  /**
	* Builds [Request] from ArrayBuffer header information.
	* 
	* Example: 
	* 
	*		import 'package:chrome/chrome_app.dart' as chrome;
	*
	* 	var headerStr = """
	* 		GET /index.html?foo=bar&foo2=bar2 HTTP/1.1
  *   	Host: localhost:8080
  *   	Connection: keep-alive
  *   	Cache-Control: max-age=0
  *   	Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp
  *   	User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.67 (Dart) Safari/537.36
  *   	Accept-Encoding: gzip,deflate,sdch
  *   	Accept-Language: en-US,en;q=0.8	
	* 	""";
	* 
	* 	var header = new chrome.ArrayBuffer.fromString(headerStr);
	* 
	**/

  Request.from(chrome.ArrayBuffer header) {
    this._headerLines = new String.fromCharCodes(header.getBytes()).split('\n');
  }

  String _methodRoutePart() {
    return _headerLines.firstWhere((element) {
      // Only GET requests supported currently
      return element.contains("GET");
    }).trim();
  }

  /**
	* [Uri] of [Request].
	* 
	* Example:
	* 
	* GET /index.html?foo=bar&foo2=bar2 HTTP/1.1
	* 
	* requestUri : /index.html?foo=bar&foo2=bar2
	**/

  Uri get requestUri => _requestUri();

  Uri _requestUri() {
    String uriPart = _methodRoutePart().split(' ')[1];
    return Uri.parse(uriPart);
  }

  /**
	* Query parameters of request [Uri].
	* 
	* Example:
	* 
	* GET /index.html?foo=bar&foo2=bar2 HTTP/1.1
	* 
	* query =
	* 	foo  : bar,
	* 	foo2 : bar2
	**/

  Map get query => requestUri.queryParameters;

  /**
	* Path of request [Uri].
	* 
	* Example:
	* 
	* GET /index.html?foo=bar&foo2=bar2 HTTP/1.1
	* 
	* path : /index.html
	**/

  String get path => requestUri.path;

  /**
	* [Map] of request headers parsed from ArrayBuffer.
	**/

  Map get headers => _parseHeaders();

  Map _parseHeaders() {
    var hm = {};
    var exp = new RegExp(r"(\w+(-\w+)?):");
    _headerLines.where((element) => element.trim().startsWith(exp)).toList(
        ).forEach((element) {
      element = element.trim();
      Match match = exp.firstMatch(element);
      String headerKey = match.group(1);
      String headerValue = element.substring(match.end).trim();
      hm[headerKey] = headerValue;
    });

    return hm;
  }

  /**
	* Host of parsed request headers.
	* 
	* Example:
	* 		GET /index.html?foo=bar&foo2=bar2 HTTP/1.1
  *   	Host: localhost:8080
  * 
  * host == "localhost:8080"; // true
	**/
  String get host => headers["Host"];

  /**
	* Request method parsed from request headers.
	* 
	* Example:
	* 		GET /index.html?foo=bar&foo2=bar2 HTTP/1.1
	*	
	* method == "GET"; // true
	**/
  String get method => _methodRoutePart().split(' ')[0];

  /**
	* Connection keep-alive header parsed from header request.
	**/
  bool get keepAlive => headers["Connection"] == "keep-alive";

  /**
	* Mime-type parsed from request [Uri] path.
	**/
  String get mimeType => _mimeType();

  String _mimeType() {
    var mtr = new MimeTypeResolver();
    return mtr.lookup(path);
  }

}

class Response {

  final _headerCompleter = new Completer();
  final _bodyCompleter = new Completer();

  /**
	* The header component of the response.
	* 
	* Requires setting [request].
	* 
	* returns Future<ArrayBuffer> where ArrayBuffer is from the [chrome](https://pub.dartlang.org/packages/chrome) library.
	**/

  Future<chrome.ArrayBuffer> get header => _headerCompleter.future;

  /**
	* The body component of the response.
	* 
	* Requires setting [request].
	* 
	* returns Future<ArrayBuffer> where ArrayBuffer is from the [chrome](https://pub.dartlang.org/packages/chrome) library.
	**/
  Future<chrome.ArrayBuffer> get body => _bodyCompleter.future;

  /**
	* Sets the [Request].
	**/
  void set request(value) => _setRequest(value);

  void _setRequest(Request request) {

    var httpRequest = new HttpRequest();
    httpRequest.open('GET', '${request.path}', async: true);
    httpRequest.responseType = 'arraybuffer';
    var contentType = request.mimeType;

    httpRequest.onLoadEnd.listen((event) {

      if (httpRequest.status == 200) {

        Uint8List content = httpRequest.response;
        List<int> byteList = content.toList();

        var contentLength = content.length;
        var hsb = new StringBuffer();
        hsb.write("HTTP/1.0 200 OK\n");
        hsb.write("Content-length: $contentLength\n");
        hsb.write("Content-type: $contentType\n");
        hsb.write("\n\n");
        var header = hsb.toString();

        var headerBuffer = new chrome.ArrayBuffer.fromString(header);
        _headerCompleter.complete(headerBuffer);

        var bodyBuffer = new chrome.ArrayBuffer.fromBytes(byteList);
        _bodyCompleter.complete(bodyBuffer);

      } else {

        var errorContent = "<html><div>Not Found</div></html>";
        var contentLength = errorContent.length;
        var contentType = "text/html";

        var hsb = new StringBuffer();
        hsb.write("HTTP/1.0 404 Not Found\n");
        hsb.write("Content-length: $contentLength\n");
        hsb.write("Content-type: $contentType\n");
        hsb.write("\n\n");
        var header = hsb.toString();
        var headerBuffer = new chrome.ArrayBuffer.fromString(header);
        _headerCompleter.complete(headerBuffer);

        var bodyBuffer = new chrome.ArrayBuffer.fromString(errorContent);
        _bodyCompleter.complete(bodyBuffer);
      }
    });

    httpRequest.send();
  }

}
