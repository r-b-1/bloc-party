import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:blocparty/model/itemview_model.dart';
import 'package:blocparty/model/item_model.dart';
import 'package:blocparty/model/auth_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  // Make this a static method so it can be used by other files
  static Widget buildItemTile(
    BuildContext context,
    Item item, {
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.card_giftcard),
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: item.isAvailable ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.isAvailable ? 'Available' : 'Unavailable',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  getPortabilityText(item.portability),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Listed by: ${item.userId}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap:
            onTap ??
            () {
              context.push('/item_description', extra: item);
            },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Align(
            alignment:
                Alignment.topRight, // Positions the button at the bottom center
            child: ElevatedButton(
              onPressed: () {
                context.go('/pick_neighborhood');
              },
              child: Text('  NEIGHBORHOOD SELECTION  '),
            ),
          ),

          const SizedBox(height: 16),

          _buildInfoCard('Group Name', 'Neighborhood Watch'),
          _buildInfoCard('Notification Request', '0'),
          _buildInfoCard('Messages', '3 new'),
          const SizedBox(height: 20),
          const Text(
            'List of Items',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Show loading indicator if items are being fetched
          if (itemViewModel.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            // Using the static method
            ...itemViewModel.items.map(
              (item) => HomeView.buildItemTile(context, item),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              itemViewModel.fetchItems();
            },
          ),
        ],
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
