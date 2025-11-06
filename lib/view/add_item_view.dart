import 'package:blocparty/view/home_view.dart';
import 'package:flutter/material.dart';
import 'package:blocparty/model/profile_model.dart';
import 'package:blocparty/model/item_model.dart';
import 'package:blocparty/model/add_item_model.dart';

class AddItemView extends StatefulWidget {
  final ProfileViewModel profileViewModel;

  const AddItemView({super.key, required this.profileViewModel});

  @override
  State<AddItemView> createState() => _AddItemViewState();
}

class _AddItemViewState extends State<AddItemView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  ItemPortability _selectedPortability = ItemPortability.portable;
  final List<String> _imagePaths = [
    'assets/images/confused-person.jpg',
    'assets/images/garden-tools.jpg',
    'assets/images/coffee-table.jpg',
    'assets/images/dining-table.jpg',
    'assets/images/dawg.jpg',
    'assets/images/lawn-mower.jpg',
    'assets/images/trapped_dog.jpg',
    'assets/images/bike.jpg',
    'assets/images/wood-bookshelf.jpg',
    'assets/images/power-drill.jpg',
  ];
  String? _selectedImagePath = 'assets/images/confused-person.jpg';
  bool _isLoading = false;

  // Create instance of AddItemViewModel
  final AddItemViewModel _addItemViewModel = AddItemViewModel();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _submitItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse tags from comma-separated string
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final neighborhoodIds =
          widget.profileViewModel.currentUser?.neighborhoodId ?? [];

      if (neighborhoodIds.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Select a neighborhood before adding an item.'),
            ),
          );
        }
        return;
      }

      // Use AddItemViewModel to add the item
      await _addItemViewModel.addItem(
        name: _nameController.text,
        description: _descriptionController.text,
        portability: _selectedPortability,
        tags: tags,
        username: widget.profileViewModel.currentUser!.username,
        imagePath: _selectedImagePath ?? 'assets/images/confused-person.jpg',
        neighborhoodId: neighborhoodIds,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add item: $e')));
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ItemPortability>(
                value: _selectedPortability,
                decoration: const InputDecoration(
                  labelText: 'Portability',
                  border: OutlineInputBorder(),
                ),
                items: ItemPortability.values.map((portability) {
                  return DropdownMenuItem(
                    value: portability,
                    child: Text(HomeView.getPortabilityText(portability)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPortability = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedImagePath,
                decoration: const InputDecoration(
                  labelText: 'Item Image',
                  border: OutlineInputBorder(),
                ),
                items: _imagePaths.map((path) {
                  final parts = path.split(
                    '/',
                  ); // Removes the path from the filename
                  final filename = parts.isNotEmpty ? parts.last : path;
                  final displayName =
                      filename.contains(
                        '.',
                      ) // Checks if it has a period, if so, then it has a extension.
                      ? filename
                            .split('.')
                            .first // Removes the extension from the filename
                      : filename;
                  return DropdownMenuItem(
                    value: path,
                    child: Text(displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedImagePath = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an image';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., tool, garden, kitchen',
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitItem,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
