import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/preference_keys.dart';
import '../../../enums/form_color_mode.dart';
import '../../../enums/text_field_theme.dart';
import '../../../services/api/api.dart';
import '../../../services/database-address/bloc/database_address_bloc.dart';
import '../../../services/database-address/database_address.dart';
import '../../../services/database-address/db_address_service.dart';
import '../../../services/database-portfolio/bloc/database_portfolio_bloc.dart';
import '../../../services/database-portfolio/database_portfolio.dart';
import '../../../services/database-portfolio/db_portfolio_service.dart';
import '../../../utilities/generics/get_arguments.dart';
import '../../../widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;

class AddressEditWidget extends StatefulWidget {
  const AddressEditWidget({super.key, this.colorMode = FormColorMode.dark, this.disableScroll = false});

  final FormColorMode colorMode;
  final bool disableScroll;

  @override
  State<AddressEditWidget> createState() => _AddressEditWidgetState();
}

class _AddressEditWidgetState extends State<AddressEditWidget> {
  DatabaseAddress? _address;
  late final DatabaseAddressService _addressesDatabaseService;
  late final DatabasePortfolioService _portfolioDatabaseService;

  late final TextEditingController _textControllerAddress;
  late final TextEditingController _textControllerLabel;

  late final int selectedPortfolioId;

  List<DatabasePortfolio>? portfolios;
  List<String>? portfolioLabels;
  DatabasePortfolio? selectedPortfolio;

  double deviceHeight(BuildContext context) => MediaQuery.of(context).size.height;
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;

  bool addressIsInvalid = false;
  late String dropdownValue;

  @override
  void initState() {
    _addressesDatabaseService = DatabaseAddressService();
    _portfolioDatabaseService = DatabasePortfolioService();

    _textControllerAddress = TextEditingController();
    _textControllerLabel = TextEditingController();

    super.initState();
  }

  Future<List<DatabasePortfolio>?> getPortfolios() async {
    if (portfolios != null) return portfolios;

    Iterable<DatabasePortfolio> tempPortfolios;

    tempPortfolios = await _portfolioDatabaseService.getAllPortfolios();
    portfolioLabels = tempPortfolios.map((e) => e.label).toList();
    portfolios = tempPortfolios.toList();

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    selectedPortfolioId = prefs.getInt(selectedPortfolioIdKey) ?? -1;

    if (prefs.getString(selectedPortfolioNameKey) != null) {
      dropdownValue = prefs.getString(selectedPortfolioNameKey)!;
    } else if (portfolioLabels != null && portfolioLabels!.isNotEmpty) {
      dropdownValue = portfolioLabels![0];
    } else {
      dropdownValue = '';
    }

    selectedPortfolio = portfolios![portfolioLabels!.indexOf(dropdownValue)];

    return portfolios;
  }

  void _getExistingAddress() {
    final widgetAddress = context.getArgument<DatabaseAddress>();

    if (widgetAddress != null) {
      _address = widgetAddress;
      _textControllerAddress.text = _address!.address;
      _textControllerLabel.text = _address!.label;
    }
  }

  Future<bool> createAddress() async {
    final addressText = _textControllerAddress.text;
    String labelText = _textControllerLabel.text;

    if (addressText.isNotEmpty) {
      bool result = await loadAddress(addressText);

      if (!result) {
        return false;
      }

      if (labelText.isEmpty) {
        labelText = 'Address ${addressText.substring(addressText.length - 6)}';
      }

      try {
        await _addressesDatabaseService.createAddress(
          label: labelText,
          address: addressText,
          portfolioID: selectedPortfolio!.documentId,
          addToStream: (selectedPortfolioId == selectedPortfolio!.documentId),
        );

        if (context.mounted) {
          context.read<DatabasePortfolioBloc>().add(SelectPortfolio(selectedPortfolio!.documentId));
          context.read<DatabasePortfolioBloc>().add(const LoadPortfolios());
          context.read<DatabaseAddressBloc>().add(LoadAddresses(selectedPortfolio!.documentId));
        }
      } catch (e) {
        // Address already exists
      }

      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateAddress() async {
    String addressText = _textControllerAddress.text;
    String labelText = _textControllerLabel.text;

    if (labelText.isNotEmpty) {
      await _addressesDatabaseService.updateAddress(
        documentId: _address!.documentId,
        address: addressText,
        label: labelText,
        portfolioID: selectedPortfolio!.documentId,
        displayOrder: _address!.displayOrder,
      );
      return true;
    } else {
      return false;
    }
  }

  Future<bool> loadAddress(String address) async {
    const invalidSnackBar = SnackBar(
      content: Text('That address doesn\'t seem to be a valid PKT address.'),
      backgroundColor: Colors.red,
    );

    final response = await http.get(Uri.parse('${API.getUrl()}/address/$address'));
    if (response.statusCode == 200) {
      return true;
    } else {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(invalidSnackBar);

      return false;
    }
  }

  @override
  void dispose() {
    _textControllerAddress.dispose();
    _textControllerLabel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getPortfolios(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _getExistingAddress();

          return CustomScrollView(
            physics: widget.disableScroll ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            'Address',
                            style: TextStyle(color: widget.colorMode == FormColorMode.dark ? Colors.grey.shade200 : Colors.grey.shade600),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Stack(
                          children: [
                            CustomtextField(
                              textEditingController: _textControllerAddress,
                              textInputAction: TextInputAction.next,
                              theme: widget.colorMode == FormColorMode.dark ? TextFieldTheme.dark : TextFieldTheme.light,
                              elevation: 0,
                              hintText: 'Enter a PKT address',
                              horizontalPadding: deviceHeight(context) / 62,
                              verticalPadding: deviceHeight(context) / 62,
                            ),
                            Positioned(
                              top: 14.0,
                              right: 14.0,
                              child: GestureDetector(
                                onTap: () async {
                                  var result = await BarcodeScanner.scan(
                                    options: const ScanOptions(restrictFormat: [BarcodeFormat.qr]),
                                  );
                                  if (result.type == ResultType.Barcode) {
                                    bool isValidAddress = await loadAddress(result.rawContent);
                                    if (isValidAddress) {
                                      _textControllerAddress.text = result.rawContent;
                                    }
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1.0, color: Colors.grey.shade400),
                                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                    color: Colors.black,
                                  ),
                                  child: Icon(
                                    Icons.qr_code_2,
                                    color: Colors.grey.shade400,
                                    size: 36,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            'Label',
                            style: TextStyle(color: widget.colorMode == FormColorMode.dark ? Colors.grey.shade200 : Colors.grey.shade600),
                          ),
                        ),
                        const SizedBox(height: 5),
                        CustomtextField(
                          textEditingController: _textControllerLabel,
                          textInputAction: TextInputAction.next,
                          theme: widget.colorMode == FormColorMode.dark ? TextFieldTheme.dark : TextFieldTheme.light,
                          elevation: 0,
                          hintText: 'Give this address a name',
                          horizontalPadding: deviceHeight(context) / 62,
                          verticalPadding: deviceHeight(context) / 62,
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            'Portfolio',
                            style: TextStyle(color: widget.colorMode == FormColorMode.dark ? Colors.grey.shade200 : Colors.grey.shade600),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: DropdownButton<String>(
                              value: portfolioLabels![0],
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_downward),
                              elevation: 8,
                              underline: Container(
                                height: 0,
                              ),
                              onChanged: (String? value) {
                                setState(() {
                                  dropdownValue = value!;
                                  selectedPortfolio = portfolios![portfolioLabels!.indexOf(dropdownValue)];
                                });
                              },
                              selectedItemBuilder: (BuildContext context) {
                                return portfolioLabels!.map((String value) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                                    child: Text(
                                      dropdownValue,
                                      style: TextStyle(color: widget.colorMode == FormColorMode.dark ? Colors.grey.shade200 : Colors.grey.shade600),
                                    ),
                                  );
                                }).toList();
                              },
                              items: portfolioLabels!.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 30),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffff007a),
                              padding: EdgeInsets.all(deviceHeight(context) / 62),
                            ),
                            onPressed: () async {
                              if (_address != null && _address!.documentId != '') {
                                bool result = await updateAddress();
                                if (result) {
                                  if (context.mounted) Navigator.pop(context, true);
                                } else {
                                  //
                                }
                              } else {
                                bool result = await createAddress();
                                if (result) {
                                  if (context.mounted) Navigator.pop(context, true);
                                } else {
                                  //
                                }
                              }
                            },
                            child: _address != null && _address!.documentId != ''
                                ? const Text(
                                    'Update address',
                                    style: TextStyle(fontSize: 16),
                                  )
                                : const Text(
                                    'Add address',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: const Center(child: CircularProgressIndicator(color: Color(0xffff007a))),
          );
        }
      },
    );
  }
}
