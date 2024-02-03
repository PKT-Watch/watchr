import 'package:flutter/material.dart';
import 'widgets/address_edit_widget.dart';

class AddressEditView extends StatelessWidget {
  const AddressEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Address'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: const AddressEditWidget(),
    );
  }
}
