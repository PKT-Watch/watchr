import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class PKTConversion {
  static double toPKT(String value) {
    return double.parse(value) / pow(2, 30);
  }

  static String toPKTFormatted(String value) {
    double converted = double.parse(value) / pow(2, 30);
    return formatNumber(converted);
  }

  static double toPKTFromInt(int value) {
    return value / pow(2, 30);
  }

  static String toPKTFromIntFormatted(int value) {
    double converted = value / pow(2, 30);
    return formatNumber(converted);
  }

  static String toPKTFromDoubleFormatted(double value) {
    double converted = value / pow(2, 30);
    return formatNumber(converted);
  }

  static String formatNumber(double value) {
    var formatter = NumberFormat('#,###,##0.00');
    if (value > 10000) {
      formatter = NumberFormat('#,###,##0');
    }
    return formatter.format(value);
  }

  static String formatAddress(String address) {
    return '${address.substring(0, 12)}...${address.substring(address.length - 12)}';
  }

  static String formatDate(String dateString, BuildContext context) {
    String locale = Localizations.localeOf(context).languageCode;
    initializeDateFormatting(locale);
    var dateValue = DateFormat("yyyy-MM-ddTHH:mm:ssZ").parseUTC(dateString).toLocal();
    String formattedDate = DateFormat.yMd(locale).add_jm().format(dateValue);

    return formattedDate;
  }
}
