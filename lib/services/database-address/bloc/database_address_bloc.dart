import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../address/address_balance.dart';
import '../../api/api.dart';
import '../database_address.dart';
import '../db_address_service.dart';
import '../../../utilities/tools/conversion.dart';

part 'database_address_event.dart';
part 'database_address_state.dart';

class DatabaseAddressBloc extends Bloc<DatabaseAddressEvent, DatabaseAddressState> {
  DatabaseAddressBloc({
    required DatabaseAddressService addressService,
  })  : _addressService = addressService,
        super(DatabaseAddressInitial()) {
    on<DatabaseAddressEmptyEvent>(_onDatabaseAddressEmptyEvent);
    on<SelectDatabaseAddress>(_onSelectDatabaseAddress);
    on<UpdateTotalBalance>(_onUpdateTotalBalance);
    on<ClearTotalBalance>(_onClearTotalBalance);
    on<LoadAddresses>(_onLoadAddresses);
    on<MakeDatabaseAddressListEditable>(_onMakeListEditable);
    on<LoadAddressBalances>(_onLoadAddressBalances);
  }

  final DatabaseAddressService _addressService;

  List<DatabaseAddress> addresses = [];

  void _onDatabaseAddressEmptyEvent(
    DatabaseAddressEmptyEvent event,
    Emitter<DatabaseAddressState> emit,
  ) {
    emit(DatabaseAddressEmpty());
  }

  void _onSelectDatabaseAddress(
    SelectDatabaseAddress event,
    Emitter<DatabaseAddressState> emit,
  ) {
    emit(DatabaseAddressSelected(address: event.address));
  }

  void _onUpdateTotalBalance(
    UpdateTotalBalance event,
    Emitter<DatabaseAddressState> emit,
  ) {
    emit(TotalBalanceUpdated(balance: event.balance));
  }

  void _onClearTotalBalance(
    ClearTotalBalance event,
    Emitter<DatabaseAddressState> emit,
  ) {
    emit(TotalBalanceCleared());
  }

  void _onLoadAddresses(
    LoadAddresses event,
    Emitter<DatabaseAddressState> emit,
  ) async {
    Iterable<DatabaseAddress> a = await _addressService.getAllAddresses(portfolioID: event.portfolioId);
    addresses = a.toList();
    emit(AddressBalancesLoaded(addresses: addresses, balance: 0.0));
    emit(AddressesLoaded(addresses: addresses.toList()));
  }

  void _onMakeListEditable(
    MakeDatabaseAddressListEditable event,
    Emitter<DatabaseAddressState> emit,
  ) {
    emit(DatabaseAddressListEditable(isEditable: event.isEditable, addresses: addresses));
  }

  void _onLoadAddressBalances(
    LoadAddressBalances event,
    Emitter<DatabaseAddressState> emit,
  ) async {
    double totalBalance = 0.0;

    // Clear the existing balance
    emit(AddressBalancesLoaded(addresses: addresses, balance: totalBalance));

    if (addresses.isEmpty) return;

    await API.getPrice();

    String query = '';
    String separator = '?';
    for (var i = 0; i < addresses.length; i++) {
      if (i > 0) separator = '&';
      query += '${separator}address=${addresses[i].address}';
    }

    final response = await API.makeRequest('/balance/$query');
    if (response.statusCode == 200) {
      dynamic res = json.decode(response.body);

      List<AddressBalance> balances = List<AddressBalance>.from(res.map((model) => AddressBalance.fromJson(model)));

      for (var address in addresses) {
        AddressBalance? balance = balances.where((item) => item.address == address.address).firstOrNull;
        if (balance != null) {
          address.isLoadingBalance = false;
          address.balance = PKTConversion.toPKT(balance.balance);
          totalBalance += address.balance;
        } else {
          address.isLoadingBalance = false;
          address.balance = 0;
        }
      }
    }

    emit(AddressBalancesLoaded(addresses: addresses, balance: totalBalance));
  }
}
