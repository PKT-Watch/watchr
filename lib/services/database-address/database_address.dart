import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../constants/db_storage_constants.dart';

@immutable
class DatabaseAddress extends Equatable {
  final String documentId;
  final String ownerUserId;
  final String address;
  String label;
  final int portfolioID;
  final int displayOrder;
  final int createdAt;
  bool isLoadingBalance;
  double balance;

  DatabaseAddress({
    required this.documentId,
    required this.ownerUserId,
    required this.address,
    required this.label,
    required this.portfolioID,
    required this.displayOrder,
    required this.createdAt,
    this.isLoadingBalance = true,
    this.balance = 0.0,
  });

  DatabaseAddress.fromRow(Map<String, Object?> map)
      : documentId = (map[idColumn] as int).toString(),
        ownerUserId = '',
        address = map[addressColumn] as String,
        label = map[labelColumn] as String,
        portfolioID = (map[portfolioIDColumn] as int),
        displayOrder = map[displayOrderColumn] as int,
        createdAt = map[createdAtColumn] as int,
        isLoadingBalance = true,
        balance = 0.0;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['documentId'] = documentId;
    data['ownerUserId'] = ownerUserId;
    data['address'] = address;
    data['label'] = label;
    data['portfolioID'] = portfolioID;
    data['displayOrder'] = displayOrder;
    data['createdAt'] = createdAt;
    return data;
  }

  DatabaseAddress.fromJson(Map<String, dynamic> json)
      : documentId = json['documentId'],
        ownerUserId = '',
        address = json['address'],
        label = json['label'],
        portfolioID = json['portfolioID'],
        displayOrder = json['displayOrder'],
        createdAt = json['createdAt'],
        isLoadingBalance = false,
        balance = 0.0;

  @override
  List<Object?> get props => [documentId, ownerUserId, address, label, portfolioID, displayOrder, createdAt, isLoadingBalance, balance];
}
