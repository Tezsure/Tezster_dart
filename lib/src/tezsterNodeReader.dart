import 'dart:convert';

import 'package:http/http.dart' as http;

class TezsterNodeReader {
  static dynamic performGetRequest({
    String server,
    String command = "",
  }) async {
    assert(server != null);
    String url = "$server/$command";
    http.Response response = await http.get(url);
    if (response.statusCode != 200) {
      return "Invalid URL";
    }
    dynamic data = jsonDecode(response.body);
    return data;
  }

  static dynamic getBlock({
    String server,
    String hash = "head",
    String chainid = "main",
  }) async {
    assert(server != null);
    dynamic response = await performGetRequest(
      server: server,
      command: "chains/$chainid/blocks/$hash",
    );

    // print(response['hash']);
    return response;
  }

  static Future<dynamic> getBlockHead({
    String server,
  }) async {
    assert(server != null);
    dynamic response = await getBlock(server: server);
    return response;
  }

  static dynamic getAccountForBlock({
    String server,
    String blockHash,
    String accountHash,
    String chainid = "main",
  }) {
    dynamic response = performGetRequest(
      server: server,
      command:
          "chains/$chainid/blocks/$blockHash/context/contracts/$accountHash",
    );
    return response;
  }

  static dynamic getCounterForAccount({
    String server,
    String accountHash,
    String chainid = "main",
  }) async {
    dynamic counter = await performGetRequest(
      server: server,
      command:
          "chains/$chainid/blocks/head/context/contracts/$accountHash/counter",
    );
    return int.parse(counter, radix: 10);
  }

  static dynamic getSpendableBalanceForAccount({
    String server,
    String accountHash,
    String chainid = "main",
  }) async {
    dynamic account = await performGetRequest(
      server: server,
      command: "chains/$chainid/blocks/head/context/contracts/$accountHash",
    );
    return int.parse(account["balance"], radix: 10);
  }

  /// Testing is Done [getAccountManagerForBlock]
  static dynamic getAccountManagerForBlock({
    String server,
    String block,
    String accountHash,
    String chainid = "main",
  }) async {
    try {
      dynamic result = await performGetRequest(
        server: server,
        command:
            "chains/$chainid/blocks/$block/context/contracts/$accountHash/manager_key",
      );
      if (result.toString() == null) {
        return "";
      }
      return result.toString();
    } catch (e) {
      throw (e);
    }
  }

  static dynamic isImplicitAndEmpty({
    String server,
    String accountHash,
  }) async {
    dynamic account = await getAccountForBlock(
      server: server,
      blockHash: "head",
      accountHash: accountHash,
    );
    bool isImplicit = accountHash.toLowerCase().startsWith("tz");
    bool isEmpty = account.balance == 0;

    if (isImplicit && isEmpty)
      return true;
    else
      return false;
  }

  /// Testing done [isManagerKeyRevealedForAccount]
  static Future<bool> isManagerKeyRevealedForAccount({
    String server,
    String accountHash,
  }) async {
    bool isRevealed;
    String managerKey = await getAccountManagerForBlock(
      server: server,
      block: "head",
      accountHash: accountHash,
    );
    managerKey == null ? isRevealed = false : isRevealed = true;

    return isRevealed;
    // return managerKey.length > 0 ? true : false;
  }

  static dynamic getContractStorage({
    String server,
    String accountHash,
    String chainid = "main",
    String block = "head",
  }) async {
    dynamic response = performGetRequest(
      server: server,
      command:
          "chains/$chainid/blocks/$block/context/contracts/$accountHash/storage",
    );
    return response;
  }

  static dynamic getValueForBigMapKey({
    String server,
    num index,
    String key,
    String block = "main",
    String chainid = "head",
  }) async {
    dynamic response = performGetRequest(
      server: server,
      command: "chains/$chainid/blocks/$block/context/big_maps/$index/$key",
    );
    return response;
  }

  static dynamic getMempoolOperation({
    String server,
    String operationGroupId,
    String chainid = "main",
  }) async {
    dynamic mempoolContent = await performGetRequest(
      server: server,
      command: "chains/$chainid/mempool/pending_operations",
    );
    List applied = mempoolContent["applied"];
    print("applied ===> $applied");
    dynamic response;
    applied.forEach((data) {
      if (data["hash"] == operationGroupId) {
        response = data;
      } else {
        response = "Hash not found";
      }
    });
    return response;
  }

  static dynamic getMempoolOperationsForAccount({
    String server,
    String accountHash,
    String chainid = "main",
  }) async {
    dynamic mempoolContent = await performGetRequest(
      server: server,
      command: "chains/$chainid/mempool/pending_operations",
    );
    List<Object> data = [];
    dynamic applied = mempoolContent["applied"];
    applied.forEach((g) {
      if (g["contents"][0]["source"] == accountHash ||
          g["contents"][0]["destination"] == accountHash) {
        //print("G ===> ${g["contents"]}");
        data.insertAll(0, g["contents"]);
      }
    });
    return data;
  }

  static dynamic getBalance({
    String server,
    String accountHash,
  }) async {
    dynamic balance = performGetRequest(
      server: server,
      command: "chains/main/blocks/head/context/contracts/$accountHash/balance",
    );
    return balance;
  }
}
