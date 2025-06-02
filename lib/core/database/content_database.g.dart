// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_database.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalizedContentAdapter extends TypeAdapter<LocalizedContent> {
  @override
  final int typeId = 0;

  @override
  LocalizedContent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalizedContent(
      id: fields[0] as String,
      title: (fields[1] as Map).cast<String, String>(),
      description: (fields[2] as Map).cast<String, String>(),
      content: (fields[3] as Map).cast<String, String>(),
      category: fields[4] as String,
      lastUpdated: fields[5] as DateTime,
      lastAccessed: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LocalizedContent obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.lastUpdated)
      ..writeByte(6)
      ..write(obj.lastAccessed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalizedContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
