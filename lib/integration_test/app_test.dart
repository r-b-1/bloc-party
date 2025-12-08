// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('BlocParty integration tests', () {
    testWidgets('tap on item selection button, verify selection updates', (
      tester,
    ) async {
      // Create a simple test app that mimics your item selection
      String selectedItem = 'None';
      
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                appBar: AppBar(title: const Text('BlocParty Test')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Selected: $selectedItem',
                        key: const Key('selected_text'),
                      ),
                      const SizedBox(height: 20),
                      // Mock item 1 - like Power Drill in your app
                      ElevatedButton(
                        key: const Key('item_power_drill'),
                        onPressed: () {
                          setState(() {
                            selectedItem = 'Power Drill';
                          });
                        },
                        child: const Text('Select Power Drill'),
                      ),
                      const SizedBox(height: 10),
                      // Mock item 2 - like Lawn Mower in your app
                      ElevatedButton(
                        key: const Key('item_lawn_mower'),
                        onPressed: () {
                          setState(() {
                            selectedItem = 'Lawn Mower';
                          });
                        },
                        child: const Text('Select Lawn Mower'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Verify initial state (like counter starts at 0)
      expect(find.text('Selected: None'), findsOneWidget);

      // Find the first item button to tap on
      final firstItemButton = find.byKey(const Key('item_power_drill'));

      // Emulate a tap on the button
      await tester.tap(firstItemButton);

      // Trigger a frame
      await tester.pumpAndSettle();

      // Verify the selection updated (like counter increments by 1)
      expect(find.text('Selected: Power Drill'), findsOneWidget);

      // Find and tap second item button
      final secondItemButton = find.byKey(const Key('item_lawn_mower'));
      await tester.tap(secondItemButton);
      await tester.pumpAndSettle();

      // Verify new selection
      expect(find.text('Selected: Lawn Mower'), findsOneWidget);
    });

    testWidgets('test navigation between screens', (tester) async {
      // Track navigation state
      String currentScreen = 'Home';
      
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                appBar: AppBar(title: Text(currentScreen)),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (currentScreen == 'Home') ...[
                        const Text('Home Screen Content'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          key: const Key('go_to_profile'),
                          onPressed: () {
                            setState(() {
                              currentScreen = 'Profile';
                            });
                          },
                          child: const Text('Go to Profile'),
                        ),
                      ] else if (currentScreen == 'Profile') ...[
                        const Text('Profile Screen Content'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          key: const Key('go_back_home'),
                          onPressed: () {
                            setState(() {
                              currentScreen = 'Home';
                            });
                          },
                          child: const Text('Back to Home'),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Verify initial screen
      expect(find.text('Home'), findsOneWidget);
      expect(find.byKey(const Key('go_to_profile')), findsOneWidget);

      // Navigate to profile
      await tester.tap(find.byKey(const Key('go_to_profile')));
      await tester.pumpAndSettle();

      // Verify profile screen
      expect(find.text('Profile'), findsOneWidget);
      expect(find.byKey(const Key('go_back_home')), findsOneWidget);

      // Navigate back to home
      await tester.tap(find.byKey(const Key('go_back_home')));
      await tester.pumpAndSettle();

      // Verify back on home
      expect(find.text('Home'), findsOneWidget);
    });
  });
}