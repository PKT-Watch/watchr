import 'package:flutter/material.dart';
import '../../enums/form_color_mode.dart';
import '../../views/address-edit/address_edit_view.dart';
import '../../views/address-edit/widgets/address_edit_widget.dart';

Future<void> showAddAddressDialog(BuildContext context, [Object? arguments]) {
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
              height: 450,
              child: const AddressEditWidget(
                colorMode: FormColorMode.light,
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
      return const AddressEditView();
    },
    routeSettings: RouteSettings(name: '/address/add-new/', arguments: arguments),
  );
}
