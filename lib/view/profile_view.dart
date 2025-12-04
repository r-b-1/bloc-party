import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:blocparty/model/profile_model.dart';
import 'package:blocparty/model/theme_provider.dart';
import 'package:blocparty/view/home_view.dart';
import 'package:blocparty/view/add_item_view.dart';
import 'package:blocparty/view/edit_item_view.dart';
import 'package:blocparty/model/item_model.dart';
import 'package:blocparty/view/widgets/neighborhood_selection_widget.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late ProfileViewModel _profileViewModel;

  @override
  void initState() {
    super.initState();
    _profileViewModel = ProfileViewModel();
    _profileViewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _profileViewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _navigateToAddItem() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddItemView(profileViewModel: _profileViewModel),
      ),
    );
  }

  // ADD: Method to navigate to edit item view
  void _navigateToEditItem(Item item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            EditItemView(profileViewModel: _profileViewModel, item: item),
      ),
    );
  }

  // Method to delete item
  Future<void> _deleteItem(Item item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: Text('Are you sure you want to delete "${item.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _profileViewModel.deleteItem(item.id);
    }
  }

  // Method to toggle item availability
  Future<void> _toggleItemAvailability(Item item) async {
    try {
      await _profileViewModel.toggleItemAvailability(
        item.id,
        !item.isAvailable,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update availability: $e')),
        );
      }
    }
  }

  // Method for the user to add a new address using the google API
  void _showAddAddressDialog() {
    final TextEditingController addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Address'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Address(controller: addressController, labelName: 'New Address'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (addressController.text.trim().isNotEmpty) {
                  try {
                    await _profileViewModel.addAddress(
                      addressController.text.trim(),
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Address added successfully!'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add address: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Add Address'),
            ),
          ],
        );
      },
    );
  }

  // Method for user to delete addresses
  Future<void> _deleteAddress(String address) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Address'),
          content: Text(
            'Are you sure you want to delete this address?\n\n$address',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await _profileViewModel.deleteAddress(address);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address deleted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$e')));
        }
      }
    }
  }

  // Method to show theme color selection dialog
  void _showThemeColorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Theme Color'),
          content: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: ['blue', 'green', 'red', 'yellow']
                    .map(
                      (color) => RadioListTile<String>(
                        title: Text(
                          color[0].toUpperCase() + color.substring(1),
                        ),
                        value: color,
                        groupValue: themeProvider.currentThemeColor,
                        onChanged: (String? newColor) {
                          if (newColor != null) {
                            themeProvider.setThemeColor(
                              newColor,
                              themeProvider.isDarkMode,
                            );
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    )
                    .toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          // Menu button with three lines that shows dropdown options
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (String value) {
              switch (value) {
                case 'refresh':
                  if (!_profileViewModel.isLoading) {
                    _profileViewModel.refresh();
                  }
                  break;
                case 'theme':
                  final themeProvider = Provider.of<ThemeProvider>(
                    context,
                    listen: false,
                  );
                  themeProvider.toggleTheme();
                  break;
                case 'theme_color':
                  _showThemeColorDialog();
                  break;
                case 'signout':
                  _signOutUser();
                  break;
                case 'delete_account':
                  _showDeleteAccountConfirmation();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              // Refresh option
              PopupMenuItem<String>(
                value: 'refresh',
                enabled: !_profileViewModel.isLoading,
                child: Row(
                  children: [
                    const Icon(Icons.refresh, size: 20),
                    const SizedBox(width: 8),
                    const Text('Refresh'),
                    if (_profileViewModel.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  ],
                ),
              ),
              // Theme toggle option
              PopupMenuItem<String>(
                value: 'theme',
                child: Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Row(
                      children: [
                        Icon(
                          themeProvider.isDarkMode
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Theme color option
              PopupMenuItem<String>(
                value: 'theme_color',
                child: Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Row(
                      children: [
                        const Icon(Icons.palette, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Theme Color (${themeProvider.currentThemeColor[0].toUpperCase() + themeProvider.currentThemeColor.substring(1)})',
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Sign out option
              const PopupMenuItem<String>(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
              // Delete account option
              const PopupMenuItem<String>(
                value: 'delete_account',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Account', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(context),
          Positioned(
            right: 16,
            bottom: 80, // moved button up to avoid overlapping with items
            child: FloatingActionButton(
              onPressed: _navigateToAddItem,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  // Method to handle user sign out
  Future<void> _signOutUser() async {
    await _profileViewModel.signOutUser();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  // Method to show delete account confirmation dialog
  Future<void> _showDeleteAccountConfirmation() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to delete your account?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'This action will:',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• Permanently delete all your data',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    Text(
                      '• Remove all your listed items',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    Text(
                      '• Delete your account information',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This action cannot be undone.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteUserAccount();
    }
  }

  // Method to delete user account
  Future<void> _deleteUserAccount() async {
    try {
      await _profileViewModel.deleteAccount();

      if (mounted) {
        // Navigate to login or welcome screen after account deletion
        Navigator.of(context).pushReplacementNamed('/login');

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildBody(BuildContext context) {
    if (_profileViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_profileViewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${_profileViewModel.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _profileViewModel.refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 16),
                Text(
                  _profileViewModel.currentUser?.username ?? 'No username',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _profileViewModel.currentUser?.email ?? '',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_profileViewModel.userItems.length} items listed',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                // neighborhood selection dropdown widget
                NeighborhoodSelectionWidget(),
                const SizedBox(height: 16),
                _buildAddressSection(),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'My Listed Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              if (_profileViewModel.userItems.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No items listed yet',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.79,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                  ),
                  itemCount: _profileViewModel.userItems.length,
                  itemBuilder: (context, index) {
                    final item = _profileViewModel.userItems[index];
                    return Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              HomeView.buildItemTile(
                                context,
                                item,
                                onTap: () {
                                  context.push(
                                    '/private_item_description',
                                    extra: item,
                                  );
                                },
                              ),
                              // Edit icon positioned in top-right corner of item tile
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                      size: 18,
                                    ),
                                    onPressed: () => _navigateToEditItem(item),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 36,
                                      minHeight: 36,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Switch(
                              value: item.isAvailable,
                              onChanged: (bool value) {
                                _toggleItemAvailability(item);
                              },
                              activeColor: Colors.green,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () => _deleteItem(item),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
          // added bottom padding to ensure space for the button
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // Widget to build the UI for the user address section
  Widget _buildAddressSection() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Addresses',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_location, color: Colors.blue),
                  onPressed: _showAddAddressDialog,
                  tooltip: 'Add new address',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_profileViewModel.addresses.isEmpty)
              Text(
                'No addresses found. Add your first address!',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              )
            else
              Column(
                children: [
                  Text(
                    'Tap an address to set it as your current address:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...(_profileViewModel.addresses.map((address) {
                    final isCurrent =
                        address == _profileViewModel.currentAddress;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isCurrent
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1)
                          : null,
                      child: ListTile(
                        dense: true,
                        leading: Icon(
                          isCurrent
                              ? Icons.location_on
                              : Icons.location_on_outlined,
                          size: 20,
                          color: isCurrent
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        title: Text(
                          address,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => _deleteAddress(address),
                        ),
                        onTap: () {
                          if (!isCurrent) {
                            _profileViewModel.setCurrentAddress(address);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Current address set to: $address',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  })).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
