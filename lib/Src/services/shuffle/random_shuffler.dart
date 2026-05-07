import 'dart:math';

import 'shuffler.dart';

class RandomShuffler extends Shuffler {
  final Random _random;

  RandomShuffler({Random? random}) : _random = random ?? Random();

  @override
  List<T> shuffle<T>(List<T> items) {
    final copy = List<T>.of(items);
    for (var i = copy.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final tmp = copy[i];
      copy[i] = copy[j];
      copy[j] = tmp;
    }
    return copy;
  }
}

