import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Align(
            alignment: Alignment.topRight, // Positions the button at the bottom center
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/pick_neighborhood');
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
          // This represents the list of items
          ListTile(
            leading: const Icon(Icons.card_giftcard),
            title: const Text('Item 1'),
            subtitle: const Text('Available'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, '/item_description');
            },
          ),
          ListTile(
            leading: const Icon(Icons.cake),
            title: const Text('Item 2'),
            subtitle: const Text('Borrowed'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, '/item_description');
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
