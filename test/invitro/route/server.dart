import 'dart:io';

_sendNotFound(HttpResponse response) {
  response.statusCode = HttpStatus.NOT_FOUND;
  response.close();
}

startServer(String basePath, int port) {
  HttpServer.bind('127.0.0.1', port).then((server) {
    print("Listening on port $port");
    server.listen((HttpRequest request) {
      final String path = request.uri.toFilePath();
      // PENDING: Do more security checks here.
      final String resultPath = path == '/' ? '/index.html' : path;
      final File file = new File('${basePath}${resultPath}');
      file.exists().then((bool found) {
        if (found) {
          file.openRead()
              .pipe(request.response)
              .catchError((e) { });
        } else {
          _sendNotFound(request.response);
        }
      });
    });
  });
}

main(List<String> args) {
  // Compute base path for the request based on the location of the
  // script and then start the server.
  int port = args.isEmpty ? 8080 : int.parse(args[0], onError:(_)=> 8080);
  File script = new File(Platform.script.toFilePath());
  startServer(script.parent.path, port);
}