import 'package:flutter/material.dart';

class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
      ),
      body: Column(
        children: [
          // Placeholder for a calendar
          Container(
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: Text(
                'Month View Calendar Placeholder',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Divider(),
          const Expanded(
            child: Center(
              child: Text('My Items list goes here.'),
            ),
          ),
        ],
      ),
    );
  }
}

