part of 'database_portfolio_bloc.dart';

sealed class DatabasePortfolioState extends Equatable {
  const DatabasePortfolioState();

  @override
  List<Object> get props => [];

  List<DatabasePortfolio> get portfolios => [];
}

final class PortfolioInitial extends DatabasePortfolioState {}

final class PortfoliosLoaded extends DatabasePortfolioState {
  const PortfoliosLoaded({
    required this.portfolios,
    required this.selectedPortfolioId,
  });
  @override
  final List<DatabasePortfolio> portfolios;

  final int selectedPortfolioId;

  @override
  List<Object> get props => [portfolios];
}

final class PortfolioListEditable extends DatabasePortfolioState {
  const PortfolioListEditable({
    required this.isEditable,
    required this.portfolios,
  });
  final bool isEditable;

  @override
  final List<DatabasePortfolio> portfolios;

  @override
  List<Object> get props => [isEditable, portfolios];
}

final class PortfolioSelected extends DatabasePortfolioState {
  const PortfolioSelected({
    required this.portfolio,
    required this.portfolios,
  });
  final DatabasePortfolio portfolio;

  @override
  final List<DatabasePortfolio> portfolios;

  @override
  List<Object> get props => [portfolio, portfolios];
}
