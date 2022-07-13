import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:tezster_dart/chain/tezos/tezos_node_writer.dart';
import 'package:tezster_dart/helper/constants.dart';
import 'package:tezster_dart/helper/http_helper.dart';
import 'package:tezster_dart/models/operation_model.dart';
import 'dart:math' as math;

class FeeEstimater {
  String server;
  String chainId;
  List<OperationModel> operations;

  FeeEstimater(this.server, this.operations, {this.chainId = 'main'});

  Future<Map<String, dynamic>> getEstimateOperationGroup() async {
    var operationResources = [];

    for (var i = 0; i < operations.length; i++) {
      var priorConsumedResources = {'gas': 0, 'storageCost': 0};

      if (i > 0) {
        var priorTransactions = operations.sublist(0, i);
        priorConsumedResources =
            await estimateOperation(server, chainId, priorTransactions);
      }
      var currentTransactions = operations.sublist(0, i + 1);
      var currentConsumedResources =
          await estimateOperation(server, chainId, currentTransactions);

      var gasLimitDelta =
          currentConsumedResources['gas'] - priorConsumedResources['gas'];
      var storageLimitDelta = currentConsumedResources['storageCost'] -
          priorConsumedResources['storageCost'];

      operationResources.add({
        'gas': gasLimitDelta + TezosConstants.GasLimitPadding,
        'storageCost': storageLimitDelta + TezosConstants.StorageLimitPadding
      });
    }

    var staticFee =
        (operations.where((o) => o.kind == 'reveal').toList().length == 1)
            ? 1270
            : 0;

    var validBranch = 'BMLxA4tQjiu1PT2x3dMiijgvMTQo8AVxkPBPpdtM8hCfiyiC1jz';
    var gasLimitTotal =
        operationResources.map((r) => r['gas']).fold<int>(0, (a, c) => a + c);
    var storageLimitTotal = operationResources
        .map((r) => r['storageCost'])
        .fold<int>(0, (a, c) => a + c);
    var forgedOperationGroup =
        TezosNodeWriter.forgeOperations(validBranch, operations);
    var groupSize = forgedOperationGroup.length / 2 + 64;
    var estimatedFee = staticFee +
        (gasLimitTotal ~/ 10) +
        TezosConstants.BaseOperationFee +
        groupSize +
        TezosConstants.DefaultBakerVig;
    var estimatedStorageBurn = double.parse(
            (storageLimitTotal * TezosConstants.StorageRate).toString())
        .ceil();

    if (num.parse(operations[0].fee) < estimatedFee) {
      estimatedFee += 16;
    }

    debugPrint('group estimate' +
        operationResources.toString() +
        '' +
        estimatedFee.toString() +
        '' +
        estimatedStorageBurn.toString());

    return {
      'operationResources': operationResources,
      'estimatedFee': estimatedFee.ceil(),
      'estimatedStorageBurn': estimatedStorageBurn
    };
  }

  estimateOperation(String server, String chainId,
      List<OperationModel> priorTransactions) async {
    var naiveOperationGasCap = math
        .min((TezosConstants.BlockGasCap / operations.length).floor(),
            TezosConstants.OperationGasCap)
        .toString();

    var localOperations = [...operations]
        .map((e) => e
          ..gasLimit = int.parse(naiveOperationGasCap)
          ..storageLimit = TezosConstants.OperationStorageCap)
        .toList();

    var responseJSON = await dryRunOperation(server, chainId, localOperations);

    var gas = 0;
    var storageCost = 0;
    var staticFee = 0;
    for (var ele in responseJSON['contents']) {
      try {
        gas += int.parse(ele['metadata']['operation_result']['consumed_gas']
                .toString()) ??
            0;
        storageCost += int.parse(ele['metadata']['operation_result']
                    ['paid_storage_size_diff']
                .toString()) ??
            0;

        if (ele['kind'] == 'origination' ||
            ele['metadata']['operation_result']
                ['allocated_destination_contract']) {
          storageCost += TezosConstants.EmptyAccountStorageBurn;
        } else if (ele['kind'] == 'reveal') {
          staticFee += 1270;
        }
      } catch (e) {
        debugPrint(e.toString());
      }

      var internalOperations = ele['metadata']['internal_operation_results'];
      if (internalOperations == null) {
        continue;
      }

      for (var internalOperation in internalOperations) {
        var result = internalOperation['result'];
        gas += int.parse(result['consumed_gas']) ?? 0;
        storageCost += int.parse(result['paid_storage_size_diff']) ?? 0;
        if (internalOperation['kind'] == 'origination') {
          storageCost += TezosConstants.EmptyAccountStorageBurn;
        }
      }
    }

    var validBranch = 'BMLxA4tQjiu1PT2x3dMiijgvMTQo8AVxkPBPpdtM8hCfiyiC1jz';
    var forgedOperationGroup =
        TezosNodeWriter.forgeOperations(validBranch, operations);
    var operationSize = forgedOperationGroup.length / 2 + 64;
    var estimatedFee = staticFee +
        (gas / 10).ceil() +
        TezosConstants.BaseOperationFee +
        operationSize +
        TezosConstants.DefaultBakerVig;
    var estimatedStorageBurn =
        (storageCost * TezosConstants.StorageRate).ceil();
    debugPrint(
        'TezosNodeWriter.estimateOperation; gas: $gas, storage: $storageCost, fee estimate: $estimatedFee, burn estimate: $estimatedStorageBurn');

    return {
      'gas': gas,
      'storageCost': storageCost,
      'estimatedFee': estimatedFee,
      'estimatedStorageBurn': estimatedStorageBurn
    };
  }

  dryRunOperation(String server, String chainId,
      List<OperationModel> localOperations) async {
    const fake_signature =
        'edsigu6xFLH2NpJ1VcYshpjW99Yc1TAL1m2XBqJyXrxcZQgBMo8sszw2zm626yjpA3pWMhjpsahLrWdmvX9cqhd4ZEUchuBuFYy';
    const fake_branch = 'BL94i2ShahPx3BoNs6tJdXDdGeoJ9ukwujUA2P8WJwULYNdimmq';
    var payload = {
      'operation': {
        'branch': fake_branch,
        'contents': operations,
        'signature': fake_signature
      }
    };
    var response = await HttpHelper.performPostRequest(
        server, 'chains/$chainId/blocks/head/helpers/scripts/run_operation', {
      'chain_id': 'NetXdQprcVkpaWU',
      ...payload,
    });

    TezosNodeWriter.parseRPCError(jsonDecode(response.toString()));

    return jsonDecode(response.toString());
  }
}
