import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/preference_keys.dart';
import '../../../enums/device_type.dart';
import '../../../enums/form_color_mode.dart';
import '../../../enums/text_field_theme.dart';
import '../../../helpers/arguments/create_update_portfolio_arguments.dart';
import '../../../services/database-address/bloc/database_address_bloc.dart';
import '../../../services/database-portfolio/bloc/database_portfolio_bloc.dart';
import '../../../services/database-portfolio/database_portfolio.dart';
import '../../../services/database-portfolio/db_portfolio_service.dart';
import '../../../utilities/generics/get_arguments.dart';
import '../../../widgets/custom_text_field.dart';

class PortfolioEditWidget extends StatefulWidget {
  const PortfolioEditWidget({super.key, this.colorMode = FormColorMode.dark, this.disableScroll = false});

  final FormColorMode colorMode;
  final bool disableScroll;

  @override
  State<PortfolioEditWidget> createState() => _PortfolioEditWidgetState();
}

class _PortfolioEditWidgetState extends State<PortfolioEditWidget> {
  DatabasePortfolio? _portfolio;
  late final TextEditingController _textControllerLabel;
  late final DatabasePortfolioService _portfolioDatabaseService;

  bool portfolioIsInvalid = false;
  late String selectedPortfolioID;

  double deviceHeight(BuildContext context) => MediaQuery.of(context).size.height;
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;

  DeviceType getDeviceType() {
    final MediaQueryData data = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.single);
    return data.size.shortestSide < 550 ? DeviceType.phone : DeviceType.tablet;
  }

  @override
  void initState() {
    _textControllerLabel = TextEditingController();

    _portfolioDatabaseService = DatabasePortfolioService();

    super.initState();
  }

  void _getExistingPortfolio() {
    final args = context.getArgument<CreateUpdatePortfolioArguments>();
    final widgetPortfolio = args?.portfolio;

    if (widgetPortfolio != null) {
      _portfolio = widgetPortfolio;
      _textControllerLabel.text = _portfolio!.label;
    }
  }

  Future<bool> createPortfolio() async {
    String labelText = _textControllerLabel.text;

    if (labelText.isNotEmpty) {
      DatabasePortfolio newPortfolio = await _portfolioDatabaseService.createPortfolio(label: labelText);
      if (context.mounted) {
        context.read<DatabasePortfolioBloc>().add(SelectPortfolio(newPortfolio.documentId));
        context.read<DatabasePortfolioBloc>().add(const LoadPortfolios());
        context.read<DatabaseAddressBloc>().add(LoadAddresses(newPortfolio.documentId));
      }
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updatePortfolio() async {
    String labelText = _textControllerLabel.text;

    if (labelText.isNotEmpty) {
      await _portfolioDatabaseService.updatePortfolio(
        documentId: _portfolio!.documentId,
        label: labelText,
        displayOrder: _portfolio!.displayOrder,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      int selectedPortfolioID = prefs.getInt(selectedPortfolioIdKey) ?? -1;

      if (selectedPortfolioID != -1 && selectedPortfolioID == _portfolio!.documentId) {
        prefs.setString(selectedPortfolioNameKey, labelText);
      }

      if (context.mounted) context.read<DatabasePortfolioBloc>().add(const LoadPortfolios());

      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _textControllerLabel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _getExistingPortfolio();

    return Builder(
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  theme: widget.colorMode == FormColorMode.dark ? TextFieldTheme.dark : TextFieldTheme.light,
                  elevation: 0,
                  hintText: 'Give this portfolio a name',
                  horizontalPadding: deviceHeight(context) / 62,
                  verticalPadding: deviceHeight(context) / 62,
                ),
                const SizedBox(height: 30),
                getDeviceType() == DeviceType.phone ? const Spacer() : const SizedBox(height: 30.0),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffff007a),
                      padding: EdgeInsets.all(deviceHeight(context) / 62),
                    ),
                    onPressed: () async {
                      if (_portfolio != null) {
                        bool result = await updatePortfolio();
                        if (result) {
                          if (context.mounted) Navigator.pop(context, true);
                        } else {
                          setState(() {});
                        }
                      } else {
                        bool result = await createPortfolio();
                        if (result) {
                          if (context.mounted) Navigator.pop(context, true);
                        } else {
                          setState(() {});
                        }
                      }
                    },
                    child: _portfolio != null ? const Text('Update portfolio') : const Text('Create portfolio'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
