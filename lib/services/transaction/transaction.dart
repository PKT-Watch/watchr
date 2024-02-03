class AddressTransaction {
  String? txid;
  String? value;
  String? blockTime;
  String? firstSeen;
  String? counterparty;
  bool isFolding = false;
  bool isSend = false;
  bool isReceive = false;
  List<AddressTransactionInput> input = <AddressTransactionInput>[];
  List<AddressTransactionOutput> output = <AddressTransactionOutput>[];

  AddressTransaction({
    required this.txid,
    required this.value,
    required this.blockTime,
    required this.firstSeen,
    required this.input,
    required this.output,
  });

  AddressTransaction.fromJson(Map<String, dynamic> json, String address) {
    txid = json['txid'];
    value = '0';
    blockTime = json['blockTime'];
    firstSeen = json['firstSeen'];

    List<dynamic> inputs = json['input'];
    for (var element in inputs) {
      AddressTransactionInput inp = AddressTransactionInput.fromJson(element);
      input.add(inp);
    }
    List<dynamic> outputs = json['output'];
    for (var element in outputs) {
      AddressTransactionOutput out = AddressTransactionOutput.fromJson(element);
      output.add(out);
    }

    input.sort((a, b) => a.value.compareTo(b.value));
    output.sort((a, b) => a.value.compareTo(b.value));

    String direction = '';

    for (AddressTransactionInput inp in input) {
      if (inp.address == address) {
        value = inp.value;
        direction = '-';
        isSend = true;
      }
      counterparty = inp.address;
    }

    if (direction == '') {
      for (AddressTransactionOutput out in output) {
        if (out.address == address) {
          value = out.value;
          direction = '+';
          isReceive = true;
        }
      }
    } else {
      counterparty = '';
      for (AddressTransactionOutput out in output) {
        if (out.address == address) {
          // This is when we receive change back, we need to deduct from the
          // amount that we're spending to get the right sum.
          value = '${(int.parse(value!) - int.parse(out.value))}';
          if (output.length == 1) {
            counterparty = 'Folding';
            isFolding = true;
            isSend = false;
          }
          continue;
        }
        counterparty = out.address;
      }
    }
  }
}

class AddressTransactionInput {
  String address = '0';
  String value = '0';

  AddressTransactionInput.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    value = json['value'];
  }
}

class AddressTransactionOutput {
  String address = '0';
  String value = '0';

  AddressTransactionOutput.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    value = json['value'];
  }
}
