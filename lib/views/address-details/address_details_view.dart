import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../enums/menu_action.dart';
import '../../enums/text_field_theme.dart';
import '../../services/address/bloc/address_bloc.dart';
import '../../services/database-address/bloc/database_address_bloc.dart';
import '../../services/database-address/database_address.dart';
import '../../services/database-address/db_address_service.dart';
import '../../utilities/dialogs/delete_dialog.dart';
import 'widgets/address_details_widget.dart';
import '../../widgets/custom_text_field.dart';

class AddressDetailsView extends StatefulWidget {
  const AddressDetailsView({super.key, this.address, required this.portfolioId});

  final DatabaseAddress? address;
  final int portfolioId;

  @override
  State<AddressDetailsView> createState() => _AddressDetailsViewState();
}

class _AddressDetailsViewState extends State<AddressDetailsView> {
  late final DatabaseAddressService _addressesDatabaseService;
  late final TextEditingController _textControllerLabel;

  double deviceHeight(BuildContext context) => MediaQuery.of(context).size.height;
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;

  late String addressLabel;

  Uri? _urlExplorer;
  Uri? _urlMiningStats;

  _showDialog() async {
    _textControllerLabel.text = widget.address!.label;
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
              await updateAddress();

              if (context.mounted) Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  Future<bool> updateAddress() async {
    String addressText = widget.address!.address;
    String labelText = _textControllerLabel.text;

    if (labelText.isNotEmpty) {
      await _addressesDatabaseService.updateAddress(
        documentId: widget.address!.documentId,
        address: addressText,
        label: labelText,
        portfolioID: widget.address!.portfolioID,
        displayOrder: widget.address!.displayOrder,
      );

      if (context.mounted) {
        context.read<DatabaseAddressBloc>().add(LoadAddresses(widget.address!.portfolioID));
        context.read<AddressBloc>().add(UpdateAddressLabel(labelText));
      }

      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    if (widget.address != null) {
      _textControllerLabel = TextEditingController();
      _addressesDatabaseService = DatabaseAddressService();
      _urlExplorer = Uri.parse('https://packetscan.io/address/${widget.address!.address}');
      _urlMiningStats = Uri.parse('https://www.pkt.world/explorer?wallet=${widget.address!.address}&minutes=60');
      addressLabel = widget.address!.label;
    }

    super.initState();
  }

  @override
  void dispose() {
    _textControllerLabel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.address != null) {
      return Scaffold(
        appBar: AppBar(
          title: BlocBuilder<AddressBloc, AddressState>(
            buildWhen: (previous, current) {
              return current is AddressLabelUpdated;
            },
            builder: (context, state) {
              if (state is AddressLabelUpdated) {
                addressLabel = state.label;
                return Text(state.label);
              }

              return Text(addressLabel);
            },
          ),
          centerTitle: true,
          actions: [
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.deleteAddress:
                    final shouldDelete = await showDeleteDialog(context);
                    if (shouldDelete) {
                      await _addressesDatabaseService.deleteAddress(
                        documentId: widget.address!.documentId,
                      );

                      if (context.mounted) {
                        context.read<DatabaseAddressBloc>().add(LoadAddresses(widget.portfolioId));
                        Navigator.pop(context);
                      }
                    }
                    break;
                  case MenuAction.openExplorer:
                    if (_urlExplorer != null) {
                      await launchUrl(_urlExplorer!);
                    }
                    break;
                  case MenuAction.openMiningStats:
                    if (_urlMiningStats != null) {
                      await launchUrl(_urlMiningStats!);
                    }
                    break;
                  case MenuAction.editAddress:
                    await _showDialog();
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
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: AddressDetailsWidget(portfolioId: widget.address!.portfolioID, address: widget.address!),
      );
    } else {
      return const Column(
        children: [Text('No address selected')],
      );
    }
  }
}
