// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'piece_category_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PieceCategoryDtoAdapter extends TypeAdapter<PieceCategoryDto> {
  @override
  final int typeId = 2;

  @override
  PieceCategoryDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PieceCategoryDto(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      iconPath: fields[3] as String,
      totalPieces: fields[4] as int,
      collectedPieces: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PieceCategoryDto obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.iconPath)
      ..writeByte(4)
      ..write(obj.totalPieces)
      ..writeByte(5)
      ..write(obj.collectedPieces);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PieceCategoryDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
