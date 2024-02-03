part of 'address_bloc.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object> get props => [];
}

final class FetchAddress extends AddressEvent {
  const FetchAddress(this.addressHash);

  final String addressHash;
}

final class FetchAddressMiningIncome extends AddressEvent {
  const FetchAddressMiningIncome(this.addressHash);

  final String addressHash;
}

final class FetchAddressTransactions extends AddressEvent {
  const FetchAddressTransactions(this.addressHash);

  final String addressHash;
}

final class UpdateAddressLabel extends AddressEvent {
  const UpdateAddressLabel(this.label);

  final String label;
}
