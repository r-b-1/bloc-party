import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:blocparty/model/itemview_model.dart';
import 'package:blocparty/model/item_model.dart';
import 'package:blocparty/view/widgets/item_search_filter_widget.dart';
import 'package:blocparty/model/login_model/auth_model.dart';
import 'package:blocparty/view/widgets/neighborhood_selection_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  // Make this a static method so it can be used by other files
  static Widget buildItemTile(
    BuildContext context,
    Item item, {
    VoidCallback? onTap,
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
        child: Column(
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
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: item.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: ' - ${item.description}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey[700],
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

  @override
  void initState() {
    super.initState();
    authViewModel = AuthViewModel();
    itemViewModel = ItemViewModel(authViewModel);
    // Listen to changes in the ItemViewModel
    itemViewModel.addListener(_onItemViewModelChanged);
  }

  @override
  void dispose() {
    itemViewModel.removeListener(_onItemViewModelChanged);
    itemViewModel.dispose();
    authViewModel.dispose();
    super.dispose();
  }

  void _onItemViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  //  method to refresh items when neighborhood changes
  void _refreshItems() {
    itemViewModel.fetchItems();
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
              Align(
                alignment: Alignment.topRight,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/pick_neighborhood');
                  },
                  child: Text('  NEIGHBORHOOD SELECTION  '),
                ),
              ),
              const SizedBox(height: 16),
              NeighborhoodSelectionWidget(onNeighborhoodChanged: _refreshItems),
              const SizedBox(height: 16),
              _buildInfoCard('Notification Request', '0'),
              _buildInfoCard('Messages', '3 new'),
              const SizedBox(height: 20),
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
              const SizedBox(height: 16),
              Text(
                'List of Items (${itemViewModel.filteredItems.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
                    );
                  },
                ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  itemViewModel.fetchItems();
                },
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
