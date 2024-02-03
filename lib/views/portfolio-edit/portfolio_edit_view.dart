import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../helpers/arguments/create_update_portfolio_arguments.dart';
import '../../services/database-portfolio/bloc/database_portfolio_bloc.dart';
import '../../services/database-portfolio/database_portfolio.dart';
import '../../services/database-portfolio/db_portfolio_service.dart';
import '../../utilities/dialogs/cannot_delete_selected_portfolio_dialog.dart';
import '../../utilities/dialogs/delete_dialog.dart';
import '../../utilities/generics/get_arguments.dart';
import 'widgets/portfolio_edit_widget.dart';

class PortfolioEditView extends StatefulWidget {
  const PortfolioEditView({super.key});

  @override
  State<PortfolioEditView> createState() => _PortfolioEditViewState();
}

class _PortfolioEditViewState extends State<PortfolioEditView> {
  late final DatabasePortfolioService _portfolioDatabaseService;

  DatabasePortfolio? _portfolio;
  bool _isSelected = false;

  void _getExistingPortfolio() {
    final args = context.getArgument<CreateUpdatePortfolioArguments>();
    final widgetPortfolio = args?.portfolio;

    if (widgetPortfolio != null) {
      _portfolio = widgetPortfolio;
      _isSelected = args?.isSelected ?? false;
    }
  }

  @override
  void initState() {
    _portfolioDatabaseService = DatabasePortfolioService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _getExistingPortfolio();

    return Scaffold(
      appBar: AppBar(
        title: _portfolio != null ? const Text('Edit Portfolio') : const Text('New Portfolio'),
        centerTitle: true,
        actions: [
          _portfolio != null
              ? IconButton(
                  onPressed: () async {
                    if (_isSelected) {
                      showCannotDeleteSelectedPortfolioDialog(context);
                    } else {
                      final shouldDelete = await showDeleteDialog(context);

                      if (shouldDelete) {
                        await _portfolioDatabaseService.deletePortfolio(
                          id: _portfolio!.documentId,
                        );

                        if (context.mounted) {
                          context.read<DatabasePortfolioBloc>().add(const LoadPortfolios());
                          Navigator.pop(context);
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                )
              : const SizedBox(),
        ],
      ),
      backgroundColor: Colors.black,
      body: const PortfolioEditWidget(),
    );
  }
}
