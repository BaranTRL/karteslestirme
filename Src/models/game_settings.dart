import 'dart:convert';

class GameSettings {
  final int _pairCount;
  final int _columns;

  const GameSettings({
    required int pairCount,
    required int columns,
  })  : _pairCount = pairCount,
        _columns = columns;

  int get pairCount => _pairCount;
  int get columns => _columns;

  static GameSettings easy() => const GameSettings(pairCount: 6, columns: 3);
  static GameSettings medium() => const GameSettings(pairCount: 8, columns: 4);
  static GameSettings hard() => const GameSettings(pairCount: 10, columns: 5);

  /// Kullanıcıdan gelen ayarı JSON string olarak alıp doğrular.
  /// Hatalı girişlerde `FormatException` fırlatır (UI katmanı yakalayacak).
  factory GameSettings.fromJsonString(String json) {
    final dynamic decoded = jsonDecode(json);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('JSON bir nesne (object) olmalı.');
    }

    final pairCount = decoded['pairCount'];
    final columns = decoded['columns'];

    if (pairCount is! int || columns is! int) {
      throw const FormatException('"pairCount" ve "columns" integer olmalı.');
    }
    if (pairCount < 2 || pairCount > 20) {
      throw const FormatException('"pairCount" 2-20 arası olmalı.');
    }
    if (columns < 2 || columns > 6) {
      throw const FormatException('"columns" 2-6 arası olmalı.');
    }

    return GameSettings(pairCount: pairCount, columns: columns);
  }
}
