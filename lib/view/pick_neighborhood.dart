import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:blocparty/model/auth_model.dart';

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

  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Neighborhood Selection')),
      body: ListView.builder(
        itemCount: available_neighborhoods.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color.fromARGB(255, 114, 26, 255),
              child: Text(available_neighborhoods[index]),
            ),

            title: Text('Neighborhood ${available_neighborhoods[index]}'),
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
  }*/
}





class _PickNeighborhoodViewState extends State<PickNeighborhoodView> {
  late NeighborhoodViewModel neighborhoodViewModel;
  late AuthViewModel authViewModel;

  @override
  void initState() {
    super.initState();
    authViewModel = AuthViewModel();
    neighborhoodViewModel = NeighborhoodViewModel(authViewModel);
    neighborhoodViewModel.addListener(_onNeighborhoodViewModelChanged);
  }

  @override
  void dispose() {
    neighborhoodViewModel.removeListener(_onNeighborhoodViewModelChanged);
    authViewModel.dispose();
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
            
            //add new neighborhood
          },
        ),
        ],

      ),
      
      
      body: ListView.builder(
        itemCount: neighborhoodViewModel.neighborhoods.length,
        
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Color.fromARGB(255, 0, (index % 25) * 2 + 200, (index % 25) * 2 + 200),
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
