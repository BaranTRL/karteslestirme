import '../../models/game_card.dart';
import '../../models/game_settings.dart';
import '../shuffle/shuffler.dart';
import 'game_engine.dart';

/// Kart eşleştirme oyunu motoru.
///
/// - Kalıtım: `MemoryGameEngine`, `GameEngine`'den türetilmiştir.
/// - Polimorfizm: `Shuffler` implementasyonu dışarıdan enjekte edilir.
class MemoryGameEngine extends GameEngine {
  final Shuffler _shuffler;

  late GameSettings _settings;
  List<GameCard> _cards = const [];
  int _moves = 0;
  int? _firstSelectionIndex;
  bool _isCompleted = false;

  MemoryGameEngine({required Shuffler shuffler}) : _shuffler = shuffler;

  @override
  GameSettings get settings => _settings;

  @override
  List<GameCard> get cards => _cards;

  @override
  int get moves => _moves;

  @override
  bool get isCompleted => _isCompleted;

  @override
  void newGame(GameSettings settings) {
    _settings = settings;
    _moves = 0;
    _firstSelectionIndex = null;
    _isCompleted = false;

    final pairs = List<int>.generate(settings.pairCount, (i) => i);
    final ids = <int>[...pairs, ...pairs];
    final shuffled = _shuffler.shuffle(ids);
    _cards = shuffled.map((id) => GameCard(pairId: id)).toList(growable: false);
  }

  @override
  void onCardSelected(int index) {
    if (index < 0 || index >= _cards.length) return;

    final selected = _cards[index];
    if (selected.isMatched || selected.isFaceUp) return;

    selected.reveal();

    final firstIndex = _firstSelectionIndex;
    if (firstIndex == null) {
      _firstSelectionIndex = index;
      return;
    }

    _moves += 1;

    final firstCard = _cards[firstIndex];
    if (firstCard.pairId == selected.pairId) {
      firstCard.markMatched();
      selected.markMatched();
      _firstSelectionIndex = null;
      _isCompleted = _cards.every((c) => c.isMatched);
      return;
    }

    // Eşleşmedi: iki kart açık kalır, UI kısa bir gecikme sonrası hide çağırır.
    _firstSelectionIndex = null;
  }

  /// UI tarafından, iki kart eşleşmediğinde geri kapatmak için çağrılır.
  void hideUnmatchedFaceUpCards() {
    final faceUp = _cards.where((c) => c.isFaceUp && !c.isMatched).toList();
    if (faceUp.length != 2) return;
    for (final c in faceUp) {
      c.hide();
    }
  }
}

