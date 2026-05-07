import 'package:flutter/material.dart';

class CardTile extends StatelessWidget {
  final bool isFaceUp;
  final bool isMatched;
  final String faceText;
  final VoidCallback? onTap;

  const CardTile({
    super.key,
    required this.isFaceUp,
    required this.isMatched,
    required this.faceText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bg = isMatched
        ? colorScheme.primaryContainer
        : (isFaceUp ? colorScheme.secondaryContainer : colorScheme.surfaceContainerHighest);

    final fg = isMatched
        ? colorScheme.onPrimaryContainer
        : (isFaceUp ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              isFaceUp ? faceText : '?',
              key: ValueKey(isFaceUp),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

