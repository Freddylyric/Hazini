import 'package:hive/hive.dart';

part 'transactions_model.g.dart';

@HiveType(typeId: 3)
class TransactionModel {
  @HiveField(0)
  final String externalReference;

  @HiveField(1)
  final String channel;

  @HiveField(2)
  final String transactionType;

  @HiveField(3)
  final String amount;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final int loanId;

  @HiveField(6)
  final int status;



  TransactionModel({

    required this.externalReference,
    required this.channel,
    required this.transactionType,
    required this.amount,
    required this.createdAt,
    required this.loanId,
    required this.status,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      externalReference: json['external_reference'],
      channel: json['channel'],
      transactionType: json['transaction_type'],
      amount: json['amount'],
      createdAt: DateTime.parse(json['created_at']),
      loanId: json['loan_id'],
      status: json['status'],
    );
  }

}
