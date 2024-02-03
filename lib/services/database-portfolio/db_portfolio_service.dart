import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/preference_keys.dart';
import 'database_portfolio.dart';
import '../../constants/db_storage_constants.dart';
import '../crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class DatabasePortfolioService {
  Database? _db;

  List<DatabasePortfolio> _portfolios = [];

  static final DatabasePortfolioService _shared = DatabasePortfolioService._sharedInstance();
  DatabasePortfolioService._sharedInstance() {
    _portfoliosStreamController = StreamController<List<DatabasePortfolio>>.broadcast(
      onListen: () {
        _portfoliosStreamController.sink.add(_portfolios);
      },
    );
  }
  factory DatabasePortfolioService() => _shared;

  late final StreamController<Iterable<DatabasePortfolio>> _portfoliosStreamController;

  Stream<Iterable<DatabasePortfolio>> get allPortfolios {
    _cachePortfolios();
    return _portfoliosStreamController.stream;
  }

  Future<void> _cachePortfolios() async {
    final allPortfolios = await getAllPortfolios();
    _portfolios = allPortfolios.toList();
    _portfoliosStreamController.add(_portfolios);
  }

  Future<DatabasePortfolio> updatePortfolio({
    required int documentId,
    required String label,
    required int displayOrder,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // Make sure portfolio exists
    await getPortfolio(id: documentId);

    // Update db
    final updatesCount = await db.update(
      portfolioTable,
      {
        labelColumn: label,
        displayOrderColumn: displayOrder,
      },
      where: 'document_id = ?',
      whereArgs: [documentId],
    );

    if (updatesCount == 0) {
      throw CouldNotUpdatePortfolio();
    }

    final updatedPortfolio = await getPortfolio(id: documentId);
    _portfolios.removeWhere((portfolio) => portfolio.documentId == updatedPortfolio.documentId);
    _portfolios.add(updatedPortfolio);
    _portfoliosStreamController.add(_portfolios);
    return updatedPortfolio;
  }

  Future<Iterable<DatabasePortfolio>> getAllPortfolios() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final portfolios = await db.query(
      portfolioTable,
      orderBy: "display_order ASC",
    );

    return portfolios.map((portfolioRow) => DatabasePortfolio.fromRow(portfolioRow));
  }

  Future<DatabasePortfolio> getPortfolio({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      portfolioTable,
      limit: 1,
      where: 'document_id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) {
      throw CouldNotFindPortfolio();
    }
    final portfolio = DatabasePortfolio.fromRow(results.first);

    _portfolios.removeWhere((portfolio) => portfolio.documentId == id);
    _portfolios.add(portfolio);
    _portfoliosStreamController.add(_portfolios);

    return portfolio;
  }

  Future<int> deleteAllPortfolios() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(portfolioTable);

    _portfolios = [];
    _portfoliosStreamController.add(_portfolios);

    return numberOfDeletions;
  }

  Future<void> deletePortfolio({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      portfolioTable,
      where: 'document_id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeletePortfolio();
    }

    _portfolios.removeWhere((portfolio) => portfolio.documentId == id);
    _portfoliosStreamController.add(_portfolios);
  }

  Future<DatabasePortfolio> createPortfolio({required String label, int displayOrder = 0}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // Create the portfolio
    final portfolioId = await db.insert(
      portfolioTable,
      {
        labelColumn: label,
        displayOrderColumn: displayOrder,
        createdAtColumn: DateTime.now().millisecondsSinceEpoch,
      },
    );

    final portfolio = DatabasePortfolio(
      documentId: portfolioId,
      label: label,
      displayOrder: displayOrder,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      ownerUserId: '',
    );

    _portfolios.add(portfolio);
    _portfoliosStreamController.add(_portfolios);

    return portfolio;
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    }

    return db;
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpen {
      //
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpen();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      await db.execute(createPortfolioTable);
      await db.execute(createAddressTable);
      await _cachePortfolios();

      if (_portfolios.isEmpty) {
        DatabasePortfolio defaultPortfolio = await createPortfolio(label: 'Main Portfolio');

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt(selectedPortfolioIdKey, defaultPortfolio.documentId);
        prefs.setString(selectedPortfolioNameKey, 'Main Portfolio');
      }
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}
