import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../enums/device_type.dart';
import '../helpers/arguments/create_update_portfolio_arguments.dart';
import '../services/database-address/bloc/database_address_bloc.dart';
import '../services/database-portfolio/bloc/database_portfolio_bloc.dart';
import '../services/database-portfolio/database_portfolio.dart';
import '../services/database-portfolio/db_portfolio_service.dart';
import '../utilities/dialogs/add_portfolio_dialog.dart';
import '../views/portfolio-edit/portfolio_edit_view.dart';
import '../views/settings/settings_view.dart';

class SidebarWidget extends StatelessWidget {
  SidebarWidget({super.key, required this.selectedPortfolioID, required this.selectedPortfolioName});

  int selectedPortfolioID;
  String selectedPortfolioName;

  final DatabasePortfolioService _portfolioDatabaseService = DatabasePortfolioService();

  DeviceType getDeviceType() {
    final MediaQueryData data = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.single);
    return data.size.shortestSide < 550 ? DeviceType.phone : DeviceType.tablet;
  }

  Widget buildPortfolioListItem(DatabasePortfolio portfolio, int index, bool isEditable, BuildContext context) {
    if (isEditable) {
      return ListTile(
        key: Key('$index'),
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        minLeadingWidth: 0,
        title: Text(portfolio.label),
        onTap: () async {
          CreateUpdatePortfolioArguments args = CreateUpdatePortfolioArguments(portfolio, portfolio.documentId == selectedPortfolioID);

          if (getDeviceType() == DeviceType.phone) {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const PortfolioEditView(),
                settings: RouteSettings(
                  name: '/portfolio/new-portfolio/',
                  arguments: args,
                ),
              ),
            );
          } else {
            showAddPortfolioDialog(context, args);
          }
        },
        leading: ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.drag_indicator, size: 20),
        ),
        trailing: const Icon(
          Icons.edit,
          size: 20,
        ),
      );
    }

    return ListTile(
      key: Key('$index'),
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      minLeadingWidth: 0,
      title: Text(portfolio.label),
      onTap: () async {
        selectPortfolio(portfolio, context);
        Navigator.pop(context);
      },
      trailing: Icon(
        Icons.check,
        size: 20,
        color: portfolio.documentId == selectedPortfolioID ? const Color.fromARGB(255, 30, 200, 118) : Colors.transparent,
      ),
    );
  }

  void selectPortfolio(DatabasePortfolio portfolio, BuildContext context) async {
    if (portfolio.documentId == selectedPortfolioID) return;

    selectedPortfolioID = portfolio.documentId;

    context.read<DatabasePortfolioBloc>().add(SelectPortfolio(selectedPortfolioID));
    context.read<DatabasePortfolioBloc>().add(const LoadPortfolios());
    context.read<DatabaseAddressBloc>().add(LoadAddresses(portfolio.documentId));
    context.read<DatabaseAddressBloc>().add(DatabaseAddressEmptyEvent());
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: 160,
          child: DrawerHeader(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Container(
              child: const Row(
                children: [
                  Image(
                    image: AssetImage('assets/images/cube_logo_alt.png'),
                    width: 50,
                    alignment: Alignment.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8),
          child: Row(
            children: [
              const Text('Portfolios', style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  if (getDeviceType() == DeviceType.phone) {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const PortfolioEditView(),
                        settings: const RouteSettings(name: '/portfolio/new-portfolio/'),
                      ),
                    );
                  } else {
                    showAddPortfolioDialog(context);
                  }
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        BlocConsumer<DatabasePortfolioBloc, DatabasePortfolioState>(
          listenWhen: (previous, current) {
            return current is PortfolioSelected;
          },
          listener: (context, state) {
            if (state is PortfolioSelected) {
              selectedPortfolioID = state.portfolio.documentId;
              selectedPortfolioName = state.portfolio.label;
            }
          },
          buildWhen: (previous, current) {
            return current is PortfoliosLoaded || current is PortfolioListEditable;
          },
          builder: ((context, state) {
            final allPortfolios = state.portfolios;
            bool isEditable = (state is PortfolioListEditable ? state.isEditable : false);

            return Column(children: [
              Container(
                child: ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(0),
                  itemCount: allPortfolios.length,
                  itemBuilder: (context, index) {
                    final portfolio = allPortfolios.elementAt(index);
                    return buildPortfolioListItem(portfolio, index, isEditable, context);
                  },
                  onReorder: (int oldIndex, int newIndex) {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final DatabasePortfolio item = allPortfolios.removeAt(oldIndex);
                    allPortfolios.insert(newIndex, item);

                    for (var i = 0; i < allPortfolios.length; i++) {
                      _portfolioDatabaseService.updatePortfolio(
                        documentId: allPortfolios[i].documentId,
                        label: allPortfolios[i].label,
                        displayOrder: i,
                      );
                    }
                  },
                ),
              ),
              Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: OutlinedButton(
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
                    ),
                    onPressed: () {
                      context.read<DatabasePortfolioBloc>().add(MakeListEditable(!isEditable));
                    },
                    child: isEditable
                        ? const Text(
                            'Done',
                            style: TextStyle(color: Color(0xffff007a)),
                          )
                        : const Text(
                            'Edit portfolios',
                            style: TextStyle(color: Color(0xffff007a)),
                          ),
                  ),
                ),
              ),
            ]);
          }),
        ),
        const Divider(),
        ListTile(
          visualDensity: VisualDensity.compact,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          title: const Text('Settings and Privacy'),
          trailing: const Icon(
            Icons.chevron_right,
            size: 20,
          ),
          onTap: () async {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const SettingsView(),
                settings: const RouteSettings(name: '/settings/'),
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          visualDensity: VisualDensity.compact,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          title: const Image(
            image: AssetImage('assets/images/pkt_watch_logo.png'),
            height: 30,
            alignment: Alignment.centerLeft,
          ),
          trailing: const Icon(
            Icons.open_in_new,
            size: 20,
          ),
          onTap: () async {
            await launchUrl(Uri.parse('https://pkt.watch'));
          },
        ),
      ],
    );
  }
}
