class GameCard {
  final int _pairId;
  bool _isFaceUp;
  bool _isMatched;

  GameCard({
    required int pairId,
    bool isFaceUp = false,
    bool isMatched = false,
  })  : _pairId = pairId,
        _isFaceUp = isFaceUp,
        _isMatched = isMatched;

  int get pairId => _pairId;
  bool get isFaceUp => _isFaceUp;
  bool get isMatched => _isMatched;

  void reveal() {
    if (_isMatched) return;
    _isFaceUp = true;
  }

  void hide() {
    if (_isMatched) return;
    _isFaceUp = false;
  }

  void markMatched() {
    _isMatched = true;
    _isFaceUp = true;
  }
}
