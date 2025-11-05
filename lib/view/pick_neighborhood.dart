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
    neighborhoodViewModel = NeighborhoodViewModel(authViewModel);
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
            icon: const Icon(Icons.add),
            onPressed: () {
              
              //should just add the current user to the neighborhood by default
              
              List<String> userToAdd = [profileViewModel.currentUser!.username];
              neighborhoodViewModel.addNeighborhood(neighborhoodIdToAdd: (neighborhoodViewModel.neighborhoods.length + 1).toString(), neighborhoodUsersToAdd: userToAdd);
            },
          ),
        ],

      ),
      
      
      body: ListView.builder(
        itemCount: neighborhoodViewModel.neighborhoods.length,
        
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Color.fromARGB(255, 0, (index % 5) * 10 + 200, (index % 5) * 10 + 200),
              child: Icon(Icons.house, color: Color.fromARGB(255, 0, 0, 0),),
            ),

            title: Text('Neighborhood: ${neighborhoodViewModel.neighborhoods[index].neighborhoodId}'),
            subtitle: Text('Description'),
            trailing: GestureDetector(
              onTap: () {
                //do neighborhood change/join logic here

                //temp
                context.go(
                  '/home',
                ); //no animation on the button, so I put this here to show it works
                //temp
              },
              child: Icon(Icons.add),
            ),
            
          );
        },
      ),
    );
  }
}
