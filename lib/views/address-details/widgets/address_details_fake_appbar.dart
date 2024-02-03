import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/address/bloc/address_bloc.dart';
import '../../../services/database-address/bloc/database_address_bloc.dart';
import 'address_details_menu_widget.dart';

class AddressDetailsFakeAppBar extends StatelessWidget {
  const AddressDetailsFakeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: BlocBuilder<DatabaseAddressBloc, DatabaseAddressState>(
        buildWhen: (previous, current) {
          return current is DatabaseAddressSelected;
        },
        builder: (context, state) {
          if (state is DatabaseAddressSelected) {
            // If we changed the lable, the text wont update when a new address is selcted
            // unless we trigger an update here.
            context.read<AddressBloc>().add(UpdateAddressLabel(state.address.label));
            return Row(
              children: [
                IconButton(
                  onPressed: () {
                    // This is a fake appbar, so we dont need to do anything here.
                  },
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.transparent,
                  ),
                ),
                Expanded(
                  child: BlocBuilder<AddressBloc, AddressState>(
                    buildWhen: (previous, current) {
                      return current is AddressLabelUpdated;
                    },
                    builder: (context, stateAddressBloc) {
                      if (stateAddressBloc is AddressLabelUpdated) {
                        return Text(
                          stateAddressBloc.label,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        );
                      }

                      return Text(
                        state.address.label,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
                AddressDetailsMenuWidget(address: state.address)
              ],
            );
          }
          return const Row();
        },
      ),
    );
  }
}
