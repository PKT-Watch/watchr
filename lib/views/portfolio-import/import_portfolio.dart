import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/database-address/db_address_service.dart';
import '../../services/database-portfolio-export/bloc/database_portfolio_export_bloc.dart';
import '../../services/database-portfolio/bloc/database_portfolio_bloc.dart';
import '../../services/database-portfolio/database_portfolio.dart';
import '../../services/database-portfolio/db_portfolio_service.dart';
import '../../services/database-portfolio/portfolio_json_chunk.dart';

class ImportPortfolioView extends StatefulWidget {
  const ImportPortfolioView({super.key});

  @override
  State<ImportPortfolioView> createState() => _ImportPortfolioViewState();
}

class _ImportPortfolioViewState extends State<ImportPortfolioView> {
  int totalChunks = 0;
  List<PortfolioJsonChunk> chunks = [];

  late final DatabaseAddressService _addressesDatabaseService;
  late final DatabasePortfolioService _portfolioDatabaseService;
  late int selectedPortfolioID;

  MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  @override
  void initState() {
    _addressesDatabaseService = DatabaseAddressService();
    _portfolioDatabaseService = DatabasePortfolioService();
    context.read<DatabasePortfolioExportBloc>().add(ExportPortfolioInitial());
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _importPortfolio() async {
    chunks.sort();
    String mergedChunks = '';

    for (var i = 0; i < chunks.length; i++) {
      mergedChunks += chunks[i].chunk;
    }

    List<dynamic> list = json.decode(mergedChunks);
    List<DatabasePortfolio> portfolios = [];
    List<DatabasePortfolio> addedPortfolios = [];

    for (var i = 0; i < list.length; i++) {
      portfolios.add(DatabasePortfolio.fromJson(list[i]));
    }

    await _addressesDatabaseService.deleteAllAddresses();
    await _portfolioDatabaseService.deleteAllPortfolios();

    for (var portfolio in portfolios) {
      DatabasePortfolio addedPortfolio = await _portfolioDatabaseService.createPortfolio(label: portfolio.label, displayOrder: portfolio.displayOrder);

      for (var address in portfolio.addresses) {
        await _addressesDatabaseService.createAddress(
          label: address.label,
          address: address.address,
          portfolioID: addedPortfolio.documentId,
          displayOrder: address.displayOrder,
        );
      }

      addedPortfolios.add(addedPortfolio);
    }

    if (context.mounted) context.read<DatabasePortfolioBloc>().add(SelectPortfolio(addedPortfolios[0].documentId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Portfolios'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: BlocConsumer<DatabasePortfolioExportBloc, DatabasePortfolioExportState>(
        listenWhen: (previous, current) {
          return current is PortfolioJsonExportAllChunksFound;
        },
        listener: (context, state) {
          _importPortfolio();
        },
        buildWhen: (previous, current) {
          return current is DatabasePortfolioExportInitial || current is PortfolioJsonExportChunkFound || current is PortfolioJsonExportAllChunksFound;
        },
        builder: (context, state) {
          if (state is! PortfolioJsonExportAllChunksFound) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Copy your portfolios from another device by choosing 'Export Portfolios' and then scanning the QR codes.",
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: 4 / 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: MobileScanner(
                            fit: BoxFit.cover,
                            controller: controller,
                            onDetect: (capture) async {
                              final List<Barcode> barcodes = capture.barcodes;
                              for (final barcode in barcodes) {
                                debugPrint('Barcode found! ${barcode.rawValue}');

                                PortfolioJsonChunk chunk = PortfolioJsonChunk.fromJson(json.decode(barcode.rawValue!));

                                if (totalChunks == 0) {
                                  totalChunks = chunk.totalChunks;
                                }

                                if (chunks.any((item) => item.index == chunk.index)) {
                                } else {
                                  chunks.add(chunk);
                                  context.read<DatabasePortfolioExportBloc>().add(ExportPortfolioJsonChunkFound(chunk.index));
                                }

                                if (chunks.length == totalChunks) {
                                  controller.stop();
                                  context.read<DatabasePortfolioExportBloc>().add(const ExportPortfolioJsonAllChunksFound());
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.blueGrey.shade50,
                            valueColor: const AlwaysStoppedAnimation(Color(0xffff007a)),
                            minHeight: 14,
                            value: totalChunks > 0 ? (chunks.length / totalChunks) : null,
                          ),
                        ),
                      ),
                      totalChunks > 0
                          ? Text(
                              '${chunks.length} of $totalChunks scanned...',
                              style: const TextStyle(color: Colors.black),
                            )
                          : const Text('Looking for qr codes...', style: TextStyle(color: Colors.black)),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/account_cloud_alt.png'),
                    width: 200,
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Your portfolios have been imported.",
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
