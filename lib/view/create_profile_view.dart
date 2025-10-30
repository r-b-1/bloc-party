import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:blocparty/model/user_model.dart';

class CreateProfileView extends StatefulWidget {
  const CreateProfileView({super.key});

  @override
  State<CreateProfileView> createState() => _CreateProfileViewState();
}

class _CreateProfileViewState extends State<CreateProfileView> {
  // 1. Create controllers and a form key
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveProfile() async {
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 3. Get the current user's UID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // This should not happen if you navigated here from UserCreated
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No user logged in.')),
        );
        return;
      }
      final uid = user.uid;

      final userModel = AddUser(
        username: _usernameController.text.trim(),
        name: _fullNameController.text.trim(),
        email: user.email ?? '',
        address: _addressController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userModel.toFirestore());

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      // Handle errors (e.g., show a snackbar)
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save profile: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Your Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              userName(),
              const SizedBox(height: 16),
              fullName(),
              const SizedBox(height: 16),
              mainAddress(),
              const SizedBox(height: 32),

              // Show a loading indicator or the button
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Save and Continue'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField mainAddress() {
    return TextFormField(
      controller: _addressController,
      decoration: const InputDecoration(labelText: 'Main Address'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please Enter a Address';
        }
        return null;
      },
    );
  }

  TextFormField fullName() {
    return TextFormField(
      controller: _fullNameController,
      decoration: const InputDecoration(labelText: 'Full Name'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your full name';
        }
        return null;
      },
    );
  }

  TextFormField userName() {
    return TextFormField(
      controller: _usernameController,
      decoration: const InputDecoration(labelText: 'Username'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a username';
        }
        return null;
      },
    );
  }
}
