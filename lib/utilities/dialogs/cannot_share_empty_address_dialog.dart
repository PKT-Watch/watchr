import 'package:flutter/material.dart';
import 'generic_dialog.dart';

Future<void> showCannotShareEmptyAddressDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Sharing',
    content: 'You cannot share an empty address!',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
