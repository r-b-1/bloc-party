import 'package:flutter/material.dart';

class ItemDescriptionView extends StatelessWidget {
  const ItemDescriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Description'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.photo_camera, size: 50, color: Colors.grey)),
            ),
            const SizedBox(height: 16),
            const Text('Status: Available', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Description: Detailed description of the item goes here.'),
            const SizedBox(height: 8),
            const Text('Instructions: Instructions for use.'),
            const Spacer(),
            ElevatedButton(
              child: const Text('Schedule'),
              onPressed: () {
                Navigator.pushNamed(context, '/schedule');
              },
            )
          ],
        ),
      ),
    );
  }
}
