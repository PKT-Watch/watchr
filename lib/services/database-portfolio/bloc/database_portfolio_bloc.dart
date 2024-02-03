import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/preference_keys.dart';
import '../database_portfolio.dart';
import '../db_portfolio_service.dart';

part 'database_portfolio_event.dart';
part 'database_portfolio_state.dart';

class DatabasePortfolioBloc extends Bloc<DatabasePortfolioEvent, DatabasePortfolioState> {
  DatabasePortfolioBloc({
    required DatabasePortfolioService portfolioService,
  })  : _portfolioService = portfolioService,
        super(PortfolioInitial()) {
    on<LoadPortfolios>(_onLoadPortfolios);
    on<MakeListEditable>(_onMakeListEditable);
    on<SelectPortfolio>(_onSelectPortfolio);
  }

  final DatabasePortfolioService _portfolioService;

  List<DatabasePortfolio> portfolios = [];

  void _onLoadPortfolios(
    LoadPortfolios event,
    Emitter<DatabasePortfolioState> emit,
  ) async {
    Iterable<DatabasePortfolio> p = await _portfolioService.getAllPortfolios();
    portfolios = p.toList();

    int selectedPortfolioId = await _getSelectedPortfolioId();

    emit(PortfoliosLoaded(portfolios: portfolios, selectedPortfolioId: selectedPortfolioId));
  }

  void _onMakeListEditable(
    MakeListEditable event,
    Emitter<DatabasePortfolioState> emit,
  ) {
    emit(PortfolioListEditable(isEditable: event.isEditable, portfolios: portfolios));
  }

  void _onSelectPortfolio(
    SelectPortfolio event,
    Emitter<DatabasePortfolioState> emit,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DatabasePortfolio portfolio = await _portfolioService.getPortfolio(id: event.portfolioId);

    await prefs.setInt(selectedPortfolioIdKey, portfolio.documentId);
    await prefs.setString(selectedPortfolioNameKey, portfolio.label);

    emit(PortfolioSelected(portfolio: portfolio, portfolios: portfolios));
  }

  Future<int> _getSelectedPortfolioId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(selectedPortfolioIdKey) ?? -1;
  }
}
