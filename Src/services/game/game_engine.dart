import '../../models/game_card.dart';
import '../../models/game_settings.dart';

abstract class GameEngine {
  GameSettings get settings;
  List<GameCard> get cards;

  int get moves;
  bool get isCompleted;

  void newGame(GameSettings settings);

  /// Seçim sonucu durum değişebilir; UI bunu dinleyip yeniden çizer.
  void onCardSelected(int index);
}

