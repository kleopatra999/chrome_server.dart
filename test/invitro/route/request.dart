import 'package:unittest/html_enhanced_config.dart';
import 'package:unittest/unittest.dart';
import 'dart:html';
import 'package:chrome_server/server.dart';
import 'package:chrome/chrome_app.dart' as chrome;

void main() {
  useHtmlEnhancedConfiguration();

  group('hardcoded header tests:', () {
    chrome.ArrayBuffer hardCodedHeader = _hardCodedHeader();
    var hardCodedRequest = new Request.from(hardCodedHeader);
    group("Request.requestUri(/?foo=bar&foo2=bar2) : ", () {
      Uri requestUri = hardCodedRequest.requestUri;
      test(" is not null", () {
        expect(requestUri, isNotNull);
      });
      test("path is '/'", () {
        expect(requestUri.path, equals("/"));
      });
      test("query string is not null", () {
        expect(requestUri.query, isNotNull);
      });
      test("query string is foo=bar&foo2=bar2", () {
        expect(requestUri.query, equals("foo=bar&foo2=bar2"));
      });
      var qp = requestUri.queryParameters;
      test("query parameters is not null", () {
        expect(qp, isNotNull);
      });
      test("query parameters: foo=bar", () {
        expect(qp["foo"], equals("bar"));
      });
      test("query parameters: foo2=bar2", () {
        expect(qp["foo2"], equals("bar2"));
      });
    });

    group("Request.query(/?foo=bar&foo2=bar2) : ", () {
      Map query = hardCodedRequest.query;

      test("is not null", () {
        expect(query, isNotNull);
      });

      test("parameters: foo=bar", () {
        expect(query["foo"], equals("bar"));
      });

      test("parameters: foo2=bar2", () {
        expect(query["foo2"], equals("bar2"));
      });
    });

    group("Request.path(/?foo=bar&foo2=bar2) : ", () {
      String path = hardCodedRequest.path;

      test("is not null", () {
        expect(path, isNotNull);
      });

      test("is /", () {
        expect(path, equals("/"));
      });
    });

    group("Request.headers: ", () {
      Map headers = hardCodedRequest.headers;

      test("is not null", () {
        expect(headers, isNotNull);
      });

      test("is not empty", () {
        expect(headers.isEmpty, isFalse);
      });

      test("is length 7", () {
        expect(headers.length, equals(7));
      });

      headers.forEach((k, v) {
        test("$k=$v", () {
          expect(headers[k], equals(v));
        });
      });
    });

    group("Request.host: ", () {
      String host = hardCodedRequest.host;

      test("is not null", () {
        expect(host, isNotNull);
      });

      test("is localhost:8080", () {
        expect(host, equals("localhost:8080"));
      });
    });

    group("Request.method: ", () {
      String method = hardCodedRequest.method;

      test("is not null", () {
        expect(method, isNotNull);
      });

      test("is Request.GET", () {
        expect(method, equals(Request.GET));
      });
    });

    group("Request.keepAlive: ", () {
      bool keepAlive = hardCodedRequest.keepAlive;

      test("is not null", () {
        expect(keepAlive, isNotNull);
      });

      test("is true", () {
        expect(keepAlive, isTrue);
      });
    });
  });

  group('mime tests', () {
    group('Request(/foo/bar/style.css).mimeType: ', () {
      var cssRequest = new Request.from(_CSSRequest());
      var mimeType = cssRequest.mimeType;

      test('is not null', () {
        expect(mimeType, isNotNull);
      });

      test('is text/css', () {
        expect(mimeType, equals('text/css'));
      });
    });

    group('Request(/foo/index.html).mimeType: ', () {
      var htmlRequest = new Request.from(_HTMLRequest());
      var mimeType = htmlRequest.mimeType;

      test('is not null', () {
        expect(mimeType, isNotNull);
      });

      test('is text/html', () {
        expect(mimeType, equals('text/html'));
      });
    });

    group('Request(/foo.jpg).mimeType: ', () {
      var jpgRequest = new Request.from(_JPGRequest());
      var mimeType = jpgRequest.mimeType;

      test('is not null', () {
        expect(mimeType, isNotNull);
      });

      test('is image/jpeg', () {
        expect(mimeType, equals('image/jpeg'));
      });
    });

    group('Request(/foo/bar.png).mimeType: ', () {
      var pngRequest = new Request.from(_PNGRequest());
      var mimeType = pngRequest.mimeType;

      test('is not null', () {
        expect(mimeType, isNotNull);
      });

      test('is image/png', () {
        expect(mimeType, equals('image/png'));
      });
    });

    group('Request(/foo.gif).mimeType: ', () {
      var gifRequest = new Request.from(_GIFRequest());
      var mimeType = gifRequest.mimeType;

      test('is not null', () {
        expect(mimeType, isNotNull);
      });

      test('is image/gif', () {
        expect(mimeType, equals('image/gif'));
      });
    });

    group('Request(/foo/bar.json).mimeType: ', () {
      var jsonRequest = new Request.from(_JSONRequest());
      var mimeType = jsonRequest.mimeType;

      test('is not null', () {
        expect(mimeType, isNotNull);
      });

      test('is application/json', () {
        expect(mimeType, equals('application/json'));
      });
    });
  });


}

/*
 * GET /?foo=bar&foo2=bar2 HTTP/1.1
 * Host: localhost:8080
 * Connection: keep-alive
 * Cache-Control: max-age=0
 * Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp
 * User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.67 (Dart) Safari/537.36
 * Accept-Encoding: gzip,deflate,sdch
 * Accept-Language: en-US,en;q=0.8
 */

chrome.ArrayBuffer _hardCodedHeader() {

  String rawHeaderString =
      """
	GET /?foo=bar&foo2=bar2 HTTP/1.1
	Host: localhost:8080
	Connection: keep-alive
	Cache-Control: max-age=0
	Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp
	User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.67 (Dart) Safari/537.36
	Accept-Encoding: gzip,deflate,sdch
	Accept-Language: en-US,en;q=0.8
	""";

  return new chrome.ArrayBuffer.fromString(rawHeaderString);
}

chrome.ArrayBuffer _CSSRequest() {
  String rawHeaderString =
      """
	GET /foo/bar/style.css HTTP/1.1
	Host: localhost:8080
	Connection: keep-alive
	Cache-Control: max-age=0
	Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp
	User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.67 (Dart) Safari/537.36
	Accept-Encoding: gzip,deflate,sdch
	Accept-Language: en-US,en;q=0.8
	""";

  return new chrome.ArrayBuffer.fromString(rawHeaderString);
}

chrome.ArrayBuffer _HTMLRequest() {
  String rawHeaderString =
      """
	GET /foo/index.html HTTP/1.1
	Host: localhost:8080
	Connection: keep-alive
	Cache-Control: max-age=0
	Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp
	User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.67 (Dart) Safari/537.36
	Accept-Encoding: gzip,deflate,sdch
	Accept-Language: en-US,en;q=0.8
	""";

  return new chrome.ArrayBuffer.fromString(rawHeaderString);
}

chrome.ArrayBuffer _JPGRequest() {
  String rawHeaderString =
      """
	GET /foo.jpg HTTP/1.1
	Host: localhost:8080
	Connection: keep-alive
	Cache-Control: max-age=0
	Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp
	User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.67 (Dart) Safari/537.36
	Accept-Encoding: gzip,deflate,sdch
	Accept-Language: en-US,en;q=0.8
	""";

  return new chrome.ArrayBuffer.fromString(rawHeaderString);
}

chrome.ArrayBuffer _PNGRequest() {
  String rawHeaderString =
      """
	GET /foo/bar.png HTTP/1.1
	Host: localhost:8080
	Connection: keep-alive
	Cache-Control: max-age=0
	Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp
	User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.67 (Dart) Safari/537.36
	Accept-Encoding: gzip,deflate,sdch
	Accept-Language: en-US,en;q=0.8
	""";

  return new chrome.ArrayBuffer.fromString(rawHeaderString);
}

chrome.ArrayBuffer _GIFRequest() {
  String rawHeaderString =
      """
	GET /foo.gif HTTP/1.1
	Host: localhost:8080
	Connection: keep-alive
	Cache-Control: max-age=0
	Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp
	User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.67 (Dart) Safari/537.36
	Accept-Encoding: gzip,deflate,sdch
	Accept-Language: en-US,en;q=0.8
	""";

  return new chrome.ArrayBuffer.fromString(rawHeaderString);
}

chrome.ArrayBuffer _JSONRequest() {
  String rawHeaderString =
      """
	GET /foo/bar.json HTTP/1.1
	Host: localhost:8080
	Connection: keep-alive
	Cache-Control: max-age=0
	Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp
	User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.67 (Dart) Safari/537.36
	Accept-Encoding: gzip,deflate,sdch
	Accept-Language: en-US,en;q=0.8
	""";

  return new chrome.ArrayBuffer.fromString(rawHeaderString);
}
