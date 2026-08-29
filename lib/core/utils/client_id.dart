int _sequence = 0;

String clientId(String prefix) {
  final milliseconds = DateTime.now().millisecondsSinceEpoch;
  final randomPart = (milliseconds ^ (_sequence++ << 8)).toRadixString(36);
  return '${prefix}_${milliseconds}_$randomPart';
}
