import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/database-address/bloc/database_address_bloc.dart';
import '../utilities/tools/conversion.dart';
import '../globals/globals.dart' as globals;

class CumualtiveBalanceWidget extends StatelessWidget {
  CumualtiveBalanceWidget({super.key});

  double totalBalance = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DatabaseAddressBloc, DatabaseAddressState>(
      buildWhen: (previous, current) {
        return current is TotalBalanceUpdated || current is TotalBalanceCleared;
      },
      builder: ((context, state) {
        if (state is TotalBalanceCleared) {
          totalBalance = 0;
        } else if (state is TotalBalanceUpdated) {
          totalBalance = state.balance;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              PKTConversion.formatNumber(totalBalance),
              style: TextStyle(
                color: Colors.grey.shade100,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '\$${PKTConversion.formatNumber((totalBalance * globals.pricePkt))}',
              style: const TextStyle(
                color: Color(0xffff007a),
                fontSize: 20,
              ),
            ),
          ],
        );
      }),
    );
  }
}
