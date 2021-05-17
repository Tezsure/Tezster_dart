import 'dart:math';

class Estimate {
  // ignore: non_constant_identifier_names
  var MINIMAL_FEE_MUTEZ = 150;
  // ignore: non_constant_identifier_names
  var MINIMAL_FEE_PER_BYTE_MUTEZ = 1;
  // ignore: non_constant_identifier_names
  var MINIMAL_FEE_PER_GAS_MUTEZ = 0.1;
  // ignore: non_constant_identifier_names
  var GAS_BUFFER = 100;

  var _milligasLimit;
  var _storageLimit;
  var opSize;
  var minimalFeePerStorageByteMutez;
  var baseFeeMutez;

  Estimate(this._milligasLimit, this._storageLimit, this.opSize,
      this.minimalFeePerStorageByteMutez, this.baseFeeMutez);

  /// @description The number of Mutez that will be burned for the storage of the [operation](https://tezos.gitlab.io/user/glossary.html#operations). (Storage + Allocation fees)
  get burnFeeMutez {
    return this.roundUp(this.storageLimit * this.minimalFeePerStorageByteMutez);
  }

  /// @description  The limit on the amount of storage an [operation](https://tezos.gitlab.io/user/glossary.html#operations) can use.
  get storageLimit {
    var limit = max(int.parse(_storageLimit.toString()), 0);
    return limit > 0 ? limit : 0;
  }

  /// @description The limit on the amount of [gas](https://tezos.gitlab.io/user/glossary.html#gas) a given operation can consume.
  get gasLimit {
    return this.roundUp(this._milligasLimit / 1000 + this.GAS_BUFFER);
  }

  get operationFeeMutez {
    return ((this._milligasLimit / 1000 + this.GAS_BUFFER) *
                this.MINIMAL_FEE_PER_GAS_MUTEZ +
            this.opSize * this.MINIMAL_FEE_PER_BYTE_MUTEZ)
        .round();
  }

  roundUp(nanotez) {
    return nanotez.round();
  }

  /// @description Minimum fees for the [operation](https://tezos.gitlab.io/user/glossary.html#operations) according to [baker](https://tezos.gitlab.io/user/glossary.html#baker) defaults.
  get minimalFeeMutez {
    return this.roundUp(this.MINIMAL_FEE_MUTEZ + this.operationFeeMutez);
  }

  /// @description The suggested fee for the operation which includes minimal fees and a small buffer.
  get suggestedFeeMutez {
    return this.roundUp(this.operationFeeMutez + this.MINIMAL_FEE_MUTEZ * 2);
  }

  /// @description Fees according to your specified base fee will ensure that at least minimum fees are used.

  get usingBaseFeeMutez {
    return (max(
            int.parse(this.baseFeeMutez.toString()), this.MINIMAL_FEE_MUTEZ) +
        this.roundUp(this.operationFeeMutez));
  }

  /// @description The sum of `minimalFeeMutez` + `burnFeeMutez`.

  get totalCost {
    return int.parse(this.minimalFeeMutez.toString()) +
        int.parse(this.burnFeeMutez.toString());
  }

  /// @description Since Delphinet, consumed gas is provided in milligas for more precision.
  /// This function returns an estimation of the gas that operation will consume in milligas.
  get consumedMilligas {
    return int.parse(this._milligasLimit.toString());
  }
}
