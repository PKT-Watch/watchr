import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/preference_keys.dart';
import '../../services/database-address/bloc/database_address_bloc.dart';
import '../../services/database-portfolio/bloc/database_portfolio_bloc.dart';
import '../address-details/widgets/address_details_fake_appbar.dart';
import '../address-details/widgets/address_details_widget.dart';
import 'widgets/address_list_balance_widget.dart';
import 'widgets/address_list_container_widget.dart';
import 'widgets/address_list_fake_appbar.dart';
import '../../widgets/sidebar_widget.dart';

class AddressesViewTablet extends StatefulWidget {
  const AddressesViewTablet({super.key});

  @override
  State<AddressesViewTablet> createState() => _AddressesViewTabletState();
}

class _AddressesViewTabletState extends State<AddressesViewTablet> {
  SharedPreferences? prefs;
  late int selectedPortfolioID;
  late String selectedPortfolioName;

  @override
  void initState() {
    super.initState();
  }

  Future<int> getSelectedPortfolio() async {
    prefs ??= await SharedPreferences.getInstance();

    try {
      selectedPortfolioID = prefs!.getInt(selectedPortfolioIdKey) ?? -1;
      selectedPortfolioName = prefs!.getString(selectedPortfolioNameKey) ?? '';
    } catch (e) {
      throw Exception();
    }

    return selectedPortfolioID;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getSelectedPortfolio(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          context.read<DatabaseAddressBloc>().add(LoadAddresses(selectedPortfolioID));
          context.read<DatabasePortfolioBloc>().add(const LoadPortfolios());

          return Scaffold(
            backgroundColor: Colors.black,
            floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
            floatingActionButton: BlocBuilder<DatabaseAddressBloc, DatabaseAddressState>(
              buildWhen: (previous, current) => current is DatabaseAddressListEditable,
              builder: (context, state) {
                if (state is DatabaseAddressListEditable) {
                  return Visibility(
                    visible: state.isEditable,
                    child: FloatingActionButton(
                      backgroundColor: const Color(0xffff007a),
                      onPressed: () {
                        context.read<DatabaseAddressBloc>().add(const MakeDatabaseAddressListEditable(false));
                        context.read<DatabaseAddressBloc>().add(LoadAddresses(selectedPortfolioID));
                      },
                      child: const Icon(Icons.done),
                    ),
                  );
                } else {
                  return const SizedBox(); // Shouldn't happen
                }
              },
            ),
            drawer: Drawer(
              backgroundColor: Colors.white,
              child: SidebarWidget(
                selectedPortfolioID: selectedPortfolioID,
                selectedPortfolioName: selectedPortfolioName,
              ),
            ),
            body: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const AddressListFakeAppBar(),
                        const Flexible(
                          flex: 0,
                          child: AddressListBalanceWidget(),
                        ),
                        Expanded(
                          child: AddressListContainerWidget(selectedPortfolioID: selectedPortfolioID),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(color: Color.fromARGB(255, 64, 64, 64)),
                  Expanded(
                    flex: 3,
                    child: BlocBuilder<DatabaseAddressBloc, DatabaseAddressState>(
                      buildWhen: (previous, current) {
                        return current is DatabaseAddressSelected || current is DatabaseAddressEmpty;
                      },
                      builder: (context, state) {
                        if (state is DatabaseAddressSelected) {
                          return Column(
                            children: [
                              const AddressDetailsFakeAppBar(),
                              Expanded(
                                child: AddressDetailsWidget(
                                  portfolioId: selectedPortfolioID,
                                  address: state.address,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return AddressDetailsWidget(
                            portfolioId: selectedPortfolioID,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xffff007a)),
          );
        }
      },
    );
  }
}
