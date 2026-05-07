import 'package:flutter/material.dart';

import '../../models/game_settings.dart';
import '../../services/game/game_controller.dart';
import '../../services/game/memory_game_engine.dart';
import '../../services/shuffle/random_shuffler.dart';
import '../widgets/card_tile.dart';

enum Difficulty { easy, medium, hard, custom }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final GameController _controller;

  Difficulty _difficulty = Difficulty.easy;
  GameSettings _customSettings = GameSettings.easy();

  static const _symbols = <String>[
    '🍀',
    '⭐',
    '🔥',
    '🎯',
    '🎲',
    '🎵',
    '⚡',
    '🌙',
    '🍎',
    '🧩',
    '🚀',
    '🐱',
    '🏁',
    '🎁',
    '💡',
    '📌',
    '🧠',
    '🌈',
    '🧱',
    '📦',
  ];

  @override
  void initState() {
    super.initState();
    _controller = GameController(
      engine: MemoryGameEngine(shuffler: RandomShuffler()),
    )..addListener(_onControllerChanged);

    _controller.start(_currentSettings());
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});

    if (_controller.isCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Tebrikler!'),
            content: Text('Oyun bitti. Hamle: ${_controller.moves}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kapat'),
              ),
            ],
          ),
        );
      });
    }
  }

  String _faceTextForPairId(int pairId) {
    if (pairId >= 0 && pairId < _symbols.length) return _symbols[pairId];
    return pairId.toString();
  }

  Future<void> _newGame() async {
    _controller.start(_currentSettings());
  }

  Future<void> _showCustomSettingsDialog() async {
    final current = _currentSettings();
    final controller = TextEditingController(
      text: '{ "pairCount": ${current.pairCount}, "columns": ${current.columns} }',
    );

    GameSettings? result;
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Özel Ayar (JSON)'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Örnek: { "pairCount": 8, "columns": 4 }'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'JSON',
                      errorText: errorText,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Vazgeç'),
                ),
                FilledButton(
                  onPressed: () {
                    try {
                      // Zorunlu hata yönetimi: kullanıcı girdisi try-catch ile kontrol ediliyor.
                      result = GameSettings.fromJsonString(controller.text);
                      Navigator.of(context).pop();
                    } catch (e) {
                      setLocalState(() {
                        errorText = e.toString().replaceFirst('FormatException: ', '');
                      });
                    }
                  },
                  child: const Text('Uygula'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        _customSettings = result!;
        _difficulty = Difficulty.custom;
      });
      await _newGame();
    }
  }

  GameSettings _currentSettings() {
    return switch (_difficulty) {
      Difficulty.easy => GameSettings.easy(),
      Difficulty.medium => GameSettings.medium(),
      Difficulty.hard => GameSettings.hard(),
      Difficulty.custom => _customSettings,
    };
  }

  @override
  Widget build(BuildContext context) {
    final settings = _currentSettings();
    final gridPadding = MediaQuery.of(context).padding;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kart Eşleştirme'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('Hamle: ${_controller.moves}'),
            ),
          ),
          IconButton(
            tooltip: 'Yeni Oyun',
            onPressed: _controller.isBusy ? null : _newGame,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Özel Ayar (JSON)',
            onPressed: _controller.isBusy ? null : _showCustomSettingsDialog,
            icon: const Icon(Icons.tune),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + gridPadding.bottom),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<Difficulty>(
                      segments: const [
                        ButtonSegment(
                          value: Difficulty.easy,
                          label: Text('Kolay'),
                        ),
                        ButtonSegment(
                          value: Difficulty.medium,
                          label: Text('Orta'),
                        ),
                        ButtonSegment(
                          value: Difficulty.hard,
                          label: Text('Zor'),
                        ),
                        ButtonSegment(
                          value: Difficulty.custom,
                          label: Text('Özel'),
                        ),
                      ],
                      selected: {_difficulty},
                      onSelectionChanged: _controller.isBusy
                          ? null
                          : (selection) {
                              final selected = selection.first;
                              setState(() => _difficulty = selected);
                              _controller.start(_currentSettings());
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = settings.columns;
                    final spacing = 10.0;
                    final tileSize = (constraints.maxWidth - (columns - 1) * spacing) / columns;

                    return GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: 1,
                        mainAxisExtent: tileSize,
                      ),
                      itemCount: _controller.cardCount,
                      itemBuilder: (context, index) {
                        final isFaceUp = _controller.cardIsFaceUp(index);
                        final isMatched = _controller.cardIsMatched(index);
                        final pairId = _controller.cardPairId(index);
                        final text = _faceTextForPairId(pairId);

                        return CardTile(
                          isFaceUp: isFaceUp,
                          isMatched: isMatched,
                          faceText: text,
                          onTap: (_controller.isBusy || isMatched)
                              ? null
                              : () => _controller.selectCard(index),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ayar: ${settings.pairCount} çift • ${settings.pairCount * 2} kart • ${settings.columns} sütun',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

