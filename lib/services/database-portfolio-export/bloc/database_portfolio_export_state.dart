part of 'database_portfolio_export_bloc.dart';

sealed class DatabasePortfolioExportState extends Equatable {
  const DatabasePortfolioExportState();

  @override
  List<Object> get props => [];
}

final class DatabasePortfolioExportInitial extends DatabasePortfolioExportState {}

final class PortfolioJsonExported extends DatabasePortfolioExportState {
  const PortfolioJsonExported({
    required this.json,
  });
  final String json;

  @override
  List<Object> get props => [json];
}

final class PortfolioJsonExportChunkFound extends DatabasePortfolioExportState {
  const PortfolioJsonExportChunkFound({
    required this.index,
  });
  final int index;

  @override
  List<Object> get props => [index];
}

final class PortfolioJsonExportAllChunksFound extends DatabasePortfolioExportState {}
