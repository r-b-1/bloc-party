import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:blocparty/model/item_model.dart';
import 'package:blocparty/model/messaging_model.dart';
import 'package:blocparty/model/login_model/auth_model.dart';
import 'package:blocparty/model/profile_model.dart';
import 'package:blocparty/view/widgets/schedule_button.dart';

class PrivateItemDescriptionView extends StatefulWidget {
  final Item item;
  const PrivateItemDescriptionView({super.key, required this.item});

  @override
  State<PrivateItemDescriptionView> createState() =>
      _PrivateItemDescriptionViewState();
}

class _PrivateItemDescriptionViewState
    extends State<PrivateItemDescriptionView> {
  late ProfileViewModel _profileViewModel;
  late AuthViewModel _authViewModel;

  @override
  void initState() {
    super.initState();
    _profileViewModel = ProfileViewModel();
    _authViewModel = AuthViewModel();
  }

  // Method to show borrow request confirmation dialog
  Future<void> _showBorrowRequestDialog(BuildContext context) async {
    final currentUsername = _profileViewModel.currentUser?.username;
    if (currentUsername == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to send requests')),
      );
      return;
    }

    // check if user is trying to request their own item
    if (currentUsername == widget.item.userId) {
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
            'Send a borrow request for "${widget.item.name}" to the owner?',
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
      await _createBorrowRequestChat(context, currentUsername);
    }
  }

  // Method to create borrow request chat and navigate
  Future<void> _createBorrowRequestChat(
    BuildContext context,
    String currentUsername,
  ) async {
    try {
      // Creates messaging model instance
      final messagingModel = MessagingModel(_authViewModel);

      // Creates the borrow request chat
      final newChat = await messagingModel.createBorrowRequestChat(
        itemName: widget.item.name,
        lenderUsername: widget.item.userId,
        currentUsername: currentUsername,
      );

      if (newChat != null) {
        // Navigates directly to the new chat
        if (context.mounted) {
          context.push('/chat', extra: newChat);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Borrow request sent successfully!')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create chat: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[300],
              child: Center(
                child: Image.asset(
                  widget.item.imagePath,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/images/confused-person.jpg');
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Status: ${widget.item.isAvailable ? 'Available' : 'Unavailable'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            // display neighborhood information
            Text(
              'Neighborhood: ${widget.item.neighborhoodId.join(', ')}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('Description: ${widget.item.description}'),
            const SizedBox(height: 8),
            Text('Owner: ${widget.item.userId}'),
            const SizedBox(height: 8),
            const Spacer(),
            const SizedBox(height: 8),
            // Add Schedule button here
            ScheduleButton(),
          ],
        ),
      ),
    );
  }
}
