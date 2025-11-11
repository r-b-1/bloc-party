import 'package:blocparty/model/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:blocparty/model/login_model/auth_model.dart';

import 'package:blocparty/model/neighborhoodview_model.dart';

//temp
final List<String> available_neighborhoods = List<String>.generate(
  10,
  (i) => '$i',
);
//temp

class PickNeighborhoodView extends StatefulWidget {
  const PickNeighborhoodView({super.key});

  @override
  State<PickNeighborhoodView> createState() => _PickNeighborhoodViewState();
}

class _PickNeighborhoodViewState extends State<PickNeighborhoodView> {
  late NeighborhoodViewModel neighborhoodViewModel;
  late AuthViewModel authViewModel;
  late ProfileViewModel profileViewModel;

  @override
  void initState() {
    super.initState();
    authViewModel = AuthViewModel();
    profileViewModel = ProfileViewModel();
    neighborhoodViewModel = NeighborhoodViewModel(authViewModel, profileViewModel);
    neighborhoodViewModel.addListener(_onNeighborhoodViewModelChanged);
  }

  @override
  void dispose() {
    neighborhoodViewModel.removeListener(_onNeighborhoodViewModelChanged);
    authViewModel.dispose();
    profileViewModel.dispose();
    neighborhoodViewModel.dispose();
    super.dispose();
  }

  void _onNeighborhoodViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }
  
// Method for the user to add a new address using the google API 
void _showAddNeighborhoodDialog() {
    final TextEditingController neighborhoodController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Neighborhood'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Address(
                controller: neighborhoodController,
                labelName: 'Neighborhood Name',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (neighborhoodController.text.trim().isNotEmpty) {
                  try {
                    //should just add the current user to the neighborhood by default

                    //List<String> userToAdd = [profileViewModel.currentUser!.username];
                    List<String> userToAdd = [authViewModel.user!.uid];
                    
                    await neighborhoodViewModel.addNeighborhood(neighborhoodIdToAdd: neighborhoodController.text.trim(), neighborhoodUsersToAdd: userToAdd);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Neighborhood added successfully!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add neighborhood: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Create Neighborhood'),
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
        title: Text('Neighborhoods Avaliable'),
        leading: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            neighborhoodViewModel.fetchNeighborhoods();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_home_work_outlined),
            onPressed: () {
              _showAddNeighborhoodDialog();
            },
          ),
        ],
      ),
      
      body: ListView.builder(
        itemCount: neighborhoodViewModel.neighborhoods.length,
        
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Color.fromARGB(255, 240 * (index % 2), 0, 240 * ((index-1) % 2)),
              child: Icon(Icons.home, color: Color.fromARGB(255, 240 * ((index-1) % 2), 0, 240 * (index % 2))),
            ),

            title: Text('Neighborhood: ${neighborhoodViewModel.neighborhoods[index].neighborhoodId}'),
            subtitle: Text('Description'),
            trailing: IconButton(
              onPressed: () {
                //do neighborhood change/join logic here
                neighborhoodViewModel.joinNeighborhood(neighborhoodIdToJoin: neighborhoodViewModel.neighborhoods[index].neighborhoodId);
              },
              icon: Icon(Icons.add_home_work),
            ),
            
          );
        },
      ),
    );
  }
}
