import 'package:unittest/html_enhanced_config.dart';
import 'package:unittest/unittest.dart';
import 'package:crypto/crypto.dart';
import 'dart:html';
import 'dart:async';
import 'dart:typed_data';


import 'package:chrome_server/server.dart';
import 'package:chrome/chrome_app.dart' as chrome;

// To test run server at /test/invitro/route
// dart server.dart
// load localhost:8080/response.html in dartium

final baseUrl = "http://localhost:8080";

void main() {

	useHtmlEnhancedConfiguration();

	group('GET requests',(){
		var path;

		path = "mock/mock.css";
		testStringContent(path);

		path = "mock/index.html";
		testStringContent(path);

		path = "mock/mock.dart";
		testStringContent(path);

		path = "mock/mock.json";
		testStringContent(path);

		path = "mock/dart.jpeg";
		testByteContent(path);

		path = "mock/dart.png";
		testByteContent(path);

		test('404', (){
			Request request = _getRequest("path/not/found");
        	_responseToString(request)
        	.then(expectAsync((requestContent){
        		print(requestContent);
          		expect(requestContent.contains("404 Not Found"), isTrue);
          	}));
		});

	});
}

void testByteContent(String path) {
	test('/$path',(){
		path = "$baseUrl/$path";
		_getAsBytes(path)
		.then(expectAsync((List contentAsBytes) {
			String content = CryptoUtils.bytesToBase64(contentAsBytes);
			Request request = _getRequest(path);
			_responseToBase64(request)
			.then(expectAsync((requestContent){
				expect(requestContent, isNotNull);
			}));
        }))
        .catchError(expectAsync((e) {print(e);}, count: 0));
	});
}

void testStringContent(String path) {
	test('/$path',(){
		path = "$baseUrl/$path";
		_getAsString(path)
		.then(expectAsync((content) {
          Request request = _getRequest(path);
          _responseToString(request)
          .then(expectAsync((requestContent){
          	expect(requestContent, equals(content));
          }));
        }))
        .catchError(expectAsync((e) {print(e);}, count: 0));
	});
}

Future<List<int>> _getAsBytes(String path) {

	var completer = new Completer();
	var httpRequest = new HttpRequest();
	httpRequest.open('GET', path);
	httpRequest.responseType = 'arraybuffer';

	httpRequest.onLoad.listen((event){

		var contentList = [];

		if(httpRequest.status==200) {
			Uint8List content = httpRequest.response;
			contentList = content.toList();
		}

		completer.complete(contentList);
	});

	httpRequest.send();
	return completer.future;
}

Future<String> _getAsString(String path) {
	return HttpRequest.getString(path);
}

Future<String> _responseToBase64(Request request) {
	var response = new Response();
	return response.processRequest(request, excludeHeader:true)
	.then((chrome.ArrayBuffer buffer) {
		var bufferAsStr = CryptoUtils.bytesToBase64(buffer.getBytes());
		return new Future.value(bufferAsStr);
	});
}

Future<String> _responseToString(Request request) {
	var response = new Response();
	return response.processRequest(request, excludeHeader:true)
	.then((chrome.ArrayBuffer buffer) {
		var bufferAsStr = new String.fromCharCodes(buffer.getBytes());
		return new Future.value(bufferAsStr);
	});
}

Request _getRequest(String path) {
	String rawHeaderString = 
	"""
	GET $path HTTP/1.1
	Host: localhost:8080
	Connection: keep-alive
	Cache-Control: max-age=0
	Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp
	User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.67 (Dart) Safari/537.36
	Accept-Encoding: gzip,deflate,sdch
	Accept-Language: en-US,en;q=0.8
	""";

	return new Request.from(new chrome.ArrayBuffer.fromString(rawHeaderString));
}