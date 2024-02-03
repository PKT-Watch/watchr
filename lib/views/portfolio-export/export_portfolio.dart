import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/database-portfolio-export/bloc/database_portfolio_export_bloc.dart';
import '../../services/database-portfolio/portfolio_json_chunk.dart';

class ExportPortfolioView extends StatefulWidget {
  const ExportPortfolioView({super.key});

  @override
  State<ExportPortfolioView> createState() => _ExportPortfolioViewState();
}

class _ExportPortfolioViewState extends State<ExportPortfolioView> {
  int currentIndex = 0;
  Timer? timer;

  List<String> splitByLength(String value, int length) {
    List<String> pieces = [];

    for (int i = 0; i < value.length; i += length) {
      int offset = i + length;
      pieces.add(value.substring(i, offset >= value.length ? value.length : offset));
    }
    return pieces;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.read<DatabasePortfolioExportBloc>().add(const ExportPortfolioJson());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Portfolios'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: BlocBuilder<DatabasePortfolioExportBloc, DatabasePortfolioExportState>(
        buildWhen: (previous, current) {
          return current is PortfolioJsonExported;
        },
        builder: (context, state) {
          if (state is PortfolioJsonExported) {
            List<String> chunkedJson = splitByLength(state.json, 100);
            List<PortfolioJsonChunk> chunks = [];
            for (var i = 0; i < chunkedJson.length; i++) {
              chunks.add(PortfolioJsonChunk(index: i, totalChunks: chunkedJson.length, chunk: chunkedJson[i]));
            }

            if (timer != null) {
              timer!.cancel();
            }

            timer = Timer(
              const Duration(milliseconds: 500),
              () {
                setState(() {
                  currentIndex += 1;
                  if (currentIndex == chunks.length) {
                    currentIndex = 0;
                  }
                });
              },
            );

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                        child: Text(
                          "Copy your portfolios to another device by choosing 'Import Portfolios' and then scanning the QR codes.",
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Any portfolios on your other device will be deleted.",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
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
                      FractionallySizedBox(
                        widthFactor: 0.8,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 10,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: QrImageView(
                            data: json.encode(chunks[currentIndex].toJson()),
                            version: QrVersions.auto,
                            //size: 300.0,
                            backgroundColor: Colors.black,
                            dataModuleStyle: const QrDataModuleStyle(
                              color: Colors.white,
                              dataModuleShape: QrDataModuleShape.square,
                            ),
                            eyeStyle: const QrEyeStyle(
                              color: Colors.white,
                              eyeShape: QrEyeShape.square,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Part ${currentIndex + 1} of ${chunks.length}',
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            );
          }

          return const Column(
            children: [
              CircularProgressIndicator(color: Color(0xffff007a)),
            ],
          );
        },
      ),
    );
  }
}
