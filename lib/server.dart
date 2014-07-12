library chrome_server;

import 'package:chrome/chrome_app.dart' as chrome;
import 'package:mime/mime.dart';
import 'dart:async';
import 'dart:html';
import 'dart:typed_data';


part 'src/route.dart';

class TcpServer {
	String addr;
	int port;
	Map options;
	chrome.SocketProperties properties;
	int socketId;

	TcpServer({String addr, int port, Map options}) {
		this.addr = addr != null ? addr : "127.0.0.1";
		this.port = port != null ? port : _findOpenPort();
		this.options = options;
	}
	
	int _findOpenPort() {
		// For now returns 8080.  Possibly use chrome.sockets.tcp.connect to assess whether port is open.
		return 8080;
	}

	Future<int> listen() {
		
		Future createFtr = properties != null 
			? chrome.sockets.tcpServer.create(properties) 
			: chrome.sockets.tcpServer.create();

		return createFtr.then((chrome.CreateInfo createInfo){
	  		this.socketId = createInfo.socketId;

	  		return chrome.sockets.tcpServer.listen(createInfo.socketId, this.addr, this.port, 1000).then((int result){
	  			
	  			chrome.sockets.tcpServer.onAccept.listen((chrome.AcceptInfo acceptInfo){
		  			chrome.sockets.tcp.setPaused(acceptInfo.clientSocketId, false);
						chrome.sockets.tcp.onReceive.listen((chrome.ReceiveInfo receiveInfo){

							var clientSocketId = receiveInfo.socketId;
							var request = new Request.from(receiveInfo.data);
							var response = new Response();

							response.request = request;

							response.header.then((headerData) => send(clientSocketId, headerData))
							.then((_) => _);

							response.body.then((bodyData) => send(clientSocketId, bodyData))
							.then((_) => _);
						});
	  			});
	  			chrome.sockets.tcpServer.onAcceptError.listen(_acceptError);

	  			return new Future.value(this.port);

	  		});
		});

	}

	Future<int> send(int clientSocketId, chrome.ArrayBuffer dataToSend) {
		return chrome.sockets.tcp.send(clientSocketId, dataToSend).then((chrome.SendInfo sendInfo){
			return sendInfo.resultCode;
		});
	}

	Future close() {
		return chrome.sockets.tcpServer.close(this.socketId);
	}

	void _acceptError(chrome.AcceptErrorInfo info) {
		print("AcceptErrorInfo: resultCode: ${info.resultCode}");
	}
}