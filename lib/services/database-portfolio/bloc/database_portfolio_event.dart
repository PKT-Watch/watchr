part of 'database_portfolio_bloc.dart';

sealed class DatabasePortfolioEvent extends Equatable {
  const DatabasePortfolioEvent();

  @override
  List<Object> get props => [];
}

final class LoadPortfolios extends DatabasePortfolioEvent {
  const LoadPortfolios();
}

final class MakeListEditable extends DatabasePortfolioEvent {
  const MakeListEditable(this.isEditable);

  final bool isEditable;
}

final class SelectPortfolio extends DatabasePortfolioEvent {
  const SelectPortfolio(this.portfolioId);

  final int portfolioId;
}
