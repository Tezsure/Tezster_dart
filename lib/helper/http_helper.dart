import 'dart:convert';
import 'dart:io';

class HttpHelper {
  static Future<dynamic> performPostRequest(server, command, payload) async {
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request =
        await httpClient.postUrl(Uri.parse('$server/$command'));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(payload)));
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    return reply;
  }

  static Future<dynamic> performGetRequest(server, command) async {
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request =
        await httpClient.getUrl(Uri.parse('$server/$command'));
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    return jsonDecode(reply);
  }
}
