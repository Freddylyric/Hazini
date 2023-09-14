import 'package:hive/hive.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 2)
class CustomerModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final double balance;

  @HiveField(4)
  final double salary;

  @HiveField(5)
  final String kraPin;

  @HiveField(6)
  final double maxLoan;

  @HiveField(7)
  final double minLoan;

  @HiveField(8)
  final int status;

  @HiveField(9)
  final int companyId;

  @HiveField(10)
  final bool canBorrow;

  @HiveField(11)
  final List<String> cannotBorrowReason;

  @HiveField(12)
  final Map<String, dynamic> outstandingLoan;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.balance,
    required this.salary,
    required this.kraPin,
    required this.maxLoan,
    required this.minLoan,
    required this.status,
    required this.companyId,
    required this.canBorrow,
    required this.cannotBorrowReason,
    required this.outstandingLoan,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      balance: double.parse(json['balance']),
      salary: double.parse(json['salary']),
      kraPin: json['kra_pin'],
      maxLoan: double.parse(json['max_loan']),
      minLoan: double.parse(json['min_loan']),
      status: json['status'],
      companyId: json['company_id'],
      canBorrow: json['can_borrow'],
      cannotBorrowReason: List<String>.from(json['cannot_borrow_reason']),
      outstandingLoan: json['outstanding_loan'],
    );
  }

  // Add HiveField annotations for all other fields



}
