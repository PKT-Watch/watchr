import 'database_address.dart';

class DatabaseAddressList {
  final List<DatabaseAddress> addresses;

  const DatabaseAddressList({
    required this.addresses,
  });

  static const empty = DatabaseAddressList(addresses: []);

  DatabaseAddressList.fromJson(Map<String, dynamic> json) : addresses = json['addresses'];
}
