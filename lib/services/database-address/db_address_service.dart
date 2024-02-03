import 'dart:async';
import 'database_address.dart';
import '../../constants/db_storage_constants.dart';
import '../crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class DatabaseAddressService {
  Database? _db;

  List<DatabaseAddress> _addresses = [];

  static final DatabaseAddressService _shared = DatabaseAddressService._sharedInstance();
  DatabaseAddressService._sharedInstance();
  factory DatabaseAddressService() => _shared;

  Future<void> _cacheAddresses({required int portfolioID}) async {
    final allAddresses = await getAllAddresses(portfolioID: portfolioID);
    _addresses = allAddresses.toList();
  }

  Future<DatabaseAddress> updateAddress({
    required String documentId,
    required String address,
    required String label,
    required int portfolioID,
    required int displayOrder,
    int balance = -1,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // Make sure address exists
    await getAddress(id: documentId);

    // Update db
    final updatesCount = await db.update(
      addressTable,
      {
        addressColumn: address,
        labelColumn: label,
        portfolioIDColumn: portfolioID,
        displayOrderColumn: displayOrder,
      },
      where: 'document_id = ?',
      whereArgs: [documentId],
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateAddress();
    }

    final updatedAddress = await getAddress(id: documentId);
    _addresses.removeWhere((address) => address.documentId == updatedAddress.documentId);
    _addresses.add(updatedAddress);
    return updatedAddress;
  }

  Future<Iterable<DatabaseAddress>> getAllAddresses({required int portfolioID}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final addresses = await db.query(
      addressTable,
      where: 'portfolio_id = ?',
      whereArgs: [portfolioID],
      orderBy: "display_order ASC",
    );

    return addresses.map((addressRow) => DatabaseAddress.fromRow(addressRow));
  }

  Future<DatabaseAddress> getAddress({required String id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      addressTable,
      limit: 1,
      where: 'document_id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) {
      throw CouldNotFindAddress();
    }
    final address = DatabaseAddress.fromRow(results.first);

    _addresses.removeWhere((address) => address.documentId == id);
    _addresses.add(address);

    return address;
  }

  Future<DatabaseAddress?> getAddressBy({required String address, required int portfolioId}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      addressTable,
      limit: 1,
      where: 'address = ? AND portfolio_id = ?',
      whereArgs: [address, portfolioId],
    );
    if (results.isNotEmpty) {
      final foundAddress = DatabaseAddress.fromRow(results.first);
      return foundAddress;
    }
    return null;
  }

  Future<int> deleteAllAddresses() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(addressTable);

    _addresses = [];

    return numberOfDeletions;
  }

  Future<void> deleteAddress({
    required String documentId,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      addressTable,
      where: 'document_id = ?',
      whereArgs: [documentId],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteAddress();
    }

    _addresses.removeWhere((address) => address.documentId == documentId);
  }

  Future<DatabaseAddress> createAddress(
      {required String label, required String address, required int portfolioID, bool addToStream = true, int displayOrder = 0}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // Check if address already exists
    DatabaseAddress? existingAddress = await getAddressBy(address: address, portfolioId: portfolioID);
    if (existingAddress != null) {
      throw AddressExists();
    }

    // Create the address
    final addressId = await db.insert(
      addressTable,
      {
        addressColumn: address,
        labelColumn: label,
        portfolioIDColumn: portfolioID,
        displayOrderColumn: displayOrder,
        createdAtColumn: DateTime.now().millisecondsSinceEpoch,
      },
    );

    final dbAddress = DatabaseAddress(
      documentId: '$addressId',
      address: address,
      label: label,
      portfolioID: portfolioID,
      displayOrder: displayOrder,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      ownerUserId: '',
    );

    if (addToStream) {
      _addresses.add(dbAddress);
    }

    return dbAddress;
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
      const selectedPortfolioID = 1;
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      await db.execute(createPortfolioTable);
      await db.execute(createAddressTable);
      await _cacheAddresses(portfolioID: selectedPortfolioID);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}
