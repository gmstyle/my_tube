import 'package:flutter/material.dart';

/// Full-page centered empty state shown when no personalized content is available.
class MusicEmptyState extends StatelessWidget {
  const MusicEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.music_note_outlined,
                size: 72, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
            const SizedBox(height: 20),
            Text(
              'Your music, your way',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Save some favorites to get personalized picks',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
