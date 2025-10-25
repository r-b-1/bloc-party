import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:blocparty/model/proflie_model.dart';
import 'package:blocparty/view/home_view.dart'; 

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _profileViewModel.isLoading ? null : () => _profileViewModel.refresh(),
          ),
        ],
      ),
      body: _buildBody(context), 
    );
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

    return Column(
      children: [
        // User info section
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
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                _profileViewModel.currentUser?.email ?? '',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                '${_profileViewModel.userItems.length} items listed',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        
        // User's items section
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Listed Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                if (_profileViewModel.userItems.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No items listed yet',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: _profileViewModel.userItems.length,
                      itemBuilder: (context, index) {
                        final item = _profileViewModel.userItems[index];
                        // Use the shared method from HomeView
                        return HomeView.buildItemTile(
                          context, 
                          item,
                          onTap: () {
                            context.push('/item_description');
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}