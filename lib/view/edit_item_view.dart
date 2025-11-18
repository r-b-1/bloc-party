import 'package:flutter/material.dart';
import 'package:blocparty/model/profile_model.dart';
import 'package:blocparty/model/item_model.dart';
import 'package:blocparty/model/edit_item_model.dart';
import 'package:blocparty/view/home_view.dart';

class EditItemView extends StatefulWidget {
  final ProfileViewModel profileViewModel;
  final Item item;

  const EditItemView({
    super.key,
    required this.profileViewModel,
    required this.item,
  });

  @override
  State<EditItemView> createState() => _EditItemViewState();
}

class _EditItemViewState extends State<EditItemView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  ItemPortability _selectedPortability = ItemPortability.portable;
  final List<String> _imagePaths = [
    'images/confused-person.jpg',
    'images/garden-tools.jpg',
    'images/coffee-table.jpg',
    'images/dining-table.jpg',
    'images/dawg.jpg',
    'images/lawn-mower.jpg',
    'images/trapped_dog.jpg',
    'images/bike.jpg',
    'images/wood-bookshelf.jpg',
    'images/power-drill.jpg',
    'images/electrician.jpg',
    'images/bike-repair.jpg',
    'images/phone-repair.jpg',
  ];
  String? _selectedImagePath = 'images/confused-person.jpg';
  bool _isLoading = false;

  // neighborhood selection state
  String? _selectedNeighborhood;

  // Creates instance of EditItemViewModel
  final EditItemViewModel _editItemViewModel = EditItemViewModel();

  @override
  void initState() {
    super.initState();
    // Initialize form fields with existing item data
    _initializeFormWithItemData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  // Method to initialize form fields with existing item data
  void _initializeFormWithItemData() {
    _nameController.text = widget.item.name;
    _descriptionController.text = widget.item.description;
    _selectedPortability = widget.item.portability;
    _tagsController.text = widget.item.tags.join(', ');
    _selectedImagePath = widget.item.imagePath;
    
    // Set initial neighborhood from item data
    if (widget.item.neighborhoodId.isNotEmpty) {
      _selectedNeighborhood = widget.item.neighborhoodId.first;
    } else {
      // Fallback to user's first neighborhood if item has none
      final neighborhoods = widget.profileViewModel.currentUser?.neighborhoodId ?? [];
      if (neighborhoods.isNotEmpty) {
        _selectedNeighborhood = neighborhoods.first;
      }
    }
  }

  Future<void> _updateItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // validates neighborhood selection
    if (_selectedNeighborhood == null || _selectedNeighborhood!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a neighborhood for this item.'),
          ),
        );
      }
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

      // use selected neighborhood instead of all user neighborhoods
      final neighborhoodIds = [_selectedNeighborhood!];

      // Use EditItemViewModel to update the item
      await _editItemViewModel.updateItem(
        itemId: widget.item.id,
        name: _nameController.text,
        description: _descriptionController.text,
        portability: _selectedPortability,
        tags: tags,
        neighborhoodId: neighborhoodIds,
        imagePath: _selectedImagePath ?? 'assets/images/confused-person.jpg',
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update item: $e')));
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
        title: const Text('Edit Item'),
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
              // neighborhood selection dropdown using same implementation as add_item_view
              _buildNeighborhoodDropdown(),
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
                onPressed: _isLoading ? null : _updateItem,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Update Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // widget to build neighborhood dropdown using profile view model data
  Widget _buildNeighborhoodDropdown() {
    final neighborhoods = widget.profileViewModel.currentUser?.neighborhoodId ?? [];

    if (neighborhoods.isEmpty) {
      return const Text(
        'No neighborhoods available. Please add neighborhoods to your profile first.',
        style: TextStyle(color: Colors.grey),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedNeighborhood,
      decoration: const InputDecoration(
        labelText: 'Select Neighborhood for Item',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: neighborhoods.map((neighborhood) {
        return DropdownMenuItem(
          value: neighborhood,
          child: Text(neighborhood),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedNeighborhood = newValue;
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a neighborhood';
        }
        return null;
      },
      isExpanded: true,
    );
  }
}