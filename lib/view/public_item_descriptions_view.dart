import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:blocparty/model/item_model.dart';
import 'package:blocparty/model/messaging_model.dart';
import 'package:blocparty/model/login_model/auth_model.dart';
import 'package:blocparty/model/profile_model.dart';
import 'package:blocparty/view/widgets/item_card.dart';
import 'package:blocparty/view/widgets/ui/tokens.dart';

class PublicItemDescriptionView extends StatefulWidget {
  final Item item;
  const PublicItemDescriptionView({super.key, required this.item});

  @override
  State<PublicItemDescriptionView> createState() =>
      _PublicItemDescriptionViewState();
}

class _PublicItemDescriptionViewState extends State<PublicItemDescriptionView> {
  late ProfileViewModel _profileViewModel;
  late AuthViewModel _authViewModel;

  @override
  void initState() {
    super.initState();
    _profileViewModel = ProfileViewModel();
    _authViewModel = AuthViewModel();
  }

  // Method to show borrow request confirmation dialog
  Future<void> _showBorrowRequestDialog(BuildContext context) async {
    final currentUsername = _profileViewModel.currentUser?.username;
    if (currentUsername == null) {
      showToast(context, 'Please log in to send requests');
      return;
    }

    // check if user is trying to request their own item
    if (currentUsername == widget.item.userId) {
      showToast(context, 'You cannot request your own item');
      return;
    }

    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Request to borrow'),
          content: Text(
            'Send a borrow request for "${widget.item.name}" to the owner?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Send request'),
            ),
          ],
        );
      },
    );

    if (shouldProceed == true) {
      await _createBorrowRequestChat(context, currentUsername);
    }
  }

  // Method to create borrow request chat and navigate
  Future<void> _createBorrowRequestChat(
    BuildContext context,
    String currentUsername,
  ) async {
    try {
      // Creates messaging model instance
      final messagingModel = MessagingModel(_authViewModel);

      // Creates the borrow request chat
      final newChat = await messagingModel.createBorrowRequestChat(
        itemName: widget.item.name,
        lenderUsername: widget.item.userId,
        currentUsername: currentUsername,
      );

      if (newChat != null) {
        // Navigates directly to the new chat
        if (context.mounted) {
          context.push('/chat', extra: newChat);
          showToast(context, 'Borrow request sent!');
        }
      }
    } catch (e) {
      if (context.mounted) {
        showToast(context, 'Failed to create chat: $e');
      }
    }
  }

  void report() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanks — item reported.')),
    );
  }

  bool get _isOwnItem {
    final username = _profileViewModel.currentUser?.username;
    return username != null && username == widget.item.userId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final item = widget.item;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 340,
            backgroundColor: scheme.surface,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
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
                  // Gentle top scrim so the back button stays readable.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0, 0.18],
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  Spacing.lg, Spacing.lg, Spacing.lg, Spacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status + portability chips
                  Wrap(
                    spacing: Spacing.sm,
                    runSpacing: Spacing.sm,
                    children: [
                      item.isAvailable
                          ? StatusChip.available()
                          : StatusChip.unavailable(),
                      PortabilityChip(portability: item.portability),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Text(
                    item.name,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: Spacing.xs),
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 16, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        'Shared by ${item.userId}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Description given real room to breathe.
                  Text(
                    item.description,
                    style: theme.textTheme.bodyLarge,
                  ),
                  if (item.tags.isNotEmpty) ...[
                    const SizedBox(height: Spacing.lg),
                    Wrap(
                      spacing: Spacing.sm,
                      runSpacing: Spacing.sm,
                      children: item.tags
                          .map((tag) => StatusChip(label: tag))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: Spacing.lg),
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md, vertical: Spacing.md),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 18, color: scheme.onSurfaceVariant),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: Text(
                            'Shared in ${item.neighborhoodId.join(', ')}',
                            style: theme.textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Persistent action bar: the one decision on this screen.
      bottomNavigationBar: _buildBottomBar(context, theme, scheme),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, ThemeData theme, ColorScheme scheme) {
    if (_isOwnItem) {
      return _BottomBar(
        child: Row(
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 18, color: scheme.onSurfaceVariant),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                'This is your listing — you manage it in your profile.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    }

    return _BottomBar(
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: widget.item.isAvailable
                  ? () => _showBorrowRequestDialog(context)
                  : null,
              child: Text(widget.item.isAvailable
                  ? 'Request to borrow'
                  : 'Currently borrowed'),
            ),
          ),
          const SizedBox(width: Spacing.md),
          IconButton.outlined(
            tooltip: 'Report this item',
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
            ),
            onPressed: report,
            icon: const Icon(Icons.flag_outlined),
          ),
        ],
      ),
    );
  }
}

/// Bottom action container: surface + hairline top edge + safe-area padding.
class _BottomBar extends StatelessWidget {
  final Widget child;

  const _BottomBar({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg, vertical: Spacing.md),
          child: child,
        ),
      ),
    );
  }
}
