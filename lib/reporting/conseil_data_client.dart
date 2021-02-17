import 'package:tezster_dart/helper/http_helper.dart';

class ConseilDataClient {
  static executeEntityQuery(
      serverInfo, platform, network, entity, query) async {
    var url = '${serverInfo['url']}/v2/data/$platform/$network/$entity';
    // log.debug(`ConseilDataClient.executeEntityQuery request: ${url}, ${JSON.stringify(query)}`);
    var res = await HttpHelper.performPostRequest(url, '', query, headers: {
      'apiKey': serverInfo['apiKey'],
      // 'Content-Type': 'application/json',
      'cache': 'no-store',
    });
    return res;
    // .then((r) {
    //   if (!r.ok) {
    //     // log.error(`ConseilDataClient.executeEntityQuery request: ${url}, ${JSON.stringify(query)}, failed with ${r.statusText}(${r.status})`);
    //     throw new ConseilErrorTypes_1.ConseilRequestError(
    //         r.status, r.statusText, url, query);
    //   }
    //   return r;
    // })
    //   .then((r) {
    // var isJSONResponse = r.headers
    //     .get('content-type')
    //     .toLowerCase()
    //     .includes('application/json');
    // var response = isJSONResponse != null ? r.json() : r.text();
    // // log.debug(`ConseilDataClient.executeEntityQuery response: ${isJSONResponse ? JSON.stringify(response) : response}`);
    // return response;
    // });
  }
}
