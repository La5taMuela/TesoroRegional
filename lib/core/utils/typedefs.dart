// Core type definitions
class UniqueId {
  final String value;

  const UniqueId._(this.value);

  factory UniqueId.fromString(String value) => UniqueId._(value);
  factory UniqueId.generate() => UniqueId._(DateTime.now().millisecondsSinceEpoch.toString());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UniqueId && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
