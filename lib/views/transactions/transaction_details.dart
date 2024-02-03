import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/routes.dart';
import '../../enums/device_type.dart';
import '../../enums/menu_action.dart';
import '../../services/database-address/database_address.dart';
import '../../services/transaction/transaction.dart';
import '../../utilities/dialogs/add_address_dialog.dart';
import '../../utilities/tools/conversion.dart';

class TransactionDetails extends StatelessWidget {
  const TransactionDetails({super.key, required this.transaction, required this.address});
  final AddressTransaction transaction;
  final DatabaseAddress address;

  double deviceHeight(BuildContext context) => MediaQuery.of(context).size.height;
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;

  DeviceType getDeviceType() {
    final MediaQueryData data = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.single);
    return data.size.shortestSide < 550 ? DeviceType.phone : DeviceType.tablet;
  }

  Widget buildTransactionIcon(AddressTransaction trans) {
    if (trans.blockTime == null) {
      return const Icon(
        Icons.update,
        color: Color(0xFFe1301c),
        size: 40,
      );
    } else if (trans.isFolding) {
      return Icon(
        Icons.sync,
        color: Colors.grey.shade500,
        size: 40,
      );
    } else if (trans.isSend) {
      return const Column(
        children: [
          Text(
            'Sent',
            style: TextStyle(
              color: Color(0xffff007a),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Icon(
            Icons.remove_circle,
            color: Color(0xffff007a),
            size: 40,
          ),
        ],
      );
    } else {
      return const Column(
        children: [
          Text(
            'Received',
            style: TextStyle(
              color: Color.fromARGB(255, 30, 200, 118),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Icon(
            Icons.add_circle,
            color: Color.fromARGB(255, 30, 200, 118),
            size: 40,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.openExplorer:
                  await launchUrl(Uri.parse('https://packetscan.io/tx/${transaction.txid}'));
                case MenuAction.logout:
                  return;
                case MenuAction.openMiningStats:
                  return;
                case MenuAction.editAddress:
                  return;
                case MenuAction.deleteAddress:
                  return;
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
                      ),
                      const SizedBox(width: 5),
                      const Text('Explorer'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                flex: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            buildTransactionIcon(transaction),
                            const SizedBox(height: 10),
                            transaction.isFolding
                                ? Text('Folding', style: TextStyle(color: Colors.grey.shade100))
                                : transaction.isSend
                                    ? Text(
                                        '-${PKTConversion.toPKTFormatted(transaction.value!)} PKT',
                                        style: const TextStyle(
                                          color: Color(0xffff007a),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : Text(
                                        '+${PKTConversion.toPKTFormatted(transaction.value!)} PKT',
                                        style: const TextStyle(color: Color.fromARGB(255, 30, 200, 118), fontWeight: FontWeight.w600),
                                      ),
                            const SizedBox(height: 25),
                            Text(
                              'Date',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              PKTConversion.formatDate(transaction.firstSeen!, context),
                              style: TextStyle(color: Colors.grey.shade100),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction ID',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Text(
                            transaction.txid!,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: () async {
                            await Clipboard.setData(ClipboardData(text: transaction.txid!));
                            SnackBar snackBar = const SnackBar(content: Text('Copied to clipboard'));
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          },
                          child: Icon(
                            Icons.copy,
                            color: Colors.grey.shade400,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),
                    Text(
                      'From',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: transaction.input.length,
                      itemBuilder: (context, index) {
                        final input = transaction.input.elementAt(index);
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: input.address == address.address
                              ? Text(
                                  input.address,
                                  style: const TextStyle(color: Colors.white),
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        input.address,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    GestureDetector(
                                      onTap: () async {
                                        await Navigator.of(context).pushNamed(
                                          createOrUpdateAddressRoute,
                                          arguments: DatabaseAddress(
                                            documentId: '',
                                            ownerUserId: '',
                                            address: input.address,
                                            label: '',
                                            portfolioID: -1,
                                            displayOrder: 0,
                                            createdAt: DateTime.now().millisecondsSinceEpoch,
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.grey.shade400,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                        );
                      },
                    ),
                    Text(
                      'To',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: transaction.output.length,
                      itemBuilder: (context, index) {
                        final output = transaction.output.elementAt(index);
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: output.address == address.address
                              ? Text(
                                  output.address,
                                  style: const TextStyle(color: Colors.white),
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        output.address,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    GestureDetector(
                                      onTap: () async {
                                        if (getDeviceType() == DeviceType.phone) {
                                          await Navigator.of(context).pushNamed(
                                            createOrUpdateAddressRoute,
                                            arguments: DatabaseAddress(
                                              documentId: '',
                                              ownerUserId: '',
                                              address: output.address,
                                              label: '',
                                              portfolioID: -1,
                                              displayOrder: 0,
                                              createdAt: DateTime.now().millisecondsSinceEpoch,
                                            ),
                                          );
                                        } else {
                                          showAddAddressDialog(
                                            context,
                                            DatabaseAddress(
                                              documentId: '',
                                              ownerUserId: '',
                                              address: output.address,
                                              label: '',
                                              portfolioID: -1,
                                              displayOrder: 0,
                                              createdAt: DateTime.now().millisecondsSinceEpoch,
                                            ),
                                          );
                                        }
                                      },
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.grey.shade400,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
