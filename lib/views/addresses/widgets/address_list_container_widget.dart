import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../enums/device_type.dart';
import '../../../services/database-address/bloc/database_address_bloc.dart';
import '../../../services/database-portfolio/bloc/database_portfolio_bloc.dart';
import '../../../utilities/dialogs/add_address_dialog.dart';
import '../../address-edit/address_edit_view.dart';
import 'address_list_widget.dart';

class AddressListContainerWidget extends StatelessWidget {
  AddressListContainerWidget({super.key, required this.selectedPortfolioID});

  int selectedPortfolioID;
  bool isEditable = false;

  void _showAddAddressDialog(BuildContext context) {
    showAddAddressDialog(context);
  }

  DeviceType getDeviceType() {
    final MediaQueryData data = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.single);
    return data.size.shortestSide < 550 ? DeviceType.phone : DeviceType.tablet;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DatabasePortfolioBloc, DatabasePortfolioState>(
      listener: (context, state) {
        if (state is PortfolioSelected) {
          selectedPortfolioID = state.portfolio.documentId;
        }
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            height: constraints.maxHeight,
            decoration: const BoxDecoration(
              color: Color(0xff000000),
            ),
            child: BlocConsumer<DatabaseAddressBloc, DatabaseAddressState>(
              listenWhen: (previous, current) {
                return current is AddressesLoaded || current is AddressBalancesLoaded;
              },
              listener: (context, state) {
                if (state is AddressesLoaded) {
                  context.read<DatabaseAddressBloc>().add(const LoadAddressBalances());
                }

                if (state is AddressBalancesLoaded) {
                  context.read<DatabaseAddressBloc>().add(UpdateTotalBalance(state.balance));
                }
              },
              buildWhen: (previous, current) {
                return current is DatabaseAddressInitial ||
                    current is AddressesLoaded ||
                    current is DatabaseAddressListEditable ||
                    current is AddressBalancesLoaded;
              },
              builder: ((context, state) {
                if (state is DatabaseAddressInitial) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xffff007a)),
                  );
                }

                final allAddresses = state.addresses;

                bool isEditable = (state is DatabaseAddressListEditable ? state.isEditable : false);

                if (allAddresses.isNotEmpty) {
                  return GestureDetector(
                    onLongPress: () {
                      if (isEditable != true) {
                        isEditable = true;
                        context.read<DatabaseAddressBloc>().add(const MakeDatabaseAddressListEditable(true));
                      }
                    },
                    child: Container(
                      child: AddressListWidget(
                        addresses: allAddresses,
                        portfolioId: selectedPortfolioID,
                        isReorderable: isEditable,
                        onBalanceUpdated: (balance) {
                          context.read<DatabaseAddressBloc>().add(UpdateTotalBalance(balance));
                        },
                        onRefresh: () {
                          //
                        },
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No addresses yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffff007a),
                            padding: const EdgeInsets.all(16),
                          ),
                          onPressed: () async {
                            if (getDeviceType() == DeviceType.phone) {
                              await Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) => const AddressEditView(),
                                  settings: const RouteSettings(name: '/address/new-address/'),
                                ),
                              );
                            } else {
                              _showAddAddressDialog(context);
                            }
                          },
                          child: const Text('Add an address'),
                        ),
                      ],
                    ),
                  );
                }
              }),
            ),
          );
        },
      ),
    );
  }
}
