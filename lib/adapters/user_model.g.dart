// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      name: fields[0] as String?,
      email: fields[1] as String?,
      balance: fields[2] as String?,
      salary: fields[3] as String?,
      kraPin: fields[4] as String?,
      maxLoan: fields[5] as String?,
      status: fields[6] as int?,
      companyId: fields[7] as int?,
      canBorrow: fields[8] as bool?,
      cannotBorrowReason: (fields[9] as List?)?.cast<dynamic>(),
      outstandingLoan: (fields[10] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.balance)
      ..writeByte(3)
      ..write(obj.salary)
      ..writeByte(4)
      ..write(obj.kraPin)
      ..writeByte(5)
      ..write(obj.maxLoan)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.companyId)
      ..writeByte(8)
      ..write(obj.canBorrow)
      ..writeByte(9)
      ..write(obj.cannotBorrowReason)
      ..writeByte(10)
      ..write(obj.outstandingLoan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
