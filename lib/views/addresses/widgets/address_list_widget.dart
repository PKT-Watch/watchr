import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/database-address/bloc/database_address_bloc.dart';
import '../../../services/database-address/database_address.dart';
import '../../../services/database-address/db_address_service.dart';
import '../../../utilities/tools/conversion.dart';
import 'address_list_item_widget.dart';

typedef AddressCallback = void Function(DatabaseAddress address);
typedef RefreshCallback = void Function();
typedef MakeReorderableCallback = void Function();
typedef AddressBalanceCallback = void Function(double balance);

class AddressListWidget extends StatefulWidget {
  final Iterable<DatabaseAddress> addresses;
  final RefreshCallback onRefresh;
  bool? isReorderable;
  AddressBalanceCallback? onBalanceUpdated;
  final int portfolioId;

  AddressListWidget({
    super.key,
    required this.addresses,
    required this.onRefresh,
    required this.portfolioId,
    this.onBalanceUpdated,
    this.isReorderable,
  });

  @override
  State<AddressListWidget> createState() => _AddressListWidgetState();
}

class _AddressListWidgetState extends State<AddressListWidget> {
  late final DatabaseAddressService _addressesDatabaseService;

  Widget buildAddressListItem(DatabaseAddress address, int index) {
    if (widget.isReorderable != null && widget.isReorderable!) {
      return Padding(
        key: Key('$index'),
        padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const Icon(
                Icons.drag_indicator,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  address.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  PKTConversion.formatAddress(address.address),
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return AddressListItemWidget(
      key: UniqueKey(),
      address: address,
      portfolioId: widget.portfolioId,
    );
  }

  @override
  void initState() {
    _addressesDatabaseService = DatabaseAddressService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final lstAddresses = widget.addresses.toList();
    return RefreshIndicator(
      notificationPredicate: widget.isReorderable != null && widget.isReorderable! ? (_) => false : (_) => true,
      onRefresh: () async {
        context.read<DatabaseAddressBloc>().add(LoadAddresses(widget.portfolioId));
      },
      color: const Color(0xffff007a),
      backgroundColor: Colors.white,
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
        ),
        child: ReorderableListView.builder(
          buildDefaultDragHandles: false,
          padding: const EdgeInsets.only(bottom: 30),
          itemCount: widget.addresses.length,
          itemBuilder: (context, index) {
            return buildAddressListItem(lstAddresses.elementAt(index), index);
          },
          onReorder: (int oldIndex, int newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final DatabaseAddress item = lstAddresses.removeAt(oldIndex);
            lstAddresses.insert(newIndex, item);

            for (var i = 0; i < lstAddresses.length; i++) {
              _addressesDatabaseService.updateAddress(
                documentId: lstAddresses[i].documentId,
                label: lstAddresses[i].label,
                address: lstAddresses[i].address,
                portfolioID: lstAddresses[i].portfolioID,
                displayOrder: i,
              );
            }
          },
        ),
      ),
    );
  }
}
