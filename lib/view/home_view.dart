import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:blocparty/model/itemview_model.dart';
import 'package:blocparty/model/item_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late ItemViewModel itemViewModel;

  @override
  void initState() {
    super.initState();
    itemViewModel = ItemViewModel(); // This will initialize with dummy data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildInfoCard('Group Name', 'Neighborhood Watch'),
          _buildInfoCard('Notification Request', '0'),
          _buildInfoCard('Messages', '3 new'),
          const SizedBox(height: 20),
          const Text(
            'List of Items',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Display items from ItemViewModel
          ...itemViewModel.items.map((item) => _buildItemTile(context, item)),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              itemViewModel.fetchItems();
              setState(() {}); // Force rebuild
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(BuildContext context, Item item) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                  _getPortabilityText(item.portability),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          context.push('/item_description');
        },
      ),
    );
  }

  String _getPortabilityText(ItemPortability portability) {
    switch (portability) {
      case ItemPortability.portable:
        return 'Portable';
      case ItemPortability.semiPortable:
        return 'Semi-Portable';
      case ItemPortability.immovable:
        return 'Immovable';
    }
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