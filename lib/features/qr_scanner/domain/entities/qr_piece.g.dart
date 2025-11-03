// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_piece.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QRPieceAdapter extends TypeAdapter<QRPiece> {
  @override
  final int typeId = 0;

  @override
  QRPiece read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QRPiece(
      id: fields[0] as String,
      province: fields[1] as String,
      title: fields[2] as String,
      code: fields[3] as String,
      collectedAt: fields[4] as DateTime,
      isCollected: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, QRPiece obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.province)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.code)
      ..writeByte(4)
      ..write(obj.collectedAt)
      ..writeByte(5)
      ..write(obj.isCollected);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QRPieceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
