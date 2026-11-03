import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:blocparty/model/itemview_model.dart';
import 'package:blocparty/model/item_model.dart';
import 'package:blocparty/view/widgets/item_card.dart';
import 'package:blocparty/view/widgets/item_search_filter_widget.dart';
import 'package:blocparty/model/login_model/auth_model.dart';
import 'package:blocparty/view/widgets/neighborhood_selection_widget.dart';
import 'package:blocparty/view/widgets/ui/tokens.dart';
import 'package:blocparty/model/profile_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  // Kept static so other screens can reuse the card.
  static Widget buildItemTile(
    BuildContext context,
    Item item, {
    VoidCallback? onTap,
  }) {
    return ItemCard(
      item: item,
      onTap:
          onTap ??
          () {
            context.push('/public_item_description', extra: item);
          },
    );
  }

  static String getPortabilityText(ItemPortability portability) {
    switch (portability) {
      case ItemPortability.portable:
        return 'Portable';
      case ItemPortability.semiPortable:
        return 'Semi-Portable';
      case ItemPortability.immovable:
        return 'Immovable';
    }
  }

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late ItemViewModel itemViewModel;
  late AuthViewModel authViewModel;
  // using profile view model to get current user data
  late ProfileViewModel _profileViewModel;

  @override
  void initState() {
    super.initState();

    authViewModel = AuthViewModel();

    // Initialize profile view model FIRST
    _profileViewModel = ProfileViewModel();

    // Pass username into item view model
    itemViewModel = ItemViewModel(authViewModel);

    // Add listeners
    itemViewModel.addListener(_onItemViewModelChanged);
    _profileViewModel.addListener(_onProfileViewModelChanged);
  }

  @override
  void dispose() {
    itemViewModel.removeListener(_onItemViewModelChanged);
    // Removes profile view model listener
    _profileViewModel.removeListener(_onProfileViewModelChanged);
    itemViewModel.dispose();
    authViewModel.dispose();
    super.dispose();
  }

  void _onItemViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // Listens to profile view model changes
  void _onProfileViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  //  Method to refresh items when neighborhood changes
  void _refreshItems() {
    itemViewModel.fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bloc Party')),
      body: RefreshIndicator(
        onRefresh: () async => itemViewModel.fetchItems(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
              Spacing.lg, Spacing.xs, Spacing.lg, Spacing.xxl),
          children: [
            // Neighborhood: one calm selector, no caps-lock buttons.
            NeighborhoodSelectionWidget(
              onNeighborhoodChanged: _refreshItems,
            ),
            _AvailabilityToggle(itemViewModel: itemViewModel),
            ItemSearchFilterWidget(
              availableTags: itemViewModel.getAvailableTags(),
              onSearchChanged: (searchText) {
                itemViewModel.updateSearchText(searchText);
              },
              onTagsChanged: (tags) {
                itemViewModel.updateSelectedTags(tags);
              },
              initialSearchText: itemViewModel.searchText,
              initialSelectedTags: itemViewModel.selectedTags,
            ),
            SectionHeader(
              'From your neighbors',
              trailing: Text(
                '${itemViewModel.filteredItems.length} items',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            _buildResults(context),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    if (itemViewModel.isLoading) {
      return _buildSkeletonGrid(context);
    }

    final items = itemViewModel.filteredItems;
    if (items.isEmpty) {
      final hasFilters =
          itemViewModel.searchText.isNotEmpty || itemViewModel.selectedTags.isNotEmpty;
      return SizedBox(
        height: 300,
        child: EmptyState(
          icon: hasFilters ? Icons.search_off_rounded : Icons.deck_rounded,
          title: hasFilters ? 'Nothing matches' : 'Nothing nearby yet',
          message: hasFilters
              ? 'Try a different search, or clear your active filters below.'
              : 'Items your neighbors lend will show up here. Be the first on your block — post something from your garage.',
          action: hasFilters
              ? TextButton(
                  onPressed: () => setState(() {
                    itemViewModel.clearFilters();
                  }),
                  child: const Text('Clear filters'),
                )
              : null,
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: Spacing.md,
        mainAxisSpacing: Spacing.md,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return HomeView.buildItemTile(context, items[index]);
      },
    );
  }

  Widget _buildSkeletonGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: Spacing.md,
        mainAxisSpacing: Spacing.md,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}

/// Availability filter as a labeled segmented control.
class _AvailabilityToggle extends StatelessWidget {
  final ItemViewModel itemViewModel;

  const _AvailabilityToggle({required this.itemViewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.xs),
            child: Text(
              'Show',
              style: theme.textTheme.labelSmall,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.check_circle_outline, size: 18),
                  label: Text('Ready to borrow'),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('Everything'),
                ),
              ],
              selected: {itemViewModel.showOnlyAvaliable},
              onSelectionChanged: (selection) {
                itemViewModel.updateShowOnlyAvaliable(selection.first);
              },
              showSelectedIcon: false,
              style: ButtonStyle(
                textStyle: WidgetStateProperty.all(
                  theme.textTheme.labelLarge,
                ),
                side: WidgetStateProperty.resolveWith((states) =>
                    BorderSide(color: theme.colorScheme.outlineVariant)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
