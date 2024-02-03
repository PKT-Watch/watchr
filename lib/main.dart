import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'enums/device_type.dart';
import 'services/address/bloc/address_bloc.dart';
import 'services/database-address/bloc/database_address_bloc.dart';
import 'services/database-address/db_address_service.dart';
import 'services/database-portfolio-export/bloc/database_portfolio_export_bloc.dart';
import 'services/database-portfolio/bloc/database_portfolio_bloc.dart';
import 'services/database-portfolio/db_portfolio_service.dart';
import 'services/database/bloc/database_bloc.dart';
import 'views/address-details/address_details_view.dart';
import 'views/addresses/addresses_view.dart';
import 'views/addresses/addresses_view_tablet.dart';
import 'views/portfolio-edit/portfolio_edit_view.dart';
import 'views/portfolio-export/export_portfolio.dart';
import 'views/portfolio-import/import_portfolio.dart';
import 'views/settings/settings_view.dart';
import 'constants/routes.dart';
import 'views/address-edit/address_edit_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<DatabaseBloc>(
          create: (context) => DatabaseBloc(portfolioService: DatabasePortfolioService()),
        ),
        BlocProvider<DatabaseAddressBloc>(
          create: (context) => DatabaseAddressBloc(addressService: DatabaseAddressService()),
        ),
        BlocProvider<DatabasePortfolioBloc>(
          create: (context) => DatabasePortfolioBloc(portfolioService: DatabasePortfolioService()),
        ),
        BlocProvider<DatabasePortfolioExportBloc>(
          create: (context) => DatabasePortfolioExportBloc(portfolioService: DatabasePortfolioService(), addressService: DatabaseAddressService()),
        ),
        BlocProvider<AddressBloc>(
          create: (context) => AddressBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Watchr',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(color: Colors.white),
            color: Color(0xff000000),
            elevation: 0,
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
        routes: {
          createOrUpdateAddressRoute: (context) => const AddressEditView(),
          createOrUpdatePortfolioRoute: (context) => const PortfolioEditView(),
          addressDetailsView: (context) => AddressDetailsView(
                portfolioId: 0,
              ),
          settingsRoute: (context) => const SettingsView(),
          exportPortfolioRoute: (context) => const ExportPortfolioView(),
          importPortfolioRoute: (context) => const ImportPortfolioView(),
        },
      ),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  DeviceType getDeviceType() {
    final MediaQueryData data = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.single);
    return data.size.shortestSide < 550 ? DeviceType.phone : DeviceType.tablet;
  }

  @override
  Widget build(BuildContext context) {
    context.read<DatabaseBloc>().add(const DatabaseInitialize());

    // Android (iOS is controlled by info.plist)
    SystemChrome.setPreferredOrientations(
      getDeviceType() == DeviceType.phone ? [DeviceOrientation.portraitUp] : [],
    );

    return BlocConsumer<DatabaseBloc, DatabaseState>(
      listener: (context, state) {
        //
      },
      builder: (context, state) {
        if (state is DatabaseInitialised) {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.minWidth < 600) {
                return const AddressesView();
              } else {
                return const AddressesViewTablet();
              }
            },
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Container(
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xffff007a)),
              ),
            ),
          );
        }
      },
    );
  }
}
