import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:blocparty/model/itemview_model.dart';
import 'package:blocparty/model/item_model.dart';
import 'package:blocparty/view/widgets/item_search_filter_widget.dart';
import 'package:blocparty/model/login_model/auth_model.dart';
import 'package:blocparty/view/widgets/neighborhood_selection_widget.dart';
import 'package:blocparty/model/messaging_model.dart';
import 'package:blocparty/model/profile_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  // Make this a static method so it can be used by other files
  static Widget buildItemTile(
    BuildContext context,
    Item item, {
    VoidCallback? onTap,
    required String? currentUsername,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      margin: const EdgeInsets.all(2),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            onTap ??
            () {
              context.push('/item_description', extra: item);
            },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1.2,
                  child: Image.asset(
                    item.imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/confused-person.jpg',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          text: item.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          children: [
                            TextSpan(
                              text: ' - ${item.description}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.normal,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Adding chat bubble icon for borrow requests (only shows icon for other users items)
            if (currentUsername != null && currentUsername != item.userId)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.blue,
                      size: 18,
                    ),
                    onPressed: () {
                      // Cast context to access the State class methods
                      final state = context
                          .findAncestorStateOfType<_HomeViewState>();
                      state?._showBorrowRequestDialog(context, item);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
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

  // Method to show borrow request confirmation dialog
  Future<void> _showBorrowRequestDialog(BuildContext context, Item item) async {
    final currentUsername = _profileViewModel.currentUser?.username;
    if (currentUsername == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to send requests')),
      );
      return;
    }

    // check if user is trying to request their own item
    if (currentUsername == item.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot request your own item')),
      );
      return;
    }

    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Request to Borrow'),
          content: Text(
            'Send a borrow request for "${item.name}" to the owner?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Send Request'),
            ),
          ],
        );
      },
    );

    if (shouldProceed == true) {
      await _createBorrowRequestChat(context, item, currentUsername);
    }
  }

  // Method to create borrow request chat and navigate
  Future<void> _createBorrowRequestChat(
    BuildContext context,
    Item item,
    String currentUsername,
  ) async {
    try {
      // Creates messaging model instance
      final messagingModel = MessagingModel(authViewModel);

      // Creates the borrow request chat
      final newChat = await messagingModel.createBorrowRequestChat(
        itemName: item.name,
        lenderUsername: item.userId,
        currentUsername: currentUsername,
      );

      if (newChat != null) {
        // Navigates directly to the new chat
        context.push('/chat', extra: newChat);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create chat: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/pick_neighborhood');
                    },
                    child: Text('  NEIGHBORHOOD SELECTION  '),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: NeighborhoodSelectionWidget(
                  onNeighborhoodChanged: _refreshItems,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Switch(
                      value: itemViewModel.showOnlyAvaliable,
                      onChanged: (bool value) {
                        itemViewModel.updateShowOnlyAvaliable(value);
                      },
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      itemViewModel.showOnlyAvaliable
                          ? 'Showing Avaliable'
                          : 'Showing All',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: ItemSearchFilterWidget(
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
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Text(
                  'List of Items (${itemViewModel.filteredItems.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (itemViewModel.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                  ),
                  itemCount: itemViewModel.filteredItems.length,
                  itemBuilder: (context, index) {
                    return HomeView.buildItemTile(
                      context,
                      itemViewModel.filteredItems[index],
                      currentUsername: _profileViewModel.currentUser?.username,
                    );
                  },
                ),
              SizedBox(
                width: double.infinity,
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      itemViewModel.fetchItems();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
