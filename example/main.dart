import 'package:chrome/chrome_app.dart' as chrome;
import 'package:chrome_server/server.dart';

import 'dart:html';
import 'dart:async';


void main() {
  var tcpServer = new TcpServer(addr: "127.0.0.1", port: 8080);
  tcpServer.listen().then((int port) {
    print("Listening on port $port");
    chrome.app.window.create('/index.html?port=$port').then((_) => _);
  });
}


