import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/database-portfolio/bloc/database_portfolio_bloc.dart';
import '../../../utilities/dialogs/add_address_dialog.dart';

class AddressListFakeAppBar extends StatelessWidget {
  const AddressListFakeAppBar({super.key});

  void _showAddAddressDialog(BuildContext context) {
    showAddAddressDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: BlocBuilder<DatabasePortfolioBloc, DatabasePortfolioState>(
              buildWhen: (previous, current) {
                return current is PortfolioSelected;
              },
              builder: (context, state) {
                if (state is PortfolioSelected) {
                  return Text(
                    state.portfolio.label,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  );
                }
                return const Text('');
              },
            ),
          ),
          IconButton(
            onPressed: () {
              _showAddAddressDialog(context);
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
