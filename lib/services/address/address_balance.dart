class AddressBalance {
  const AddressBalance(this.address, this.balance);
  final String address;
  final String balance;

  AddressBalance.fromJson(Map<String, dynamic> json)
      : address = json['address'],
        balance = json['balance'];
}
