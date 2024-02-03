import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../services/address/address.dart';
import '../../../utilities/tools/conversion.dart';
import '../../../globals/globals.dart' as globals;

class AddressDetailsHeader extends StatelessWidget {
  const AddressDetailsHeader({super.key, required this.address, required this.isLoading});

  final Address address;
  final bool isLoading;

  void showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        width: double.infinity,
        height: 300,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        child: Column(
          children: [
            QrImageView(
              data: address.address,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
            ),
            const SizedBox(height: 10),
            Text(address.address),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.black),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            const Text(
              'Balance',
              style: TextStyle(
                color: Color(0xffff007a),
              ),
            ),
            const SizedBox(height: 5.0),
            isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xffff007a),
                        )),
                  )
                : Text(
                    PKTConversion.toPKTFromIntFormatted(int.parse(address.balance)),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            const SizedBox(height: 5.0),
            Text(
              '\$${PKTConversion.formatNumber((PKTConversion.toPKT(address.balance) * globals.pricePkt))}',
              style: const TextStyle(
                color: Color(0xffff007a),
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 25.0),
            Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                  child: ExtendedText(
                    address.address,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflowWidget: TextOverflowWidget(
                      position: TextOverflowPosition.middle,
                      align: TextOverflowAlign.center,
                      child: Text(
                        '...',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Flexible(
                  flex: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await Clipboard.setData(ClipboardData(text: address.address));
                          SnackBar snackBar = const SnackBar(
                            content: Text('Copied to clipboard'),
                            backgroundColor: Colors.black,
                          );
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        child: Icon(
                          Icons.copy,
                          color: Colors.grey.shade400,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          showShareSheet(context);
                        },
                        child: Icon(
                          Icons.qr_code_2,
                          color: Colors.grey.shade400,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 32, 32, 32),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Mined Last 24hr',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          PKTConversion.toPKTFormatted(address.mined24),
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 32, 32, 32),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Unconsolidated',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          PKTConversion.formatNumber(double.parse(address.balanceCount.toString())),
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
