import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../address.dart';
import '../../api/api.dart';
import '../../transaction/transaction.dart';

part 'address_event.dart';
part 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  AddressBloc() : super(AddressInitial()) {
    on<FetchAddress>(_onFetchAddress);
    on<FetchAddressMiningIncome>(_onFetchAddressMiningIncome);
    on<FetchAddressTransactions>(_onFetchAddressTransactions);
    on<UpdateAddressLabel>(_onUpdateAddressLabel);
  }

  void _onFetchAddress(
    FetchAddress event,
    Emitter<AddressState> emit,
  ) async {
    // Emit an empty address so we can set the initial state of the address details view
    if (event.addressHash == '') {
      emit(AddressFetched(address: Address()));
      return;
    }

    final response = await API.makeRequest('/address/${event.addressHash}');

    if (response.statusCode == 200) {
      Address address = Address.fromJson(json.decode(response.body));
      emit(AddressFetched(address: address));
    }
  }

  void _onFetchAddressMiningIncome(
    FetchAddressMiningIncome event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressMiningIncomeLoading());

    final response = await API.makeRequest('/address/${event.addressHash}/income/30?mining=only');

    if (response.statusCode == 200) {
      List<dynamic> results = json.decode(response.body)['results'];

      int largestValue = 0;
      List<int> miningIncome = [];

      for (var element in results.reversed) {
        int mined = int.parse(element["received"]);
        if (mined > largestValue) {
          largestValue = mined;
        }
        miningIncome.add(mined);
      }

      emit(AddressMiningIncomeFetched(miningIncome: miningIncome));
    }
  }

  void _onFetchAddressTransactions(
    FetchAddressTransactions event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressTransactionsLoading());

    final response = await API.makeRequest('/address/${event.addressHash}/coins/50/1/?mining=excluded');

    if (response.statusCode == 200) {
      List<dynamic> results = json.decode(response.body)['results'];
      List<AddressTransaction> transactions = <AddressTransaction>[];

      for (var element in results) {
        AddressTransaction trans = AddressTransaction.fromJson(element, event.addressHash);
        transactions.add(trans);
      }

      emit(AddressTransactionsFetched(transactions: transactions));
    }
  }

  void _onUpdateAddressLabel(
    UpdateAddressLabel event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLabelUpdated(label: event.label));
  }
}
