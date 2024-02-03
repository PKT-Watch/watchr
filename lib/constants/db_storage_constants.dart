const dbName = 'watchr.db';
const addressTable = 'address';
const portfolioTable = 'portfolio';

// Shared
const idColumn = 'document_id';
const labelColumn = 'label';
const createdAtColumn = 'created_at';
const displayOrderColumn = 'display_order';

// Address
const portfolioIDColumn = 'portfolio_id';
const addressColumn = 'address';

const createAddressTable = '''CREATE TABLE IF NOT EXISTS "address" (
          "document_id"	INTEGER NOT NULL,
          "address"	TEXT NOT NULL,
          "label" TEXT NOT NULL,
          "portfolio_id" INTEGER NOT NULL,
          "display_order" INTEGER NOT NULL,
          "created_at" INTEGER NOT NULL,
          PRIMARY KEY("document_id" AUTOINCREMENT)
        );''';
const createPortfolioTable = '''CREATE TABLE IF NOT EXISTS "portfolio" (
          "document_id"	INTEGER NOT NULL,
          "label" TEXT NOT NULL,
          "display_order" INTEGER NOT NULL,
          "created_at" INTEGER NOT NULL,
          PRIMARY KEY("document_id" AUTOINCREMENT)
        );''';
