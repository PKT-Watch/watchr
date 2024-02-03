import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/database-address/bloc/database_address_bloc.dart';
import '../../../services/database-address/database_address.dart';
import '../../../utilities/tools/conversion.dart';
import '../../../globals/globals.dart' as globals;

class AddressListItemWidget extends StatelessWidget {
  const AddressListItemWidget({super.key, required this.address, required this.portfolioId});

  final int portfolioId;
  final DatabaseAddress address;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 0,
          color: Colors.transparent,
          child: InkWell(
            highlightColor: const Color(0x66000000),
            onTap: () => {
              context.read<DatabaseAddressBloc>().add(DatabaseAddressEmptyEvent()), // Flush the state so that we can tap the same address twice.
              context.read<DatabaseAddressBloc>().add(SelectDatabaseAddress(address)),
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        address.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        PKTConversion.formatAddress(address.address),
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  address.isLoadingBalance
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xffff007a),
                          ))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              PKTConversion.formatNumber(address.balance),
                              style: const TextStyle(
                                color: Color(0xffff007a),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              '\$${PKTConversion.formatNumber((address.balance * globals.pricePkt))}',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
