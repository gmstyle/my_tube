// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_mt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResourceMTAdapter extends TypeAdapter<ResourceMT> {
  @override
  final int typeId = 1;

  @override
  ResourceMT read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResourceMT(
      id: fields[0] as String?,
      title: fields[1] as String?,
      description: fields[2] as String?,
      channelTitle: fields[3] as String?,
      thumbnailUrl: fields[4] as String?,
      kind: fields[5] as String?,
      channelId: fields[6] as String?,
      playlistId: fields[7] as String?,
      streamUrl: fields[8] as String?,
      duration: fields[9] as int?,
      addedAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ResourceMT obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.channelTitle)
      ..writeByte(4)
      ..write(obj.thumbnailUrl)
      ..writeByte(5)
      ..write(obj.kind)
      ..writeByte(6)
      ..write(obj.channelId)
      ..writeByte(7)
      ..write(obj.playlistId)
      ..writeByte(8)
      ..write(obj.streamUrl)
      ..writeByte(9)
      ..write(obj.duration)
      ..writeByte(10)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResourceMTAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
