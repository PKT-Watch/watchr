import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../database-address/database_address.dart';
import '../../database-address/db_address_service.dart';
import '../../database-portfolio/database_portfolio.dart';
import '../../database-portfolio/db_portfolio_service.dart';

part 'database_portfolio_export_event.dart';
part 'database_portfolio_export_state.dart';

class DatabasePortfolioExportBloc extends Bloc<DatabasePortfolioExportEvent, DatabasePortfolioExportState> {
  DatabasePortfolioExportBloc({
    required DatabasePortfolioService portfolioService,
    required DatabaseAddressService addressService,
  })  : _portfolioService = portfolioService,
        _addressService = addressService,
        super(DatabasePortfolioExportInitial()) {
    on<ExportPortfolioInitial>(_onExportPortfolioInitial);
    on<ExportPortfolioJson>(_onExportPortfolioJson);
    on<ExportPortfolioJsonChunkFound>(_onExportPortfolioJsonChunkFound);
    on<ExportPortfolioJsonAllChunksFound>(_onExportPortfolioJsonAllChunksFound);
  }

  final DatabasePortfolioService _portfolioService;
  final DatabaseAddressService _addressService;

  void _onExportPortfolioInitial(
    ExportPortfolioInitial event,
    Emitter<DatabasePortfolioExportState> emit,
  ) {
    emit(DatabasePortfolioExportInitial());
  }

  void _onExportPortfolioJson(
    ExportPortfolioJson event,
    Emitter<DatabasePortfolioExportState> emit,
  ) async {
    Iterable<DatabasePortfolio> p = await _portfolioService.getAllPortfolios();
    List<DatabasePortfolio> pList = p.toList();
    for (var i = 0; i < pList.length; i++) {
      final Iterable<DatabaseAddress> addresses = await _addressService.getAllAddresses(portfolioID: pList[i].documentId);
      pList[i].addresses = addresses.toList();
    }
    final String exported = json.encode(pList);
    emit(PortfolioJsonExported(json: exported));
  }

  void _onExportPortfolioJsonChunkFound(
    ExportPortfolioJsonChunkFound event,
    Emitter<DatabasePortfolioExportState> emit,
  ) async {
    emit(PortfolioJsonExportChunkFound(index: event.index));
  }

  void _onExportPortfolioJsonAllChunksFound(
    ExportPortfolioJsonAllChunksFound event,
    Emitter<DatabasePortfolioExportState> emit,
  ) async {
    emit(PortfolioJsonExportAllChunksFound());
  }
}
