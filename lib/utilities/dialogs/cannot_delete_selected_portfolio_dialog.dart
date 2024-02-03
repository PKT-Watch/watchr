import 'package:flutter/material.dart';
import 'generic_dialog.dart';

Future<void> showCannotDeleteSelectedPortfolioDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Portfolios',
    content: 'You cannot delete the selected portfolio. Select another portfolio and try again.',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
