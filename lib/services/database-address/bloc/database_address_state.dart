part of 'database_address_bloc.dart';

sealed class DatabaseAddressState extends Equatable {
  const DatabaseAddressState();

  @override
  List<Object> get props => [];

  List<DatabaseAddress> get addresses => [];
}

final class DatabaseAddressInitial extends DatabaseAddressState {}

final class DatabaseAddressEmpty extends DatabaseAddressState {}

final class DatabaseAddressSelected extends DatabaseAddressState {
  const DatabaseAddressSelected({
    required this.address,
  });
  final DatabaseAddress address;

  @override
  List<Object> get props => [address];
}

class TotalBalanceCleared extends DatabaseAddressState {
  final String uniqueKey = UniqueKey().toString();

  @override
  List<Object> get props => [uniqueKey];
}

final class TotalBalanceUpdated extends DatabaseAddressState {
  const TotalBalanceUpdated({
    required this.balance,
  });
  final double balance;

  @override
  List<Object> get props => [balance];
}

final class AddressesLoaded extends DatabaseAddressState {
  const AddressesLoaded({
    required this.addresses,
  });
  @override
  final List<DatabaseAddress> addresses;

  @override
  List<Object> get props => [List.from(addresses)];
}

final class AddressBalancesLoaded extends DatabaseAddressState {
  const AddressBalancesLoaded({
    required this.addresses,
    required this.balance,
  });
  @override
  final List<DatabaseAddress> addresses;
  final double balance;

  @override
  List<Object> get props => [balance];
}

final class DatabaseAddressListEditable extends DatabaseAddressState {
  const DatabaseAddressListEditable({
    required this.isEditable,
    required this.addresses,
  });
  final bool isEditable;
  @override
  final List<DatabaseAddress> addresses;

  @override
  List<Object> get props => [isEditable, addresses];
}
