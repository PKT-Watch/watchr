import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../enums/form_color_mode.dart';
import '../../helpers/arguments/create_update_portfolio_arguments.dart';
import '../../services/database-portfolio/bloc/database_portfolio_bloc.dart';
import '../../services/database-portfolio/db_portfolio_service.dart';
import 'cannot_delete_selected_portfolio_dialog.dart';
import 'delete_dialog.dart';
import '../../views/portfolio-edit/widgets/portfolio_edit_widget.dart';

Future<void> showAddPortfolioDialog(BuildContext context, [CreateUpdatePortfolioArguments? arguments]) {
  final DatabasePortfolioService portfolioDatabaseService = DatabasePortfolioService();

  return showGeneralDialog(
    barrierColor: Colors.black.withOpacity(0.5),
    transitionBuilder: (context, a1, a2, widget) {
      return Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: Dialog(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(8.0),
              ),
              width: 600,
              height: 340,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Color(0xffff007a)),
                        ),
                      ),
                      Expanded(
                        child: arguments?.portfolio != null
                            ? const Text(
                                'Edit Portfolio',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                              )
                            : const Text(
                                'New Portfolio',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                              ),
                      ),
                      const SizedBox(width: 24),
                      arguments?.portfolio != null
                          ? IconButton(
                              onPressed: () async {
                                if (arguments?.isSelected ?? false) {
                                  showCannotDeleteSelectedPortfolioDialog(context);
                                } else {
                                  final shouldDelete = await showDeleteDialog(context);

                                  if (shouldDelete) {
                                    await portfolioDatabaseService.deletePortfolio(
                                      id: arguments!.portfolio.documentId,
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
                          : IconButton(
                              onPressed: () async {
                                //
                              },
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.transparent,
                              ),
                            ),
                    ],
                  ),
                  const PortfolioEditWidget(
                    colorMode: FormColorMode.light,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return const PortfolioEditWidget();
    },
    routeSettings: RouteSettings(name: '/portfolio/add-new/', arguments: arguments),
  );
}
