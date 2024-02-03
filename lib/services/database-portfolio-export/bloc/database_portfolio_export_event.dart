part of 'database_portfolio_export_bloc.dart';

sealed class DatabasePortfolioExportEvent extends Equatable {
  const DatabasePortfolioExportEvent();

  @override
  List<Object> get props => [];
}

final class ExportPortfolioInitial extends DatabasePortfolioExportEvent {}

final class ExportPortfolioJson extends DatabasePortfolioExportEvent {
  const ExportPortfolioJson();
}

final class ExportPortfolioJsonChunkFound extends DatabasePortfolioExportEvent {
  const ExportPortfolioJsonChunkFound(this.index);

  final int index;
}

final class ExportPortfolioJsonAllChunksFound extends DatabasePortfolioExportEvent {
  const ExportPortfolioJsonAllChunksFound();
}
