import '../../services/database-portfolio/database_portfolio.dart';

class CreateUpdatePortfolioArguments {
  final DatabasePortfolio portfolio;
  final bool isSelected;

  CreateUpdatePortfolioArguments(this.portfolio, this.isSelected);
}
