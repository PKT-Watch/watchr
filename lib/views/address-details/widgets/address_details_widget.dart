import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/address/address.dart';
import '../../../services/address/bloc/address_bloc.dart';
import '../../../services/database-address/database_address.dart';
import '../../../services/transaction/transaction.dart';
import '../../../utilities/tools/conversion.dart';
import 'address_details_header.dart';
import '../../transactions/transaction_details.dart';

class AddressDetailsWidget extends StatefulWidget {
  const AddressDetailsWidget({super.key, this.address, required this.portfolioId});

  final DatabaseAddress? address;
  final int portfolioId;

  @override
  State<AddressDetailsWidget> createState() => _AddressDetailsWidgetState();
}

class _AddressDetailsWidgetState extends State<AddressDetailsWidget> {
  double deviceHeight(BuildContext context) => MediaQuery.of(context).size.height;
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;

  late String addressLabel;

  List<FlSpot> _chartSpots(List<int> miningIncome) {
    List<FlSpot> list = <FlSpot>[];

    for (var i = 0; i < miningIncome.length; i++) {
      list.add(FlSpot(i.toDouble(), PKTConversion.toPKTFromInt(miningIncome[i])));
    }

    return list;
  }

  List<FlSpot> _chartSpotsDummy() {
    List<int> listValues = [25, 59, 31, 52, 46, 84, 97, 44, 47, 56, 82, 32, 28, 7, 15, 64, 58, 27, 2, 53, 18, 70, 89, 69, 72, 87, 47, 71, 80, 90, 90];
    List<FlSpot> list = <FlSpot>[];

    for (var i = 0; i < listValues.length; i++) {
      list.add(FlSpot(i.toDouble(), listValues[i].toDouble()));
    }

    return list;
  }

  Widget buildChart(List<int>? miningIncome) {
    if (miningIncome == null) {
      // Loading state
      return LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: _chartSpotsDummy(),
              isCurved: false,
              barWidth: 5,
              color: Colors.grey.shade900,
            ),
          ],
          gridData: const FlGridData(
            drawVerticalLine: true,
            drawHorizontalLine: false,
            verticalInterval: 6,
          ),
          titlesData: const FlTitlesData(
            show: false,
          ),
          lineTouchData: const LineTouchData(
            enabled: false,
          ),
        ),
      );
    }

    double totalMined = miningIncome.fold(0, (previous, current) => previous + current);

    if (totalMined == 0) {
      // No mining data
      return Stack(
        children: [
          LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: _chartSpotsDummy(),
                  isCurved: false,
                  barWidth: 5,
                  color: Colors.grey.shade900,
                ),
              ],
              gridData: const FlGridData(
                drawVerticalLine: true,
                drawHorizontalLine: false,
                verticalInterval: 6,
              ),
              titlesData: const FlTitlesData(
                show: false,
              ),
              lineTouchData: const LineTouchData(
                enabled: false,
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: Text(
                'No mining data',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: _chartSpots(miningIncome),
            isCurved: false,
            barWidth: 5,
            color: const Color(0xffff007a),
          ),
        ],
        gridData: const FlGridData(
          drawVerticalLine: true,
          drawHorizontalLine: false,
          verticalInterval: 6,
        ),
        titlesData: const FlTitlesData(
          show: false,
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
            //
          },
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: const Color(0xffff007a),
            tooltipRoundedRadius: 20.0,
            showOnTopOfTheChartBoxArea: true,
            fitInsideHorizontally: true,
            tooltipMargin: 0,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map(
                (LineBarSpot touchedSpot) {
                  const textStyle = TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  );
                  return LineTooltipItem(
                    PKTConversion.toPKTFromInt(miningIncome[touchedSpot.spotIndex]).toStringAsFixed(2),
                    textStyle,
                  );
                },
              ).toList();
            },
          ),
          getTouchedSpotIndicator: (LineChartBarData barData, List<int> indicators) {
            return indicators.map(
              (int index) {
                const line = FlLine(color: Colors.grey, strokeWidth: 1, dashArray: [2, 4]);
                return const TouchedSpotIndicatorData(
                  line,
                  FlDotData(show: false),
                );
              },
            ).toList();
          },
          getTouchLineEnd: (_, __) => double.infinity,
        ),
      ),
    );
  }

  Widget buildTransactionIcon(AddressTransaction trans) {
    if (trans.blockTime == null) {
      return const Icon(
        Icons.update,
        color: Color(0xFFe1301c),
      );
    } else if (trans.isFolding) {
      return Icon(
        Icons.sync,
        color: Colors.grey.shade500,
      );
    } else if (trans.isSend) {
      return const Icon(
        Icons.remove_circle,
        color: Color(0xffff007a),
      );
    } else {
      return const Icon(
        Icons.add_circle,
        color: Color.fromARGB(255, 30, 200, 118),
      );
    }
  }

  Widget buildTransactionList(List<AddressTransaction> transactions) {
    return transactions.isNotEmpty
        ? SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final transaction = transactions.elementAt(index);
                return Material(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionDetails(
                            transaction: transaction,
                            address: widget.address!,
                          ),
                          settings: const RouteSettings(name: '/address/details/transaction/'),
                        ),
                      );
                    },
                    highlightColor: Colors.blueGrey.shade200,
                    splashColor: Colors.blueGrey.shade500,
                    child: ListTile(
                      tileColor: Colors.white,
                      visualDensity: VisualDensity.comfortable,
                      horizontalTitleGap: 0,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildTransactionIcon(transaction),
                        ],
                      ),
                      title: transaction.isFolding
                          ? const Text('Folding')
                          : transaction.isSend
                              ? Text(
                                  PKTConversion.formatAddress(
                                      transaction.output.where((element) => element.address != widget.address!.address).elementAt(0).address),
                                  style: const TextStyle(fontSize: 14),
                                )
                              : Text(
                                  PKTConversion.formatAddress(transaction.input[0].address),
                                  style: const TextStyle(fontSize: 14),
                                ),
                      subtitle: Text(
                        PKTConversion.formatDate(transaction.firstSeen!, context),
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: transaction.isFolding
                          ? const Text('--')
                          : transaction.isSend
                              ? Text(
                                  '-${PKTConversion.toPKTFormatted(transaction.value!)}',
                                  style: const TextStyle(
                                    color: Color(0xffff007a),
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  '+${PKTConversion.toPKTFormatted(transaction.value!)}',
                                  style: const TextStyle(color: Color.fromARGB(255, 30, 200, 118), fontWeight: FontWeight.w600),
                                ),
                    ),
                  ),
                );
              },
              childCount: transactions.length,
            ),
          )
        : SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: const Center(
                child: Text('No transactions'),
              ),
            ),
          );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.address != null) {
      context.read<AddressBloc>().add(FetchAddress(widget.address!.address));
      context.read<AddressBloc>().add(FetchAddressMiningIncome(widget.address!.address));
      context.read<AddressBloc>().add(FetchAddressTransactions(widget.address!.address));

      return Stack(
        children: [
          FractionallySizedBox(
            widthFactor: 1,
            heightFactor: 0.5,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: BlocBuilder<AddressBloc, AddressState>(
                  buildWhen: (previous, current) {
                    return current is AddressInitial || current is AddressFetched;
                  },
                  builder: (context, state) {
                    if (state is AddressFetched) {
                      return AddressDetailsHeader(address: state.address, isLoading: false);
                    } else {
                      return AddressDetailsHeader(address: Address(address: widget.address!.address), isLoading: true);
                    }
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(color: Colors.black),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '30 day mining income',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 120,
                          child: BlocBuilder<AddressBloc, AddressState>(
                            buildWhen: (previous, current) {
                              return current is AddressMiningIncomeLoading || current is AddressMiningIncomeFetched;
                            },
                            builder: (context, state) {
                              if (state is AddressMiningIncomeFetched) {
                                return buildChart(state.miningIncome);
                              }

                              return buildChart(null);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: SectionHeaderDelegate('Latest transactions'),
                pinned: true,
              ),
              BlocBuilder<AddressBloc, AddressState>(
                buildWhen: (previous, current) {
                  return current is AddressTransactionsLoading || current is AddressTransactionsFetched;
                },
                builder: (context, state) {
                  if (state is AddressTransactionsFetched) {
                    return buildTransactionList(state.transactions);
                  }

                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xffff007a),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }
}

class SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final double height;

  SectionHeaderDelegate(this.title, [this.height = 50]);

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(title),
        ),
      ),
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}
