import 'package:flutter/material.dart';

import 'package:blocparty/model/item_model.dart';
import 'package:blocparty/view/widgets/ui/tokens.dart';

/// Small label chip used for availability + portability.
/// Full background tints instead of side-stripe hacks.
class StatusChip extends StatelessWidget {
  static StatusChip available() =>
      const StatusChip(label: 'Available', accent: true);
  static StatusChip unavailable() => const StatusChip(label: 'Borrowed');

  final String label;
  final bool accent;
  final IconData? icon;

  const StatusChip({super.key, required this.label, this.accent = false, this.icon});

  factory StatusChip.tag(String text) =>
      StatusChip(label: text);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color bg, Color fg) = accent
        ? (scheme.primaryContainer, scheme.onPrimaryContainer)
        : (scheme.surfaceContainerHighest, scheme.onSurfaceVariant);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm + 2, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Gabarito',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// The card the whole app is built around: photo first, honest text below,
/// availability readable at a glance.
class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback? onTap;

  const ItemCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The photo is the hero; everything else supports it.
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    item.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/confused-person.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: Spacing.sm,
                    right: Spacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm, vertical: 3),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: item.isAvailable
                                  ? scheme.primary
                                  : scheme.outline,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.isAvailable ? 'Available' : 'Borrowed',
                            style: TextStyle(
                              fontFamily: 'Gabarito',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Spacing.md, Spacing.sm + 2, Spacing.md, Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Portability badge shown on item detail screens.
class PortabilityChip extends StatelessWidget {
  final ItemPortability portability;

  const PortabilityChip({super.key, required this.portability});

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (portability) {
      ItemPortability.portable => (Icons.backpack_outlined, 'Easy to carry'),
      ItemPortability.semiPortable => (Icons.local_shipping_outlined, 'Fits in a car'),
      ItemPortability.immovable => (Icons.home_work_outlined, 'Pickup only'),
    };
    return StatusChip(icon: icon, label: label);
  }
}
