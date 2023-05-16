import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String? email;

  @HiveField(2)
  int balance;

  @HiveField(3)
  int? salary;

  @HiveField(4)
  String? kraPin;

  @HiveField(5)
  int? maxLoan;

  @HiveField(6)
  int? status;

  @HiveField(7)
  int? companyId;

  @HiveField(8)
  bool? canBorrow;

  @HiveField(9)
  List<dynamic>? cannotBorrowReason;

  @HiveField(10)
  Map<String, dynamic>? outstandingLoan;

  UserModel({
    required this.name,
    required this.email,
    required this.balance,
    required this.salary,
    required this.kraPin,
    required this.maxLoan,
    required this.status,
    required this.companyId,
    required this.canBorrow,
    required this.cannotBorrowReason,
    required this.outstandingLoan,
  });
}
