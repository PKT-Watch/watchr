part of 'address_bloc.dart';

sealed class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object> get props => [];
}

final class AddressInitial extends AddressState {}

final class AddressFetched extends AddressState {
  const AddressFetched({
    required this.address,
  });
  final Address address;

  @override
  List<Object> get props => [address];
}

final class AddressMiningIncomeLoading extends AddressState {}

final class AddressMiningIncomeFetched extends AddressState {
  const AddressMiningIncomeFetched({
    required this.miningIncome,
  });
  final List<int> miningIncome;

  @override
  List<Object> get props => [miningIncome];
}

final class AddressTransactionsLoading extends AddressState {}

final class AddressTransactionsFetched extends AddressState {
  const AddressTransactionsFetched({
    required this.transactions,
  });
  final List<AddressTransaction> transactions;

  @override
  List<Object> get props => [transactions];
}

final class AddressLabelUpdated extends AddressState {
  const AddressLabelUpdated({
    required this.label,
  });
  final String label;

  @override
  List<Object> get props => [label];
}
