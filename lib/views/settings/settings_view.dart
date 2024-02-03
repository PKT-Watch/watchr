import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../enums/device_type.dart';
import '../portfolio-export/export_portfolio.dart';
import '../portfolio-export/export_portfolio_tablet.dart';
import '../portfolio-import/import_portfolio_tablet.dart';
import '../portfolio-import/import_portfolio.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  DeviceType getDeviceType() {
    final MediaQueryData data = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.single);
    return data.size.shortestSide < 550 ? DeviceType.phone : DeviceType.tablet;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings and Privacy'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          ListTile(
            textColor: Colors.grey.shade400,
            iconColor: Colors.grey.shade400,
            title: const Text(
              'Export Portfolios',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text('Copy your portfolios to another device'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => getDeviceType() == DeviceType.phone ? const ExportPortfolioView() : const ExportPortfolioViewTablet(),
                  settings: const RouteSettings(
                    name: '/settings/export-portfolio/',
                  ),
                ),
              );
            },
          ),
          Divider(color: Colors.grey.shade600, height: 0),
          ListTile(
            textColor: Colors.grey.shade400,
            iconColor: Colors.grey.shade400,
            title: const Text(
              'Import Portfolios',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text('Receive portfolios from another device'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => getDeviceType() == DeviceType.phone ? const ImportPortfolioView() : const ImportPortfolioViewTablet(),
                  settings: const RouteSettings(
                    name: '/settings/import-portfolio/',
                  ),
                ),
              );
            },
          ),
          Divider(color: Colors.grey.shade600, height: 0),
          ListTile(
            textColor: Colors.grey.shade400,
            iconColor: Colors.grey.shade400,
            title: const Text(
              'Privacy Policy',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text('Learn more about how your data is used'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () async {
              await launchUrl(Uri.parse('https://pkt.watch/watchr/privacy-policy/'));
            },
          ),
        ],
      ),
    );
  }
}
