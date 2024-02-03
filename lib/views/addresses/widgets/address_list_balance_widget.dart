import 'package:flutter/material.dart';
import '../../../widgets/cumulative_balance_widget.dart';

class AddressListBalanceWidget extends StatelessWidget {
  const AddressListBalanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 25, 16, 35),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Balance',
                  style: TextStyle(
                    color: Color(0xffff007a),
                  ),
                ),
                CumualtiveBalanceWidget(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
