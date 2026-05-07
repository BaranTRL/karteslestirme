import 'package:flutter/foundation.dart';

import '../../models/game_settings.dart';
import 'game_engine.dart';
import 'memory_game_engine.dart';

class GameController extends ChangeNotifier {
  final GameEngine _engine;

  bool _isBusy = false;
  bool get isBusy => _isBusy;

  GameController({required GameEngine engine}) : _engine = engine;

  GameSettings get settings => _engine.settings;
  int get moves => _engine.moves;
  bool get isCompleted => _engine.isCompleted;
  int get cardCount => _engine.cards.length;

  bool cardIsFaceUp(int index) => _engine.cards[index].isFaceUp;
  bool cardIsMatched(int index) => _engine.cards[index].isMatched;
  int cardPairId(int index) => _engine.cards[index].pairId;

  void start(GameSettings settings) {
    _engine.newGame(settings);
    notifyListeners();
  }

  Future<void> selectCard(int index) async {
    if (_isBusy || isCompleted) return;

    _engine.onCardSelected(index);
    notifyListeners();

    // Eğer iki adet eşleşmemiş açık kart varsa kısa bir süre gösterip kapat.
    final faceUpUnmatched = _engine.cards.where((c) => c.isFaceUp && !c.isMatched).length;
    if (faceUpUnmatched == 2) {
      _isBusy = true;
      notifyListeners();

      await Future<void>.delayed(const Duration(milliseconds: 650));

      if (_engine is MemoryGameEngine) {
        (_engine as MemoryGameEngine).hideUnmatchedFaceUpCards();
      }

      _isBusy = false;
      notifyListeners();
    }
  }
}

