import 'package:flutter/material.dart';
import 'package:blocparty/model/item_model.dart';

class ItemDescriptionView extends StatelessWidget {
  final Item item;
  const ItemDescriptionView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: Center(
                child: Image.asset(
                  item.imagePath,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Error loading image');
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Status: ${item.isAvailable ? 'Available' : 'Unavailable'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('Description: ${item.description}'),
            const SizedBox(height: 8),
            const Text('Instructions: Instructions for use.'),
            const Spacer(),
            ElevatedButton(
              child: const Text('Schedule'),
              onPressed: () {
                Navigator.pushNamed(context, '/schedule');
              },
            ),
          ],
        ),
      ),
    );
  }
}
