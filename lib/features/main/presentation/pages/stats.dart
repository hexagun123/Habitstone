import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Using withAlpha for the background. 240 is mostly opaque.
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(240),
      appBar: AppBar(
        title: const Text('[ System Status ]'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: const Center(
        child: StatsView(),
      ),
    );
  }
}

class StatsView extends ConsumerWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          // 217 is ~85% opaque
          color: colorScheme.surface.withAlpha(217),
          // 128 is 50% opaque
          border: Border.all(color: colorScheme.primary.withAlpha(128)),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              // 51 is ~20% opaque
              color: colorScheme.primary.withAlpha(51),
              blurRadius: 12.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Text(
              'S T A T U S',
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.primary,
                letterSpacing: 4,
              ),
            ),
            const _CustomDivider(),

            // Info Section
            const _StatRowPlaceholder(label: 'Name', valueWidth: 120),
            const SizedBox(height: 8),
            const _StatRowPlaceholder(label: 'Level', valueWidth: 50),
            const SizedBox(height: 16),

            // Main Stats Section
            Text(
              'A T T R I B U T E S',
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.secondary,
                letterSpacing: 2,
              ),
            ),
            const _CustomDivider(),

            // Your requested sections with placeholders
            _StatRowPlaceholder(
              label: 'Essence',
              valueWidth: 60,
              icon: Icons.whatshot, // Fire icon
              iconColor: colorScheme.error,
            ),
            const SizedBox(height: 8),
            _StatRowPlaceholder(
              label: 'Strength',
              valueWidth: 60,
              icon: Icons.fitness_center,
              iconColor: colorScheme.secondary,
            ),
            const SizedBox(height: 8),
            _StatRowPlaceholder(
              label: 'Agility',
              valueWidth: 60,
              icon: Icons.flash_on,
              iconColor: colorScheme.tertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// A stylized divider for the stats panel.
class _CustomDivider extends StatelessWidget {
  const _CustomDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        height: 1.5,
        // 128 is 50% opaque
        color: Theme.of(context).colorScheme.primary.withAlpha(128),
      ),
    );
  }
}

/// A reusable placeholder for a single stat row.
class _StatRowPlaceholder extends StatelessWidget {
  final String label;
  final double valueWidth;
  final IconData? icon;
  final Color? iconColor;

  const _StatRowPlaceholder({
    required this.label,
    this.valueWidth = 80.0,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final placeholderDecoration = BoxDecoration(
      // 128 is 50% opaque
      color: colorScheme.surface.withAlpha(128),
      border: Border.all(color: colorScheme.outline.withAlpha(128)),
      borderRadius: BorderRadius.circular(4.0),
    );

    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon,
              color: iconColor ?? colorScheme.onSurfaceVariant, size: 20),
          const SizedBox(width: 12),
        ],

        // --- THE FIX IS HERE ---
        // 1. Wrap the flexible parts of the Row in an Expanded widget.
        // This tells the Row to give all remaining space to this group.
        Expanded(
          child: Row(
            children: [
              // 2. The Text now has a defined parent, so it's not expanding infinitely.
              Text(
                label,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              // 3. This Expanded now works correctly. It asks its parent Row:
              // "How much space is left?" and fills it. This is a finite amount.
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '.' * 50,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(color: colorScheme.outline.withAlpha(102)),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 4. The value placeholder is outside the Expanded, so it retains its fixed width.
        Container(
          height: 20.0,
          width: valueWidth,
          decoration: placeholderDecoration,
        ),
      ],
    );
  }
}
