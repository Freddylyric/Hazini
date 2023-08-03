import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String? name;

  @HiveField(1)
  String? email;

  @HiveField(2)
  String? balance;

  @HiveField(3)
  String? salary;

  @HiveField(4)
  String? kraPin;

  @HiveField(5)
  String? maxLoan;

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
     this.name,
     this.email,
    this.balance,
     this.salary,
     this.kraPin,
     this.maxLoan,
     this.status,
     this.companyId,
     this.canBorrow,
     this.cannotBorrowReason,
     this.outstandingLoan,
  });
}
