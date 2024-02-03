import 'package:flutter/material.dart';
import '../database-address/database_address.dart';
import '../../constants/db_storage_constants.dart';

@immutable
class DatabasePortfolio {
  final int documentId;
  final String ownerUserId;
  final String label;
  final int displayOrder;
  final int createdAt;
  List<DatabaseAddress> addresses;

  DatabasePortfolio({
    required this.documentId,
    required this.ownerUserId,
    required this.label,
    required this.displayOrder,
    required this.createdAt,
    this.addresses = const [],
  });

  DatabasePortfolio.fromRow(Map<String, Object?> map)
      : documentId = (map[idColumn] as int),
        ownerUserId = '',
        label = map[labelColumn] as String,
        displayOrder = map[displayOrderColumn] as int,
        createdAt = map[createdAtColumn] as int,
        addresses = [];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['documentId'] = documentId;
    data['label'] = label;
    data['displayOrder'] = displayOrder;
    data['createdAt'] = createdAt;
    data['addresses'] = addresses;
    return data;
  }

  factory DatabasePortfolio.fromJson(Map<String, dynamic> json) => DatabasePortfolio(
        documentId: json['documentId'],
        ownerUserId: '',
        label: json['label'],
        displayOrder: json['displayOrder'],
        createdAt: json['createdAt'],
        addresses: (json["addresses"] as List).map((item) => DatabaseAddress.fromJson(item)).toList(),
      );
}
