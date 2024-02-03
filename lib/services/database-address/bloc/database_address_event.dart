part of 'database_address_bloc.dart';

sealed class DatabaseAddressEvent extends Equatable {
  const DatabaseAddressEvent();

  @override
  List<Object> get props => [];
}

final class DatabaseAddressEmptyEvent extends DatabaseAddressEvent {}

final class RefreshAddress extends DatabaseAddressEvent {}

final class ClearTotalBalance extends DatabaseAddressEvent {}

final class SelectDatabaseAddress extends DatabaseAddressEvent {
  const SelectDatabaseAddress(this.address);
  final DatabaseAddress address;

  @override
  List<Object> get props => [address];
}

final class UpdateTotalBalance extends DatabaseAddressEvent {
  const UpdateTotalBalance(this.balance);

  final double balance;

  @override
  List<Object> get props => [balance];
}

final class LoadAddresses extends DatabaseAddressEvent {
  const LoadAddresses(this.portfolioId);

  final int portfolioId;

  @override
  List<Object> get props => [portfolioId];
}

final class MakeDatabaseAddressListEditable extends DatabaseAddressEvent {
  const MakeDatabaseAddressListEditable(this.isEditable);

  final bool isEditable;

  @override
  List<Object> get props => [isEditable];
}

final class LoadAddressBalances extends DatabaseAddressEvent {
  const LoadAddressBalances();

  @override
  List<Object> get props => [];
}
