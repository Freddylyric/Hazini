import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final int userStatus;

  @HiveField(3)
  final String loanAmount;

  @HiveField(4)
  final String balance;

  @HiveField(5)
  final String createdAt;

  @HiveField(6)
  final int profileId;

  @HiveField(7)
  final String nationalIdNumber;

  @HiveField(8)
  final String fullNames;

  @HiveField(9)
  final String phoneNumber;

  @HiveField(10)
  final Map<String, dynamic>? email;

  @HiveField(11)
  final Map<String, dynamic>? kraPinNumber;

  @HiveField(12)
  final Map<String, dynamic>? dateOfBirth;

  @HiveField(13)
  final Map<String, dynamic>? nextOfKin;

  @HiveField(14)
  final Map<String, dynamic>? nextOfKinRelationship;

  @HiveField(15)
  final String? companyName;

  @HiveField(16)
  final Map<String, dynamic>? payrollNumber;

  // Add more fields as needed...

  UserModel( {
    required this.id,
    required this.username,
    required this.userStatus,
    required this.loanAmount,
    required this.balance,
    required this.createdAt,
    required this.profileId,
    required this.nationalIdNumber,
    required this.fullNames,
    required this.phoneNumber,
    this.email,
    this.kraPinNumber,
    this.dateOfBirth,
    this.nextOfKin,
    this.nextOfKinRelationship,
    this.companyName,
    this.payrollNumber,
    // Add more constructor parameters...
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      userStatus: json['user_status'],
      loanAmount: json['loan_amount'],
      balance: json['balance'],
      createdAt: json['created_at'],
      profileId: json['profile_id'],
      nationalIdNumber: json['national_id_number'],
      fullNames: json['full_names'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      kraPinNumber: json['kra_pin_number'],
      dateOfBirth: json['date_of_birth'],
      nextOfKin: json['next_of_kin'],
      nextOfKinRelationship: json['next_of_kin_relationship'],
      companyName: json['company_name'],
      payrollNumber: json['payroll_number'],

      // Map more fields accordingly...
    );
  }
}
