import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../database-portfolio/db_portfolio_service.dart';
import 'package:http/http.dart' as http;
import '../../../globals/globals.dart' as globals;

part 'database_event.dart';
part 'database_state.dart';

class DatabaseBloc extends Bloc<DatabaseEvent, DatabaseState> {
  DatabaseBloc({required DatabasePortfolioService portfolioService})
      : _portfolioService = portfolioService,
        super(DatabaseUninitialised()) {
    on<DatabaseInitialize>(_onDatabaseInitialize);
  }

  final DatabasePortfolioService _portfolioService;

  Future<void> _onDatabaseInitialize(
    DatabaseInitialize event,
    Emitter<DatabaseState> emit,
  ) async {
    await _portfolioService.open();

    final response = await http.get(Uri.parse('https://api.pkt.watch/v1/network/price'));
    if (response.statusCode == 200) {
      globals.pricePkt = json.decode(response.body)['pkt'];
    }
    emit(DatabaseInitialised());
  }
}
