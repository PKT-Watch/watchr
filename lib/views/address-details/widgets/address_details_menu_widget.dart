import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../enums/device_type.dart';
import '../../../enums/menu_action.dart';
import '../../../enums/text_field_theme.dart';
import '../../../services/address/bloc/address_bloc.dart';
import '../../../services/database-address/bloc/database_address_bloc.dart';
import '../../../services/database-address/database_address.dart';
import '../../../services/database-address/db_address_service.dart';
import '../../../utilities/dialogs/delete_dialog.dart';
import '../../../widgets/custom_text_field.dart';

class AddressDetailsMenuWidget extends StatelessWidget {
  AddressDetailsMenuWidget({super.key, required this.address});

  final DatabaseAddress address;

  final DatabaseAddressService _addressesDatabaseService = DatabaseAddressService();
  final TextEditingController _textControllerLabel = TextEditingController();

  double deviceHeight(BuildContext context) => MediaQuery.of(context).size.height;
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;

  DeviceType getDeviceType() {
    final MediaQueryData data = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.single);
    return data.size.shortestSide < 550 ? DeviceType.phone : DeviceType.tablet;
  }

  late final Uri _urlExplorer;
  late final Uri _urlMiningStats;

  _showDialog(BuildContext context) async {
    _textControllerLabel.text = address.label;
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(
                'Label',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.left,
              ),
            ),
            CustomtextField(
              textEditingController: _textControllerLabel,
              autofocus: true,
              theme: TextFieldTheme.light,
              elevation: 0,
              horizontalPadding: deviceHeight(context) / 62,
              verticalPadding: deviceHeight(context) / 62,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xffff007a)),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xffff007a)),
            ),
            onPressed: () async {
              await updateAddress(context);

              if (context.mounted) Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  Future<bool> updateAddress(BuildContext context) async {
    String addressText = address.address;
    String labelText = _textControllerLabel.text;

    if (labelText.isNotEmpty) {
      await _addressesDatabaseService.updateAddress(
        documentId: address.documentId,
        address: addressText,
        label: labelText,
        portfolioID: address.portfolioID,
        displayOrder: address.displayOrder,
      );

      if (context.mounted) {
        context.read<DatabaseAddressBloc>().add(LoadAddresses(address.portfolioID));
        context.read<AddressBloc>().add(UpdateAddressLabel(labelText));
      }

      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _urlExplorer = Uri.parse('https://packetscan.io/address/${address.address}');
    _urlMiningStats = Uri.parse('https://www.pkt.world/explorer?wallet=${address.address}&minutes=60');

    return PopupMenuButton<MenuAction>(
      color: Colors.white,
      onSelected: (value) async {
        switch (value) {
          case MenuAction.deleteAddress:
            final shouldDelete = await showDeleteDialog(context);
            if (shouldDelete) {
              await _addressesDatabaseService.deleteAddress(
                documentId: address.documentId,
              );

              if (context.mounted) {
                context.read<DatabaseAddressBloc>().add(LoadAddresses(address.portfolioID));
                context.read<DatabaseAddressBloc>().add(DatabaseAddressEmptyEvent());

                if (getDeviceType() == DeviceType.phone) {
                  Navigator.pop(context);
                }
              }
            }
            break;
          case MenuAction.openExplorer:
            await launchUrl(_urlExplorer);
            break;
          case MenuAction.openMiningStats:
            await launchUrl(_urlMiningStats);
            break;
          case MenuAction.editAddress:
            await _showDialog(context);
            break;
          case MenuAction.logout:
            break;
        }
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem<MenuAction>(
            value: MenuAction.openExplorer,
            child: Row(
              children: [
                Icon(
                  Icons.open_in_new,
                  color: Colors.blueGrey.shade500,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Text('Explorer'),
              ],
            ),
          ),
          PopupMenuItem<MenuAction>(
            value: MenuAction.openMiningStats,
            child: Row(
              children: [
                Icon(
                  Icons.open_in_new,
                  color: Colors.blueGrey.shade500,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Text('Mining Stats'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<MenuAction>(
            value: MenuAction.editAddress,
            child: Row(
              children: [
                Icon(
                  Icons.edit,
                  color: Colors.blueGrey.shade500,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Text('Edit Label'),
              ],
            ),
          ),
          const PopupMenuItem<MenuAction>(
            value: MenuAction.deleteAddress,
            child: Row(
              children: [
                Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text('Delete'),
              ],
            ),
          ),
        ];
      },
    );
  }
}
