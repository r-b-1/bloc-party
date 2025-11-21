import 'package:blocparty/model/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:blocparty/model/login_model/auth_model.dart';

import 'package:blocparty/model/neighborhoodview_model.dart';

class PickNeighborhoodView extends StatefulWidget {
  const PickNeighborhoodView({super.key});

  @override
  State<PickNeighborhoodView> createState() => _PickNeighborhoodViewState();
}

class _PickNeighborhoodViewState extends State<PickNeighborhoodView> {
  late NeighborhoodViewModel neighborhoodViewModel;
  late AuthViewModel authViewModel;
  late ProfileViewModel profileViewModel;

  bool running_ = false;
  FocusNode focusNode = FocusNode();
  Color RED = Color.fromARGB(255, 255, 0, 0);
  Color BLUE = Color.fromARGB(255, 0, 0, 255);
  Color GREEN = Color.fromARGB(255, 0, 255, 0);

  @override
  void initState() {
    super.initState();
    authViewModel = AuthViewModel();
    profileViewModel = ProfileViewModel();
    neighborhoodViewModel = NeighborhoodViewModel(authViewModel, profileViewModel);
    neighborhoodViewModel.addListener(_onNeighborhoodViewModelChanged);

    focusNode.addListener(() {
      setState(() => RED = focusNode.hasFocus ? Colors.red : Colors.red);
    });
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
          title: 
          Stack(
            children: <Widget>[
              // Stroked text as border.
              Text(
                'Create Neighborhood',
                style: TextStyle(
                  fontSize: 40,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 5
                    ..color = GREEN,
                ),
              ),
              // Solid text as fill.
              Text(
                'Create Neighborhood',
                style: TextStyle(
                  fontSize: 40,
                  color: RED,
                ),
              ),
            ],
          ),
          
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: neighborhoodController,
                focusNode: focusNode,
                cursorColor: GREEN,
                style: TextStyle(color: GREEN, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide(color: RED, width: 3)),
                  focusedBorder:
                      OutlineInputBorder(borderSide: BorderSide(color: GREEN, width: 3)),
                  prefixIcon: Icon(
                    Icons.home,
                    color: GREEN,
                  ),
                ),
              ),
              /*Address(
                
                controller: neighborhoodController,
                labelName: 'Neighborhood Name',
                
              ),*/
            ],
            
          ),
          
          backgroundColor: Color.fromARGB(255, 0, 0, 255),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 255, 0, 0), // Set background color
              ),

              child: Text('Cancel', style:TextStyle(
                color: GREEN,
                fontWeight: FontWeight.bold)),
            ),
            
            ElevatedButton(
              onPressed: () async {
                if (neighborhoodController.text.trim().isNotEmpty && !running_) {
                  try {
                    //should just add the current user to the neighborhood by default
                    running_ = true;

                    //List<String> userToAdd = [profileViewModel.currentUser!.username];
                    List<String> userToAdd = [authViewModel.user!.uid];

                    await profileViewModel.addNeighborhood(neighborhoodIdToAdd: neighborhoodController.text.trim(),);

                    await neighborhoodViewModel.addNeighborhood(neighborhoodIdToAdd: neighborhoodController.text.trim(),);

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Neighborhood added successfully!')),
                      );
                    }

                    running_ = false;

                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add neighborhood: $e')),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 255, 0, 0), // Set background color
              ),
              child: 
              Text('Create Neighborhood', 
                          style:TextStyle(
                          color: GREEN,
                          fontWeight: FontWeight.bold)),
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
            String currentNeighborhoodID = neighborhoodViewModel.neighborhoods[index].neighborhoodId;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Color.fromARGB(255, 240 * (index % 2), 0, 240 * ((index-1) % 2)),
                child: Icon(Icons.home, color: Color.fromARGB(255, 240 * ((index-1) % 2), 0, 240 * (index % 2))),
              ),
              
              title: Text('Neighborhood: $currentNeighborhoodID'),
              subtitle: Text('Description'),
              trailing: IconButton(
                onPressed: () async{
                  //do neighborhood change/join logic here
                  if(!running_){
                    running_ = true;

                    if(profileViewModel.neighborhoods.contains(currentNeighborhoodID)){
                      await neighborhoodViewModel.leaveNeighborhood(neighborhoodIdToLeave: currentNeighborhoodID);
                    }
                    else{
                      await neighborhoodViewModel.joinNeighborhood(neighborhoodIdToJoin: currentNeighborhoodID);
                    }
                    neighborhoodViewModel.fetchNeighborhoods();

                    running_ = false;
                  }
                },
                icon: Icon(profileViewModel.neighborhoods.contains(currentNeighborhoodID) ? Icons.remove : Icons.add_home_work),
              ),
              
            );
        },
      ),
    );
  }
}
