class Address {
  String unconfirmedReceived = '0';
  String confirmedReceived = '0';
  String balance = '0';
  String spending = '0';
  String spent = '0';
  String burned = '0';
  int recvCount = 0;
  int mineCount = 0;
  int spentCount = 0;
  int balanceCount = 0;
  String mined24 = '0';
  String address = '';

  Address({
    this.unconfirmedReceived = '0',
    this.confirmedReceived = '0',
    this.balance = '0',
    this.spending = '0',
    this.spent = '0',
    this.burned = '0',
    this.recvCount = 0,
    this.mineCount = 0,
    this.spentCount = 0,
    this.balanceCount = 0,
    this.mined24 = '0',
    this.address = '',
  });

  Address.fromJson(Map<String, dynamic> json) {
    unconfirmedReceived = json['unconfirmedReceived'];
    confirmedReceived = json['confirmedReceived'];
    balance = json['balance'];
    spending = json['spending'];
    spent = json['spent'];
    burned = json['burned'];
    recvCount = json['recvCount'];
    mineCount = json['mineCount'];
    spentCount = json['spentCount'];
    balanceCount = json['balanceCount'];
    mined24 = json['mined24'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['unconfirmedReceived'] = unconfirmedReceived;
    data['confirmedReceived'] = confirmedReceived;
    data['balance'] = balance;
    data['spending'] = spending;
    data['spent'] = spent;
    data['burned'] = burned;
    data['recvCount'] = recvCount;
    data['mineCount'] = mineCount;
    data['spentCount'] = spentCount;
    data['balanceCount'] = balanceCount;
    data['mined24'] = mined24;
    data['address'] = address;
    return data;
  }

  Map<String, dynamic> toMap() {
    return {
      'unconfirmedReceived': unconfirmedReceived,
      'confirmedReceived': confirmedReceived,
      'balance': balance,
      'spending': spending,
      'spent': spent,
      'burned': burned,
      'recvCount': recvCount,
      'mineCount': mineCount,
      'spentCount': spentCount,
      'balanceCount': balanceCount,
      'mined24': mined24,
      'address': address,
    };
  }

  // Implement toString to make it easier to see information about
  // each address when using the print statement.
  @override
  String toString() {
    return '''Address{
        address: $address,
        unconfirmedReceived: $unconfirmedReceived, confirmedReceived: $confirmedReceived, balance: $balance,
        spending: $spending, spent: $spent, burned: $burned, recvCount: $recvCount, mineCount: $mineCount,
        spentCount: $spentCount, balanceCount: $balanceCount, mined24: $mined24
      }''';
  }
}
