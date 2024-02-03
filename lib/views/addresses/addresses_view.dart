import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/preference_keys.dart';
import '../../services/database-address/bloc/database_address_bloc.dart';
import '../../services/database-portfolio/bloc/database_portfolio_bloc.dart';
import '../../services/database-portfolio/database_portfolio.dart';
import '../address-details/address_details_view.dart';
import '../address-edit/address_edit_view.dart';
import 'widgets/address_list_balance_widget.dart';
import 'widgets/address_list_container_widget.dart';
import '../../widgets/sidebar_widget.dart';

class AddressesView extends StatefulWidget {
  const AddressesView({super.key});

  @override
  State<AddressesView> createState() => _AddressesViewState();
}

class _AddressesViewState extends State<AddressesView> {
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

  void selectPortfolio(DatabasePortfolio portfolio) async {
    if (portfolio.documentId == selectedPortfolioID) return;

    selectedPortfolioID = portfolio.documentId;

    context.read<DatabasePortfolioBloc>().add(SelectPortfolio(selectedPortfolioID));
    context.read<DatabasePortfolioBloc>().add(const LoadPortfolios());
    context.read<DatabaseAddressBloc>().add(LoadAddresses(portfolio.documentId));
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
            appBar: AppBar(
              centerTitle: true,
              title: BlocBuilder<DatabasePortfolioBloc, DatabasePortfolioState>(
                buildWhen: (previous, current) {
                  return current is PortfolioSelected;
                },
                builder: (context, state) {
                  if (state is PortfolioSelected) {
                    selectPortfolio(state.portfolio);
                    return Text(state.portfolio.label);
                  }
                  return Text(selectedPortfolioName);
                },
              ),
              actions: [
                IconButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddressEditView(),
                        settings: const RouteSettings(name: '/address/new-address/'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
            floatingActionButton: BlocConsumer<DatabaseAddressBloc, DatabaseAddressState>(
              listenWhen: (previous, current) => current is DatabaseAddressSelected,
              listener: (context, state) {
                if (state is DatabaseAddressSelected) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddressDetailsView(
                        address: state.address,
                        portfolioId: selectedPortfolioID,
                      ),
                      settings: const RouteSettings(name: '/address/details/'),
                    ),
                  );
                }
              },
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
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Flexible(
                  flex: 0,
                  child: AddressListBalanceWidget(),
                ),
                Expanded(
                  child: AddressListContainerWidget(selectedPortfolioID: selectedPortfolioID),
                ),
              ],
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
