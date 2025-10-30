import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//temp
final List<String> available_neighborhoods = List<String>.generate(
  100,
  (i) => '$i',
);
//temp

class PickNeighborhoodView extends StatelessWidget {
  const PickNeighborhoodView({super.key});

  @override
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
  }
}
