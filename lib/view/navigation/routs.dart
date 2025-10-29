import 'package:go_router/go_router.dart'; 
import 'package:blocparty/flutter_backend/go_router.dart'; // main function to go from page to page

import 'package:blocparty/view/navigation/navigation_bar.dart';   //Navigation
import 'package:blocparty/view/chat_view.dart';                   //chat view
import 'package:blocparty/view/item_descriptions_view.dart';      //Item dicription
import 'package:blocparty/view/login_view.dart';                  //Login
import 'package:blocparty/view/schedule_view.dart';               //schedule
import 'package:blocparty/view/register_view.dart';               //register      
import 'package:blocparty/view/create_profile_view.dart';         //Create Profile
import 'package:firebase_auth/firebase_auth.dart';                //Fire_auth
import 'package:blocparty/view/pick_neighborhood.dart';           //Pick Neighborhood
  
  GoRouter goRouts() {
    final GoRouter router = GoRouter(
      initialLocation: '/auth',
      refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
      routes: [
        GoRoute(
          path: '/auth',
          builder: (context, state) => LoginView(),
        ),
        GoRoute(
          path: '/register',
         builder: (context, state) => const RegisterView(),
        ),
        GoRoute(
          path: '/create-profile',
          builder:(context, state) => const CreateProfileView(),
          ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const MainNavigation(),
        ),
        GoRoute(
          path: '/item_description',
          builder: (context, state) => const ItemDescriptionView(),
        ),
        GoRoute(
          path: '/schedule',
          builder: (context, state) => const ScheduleView(),
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => const ChatView(),
        ),
        GoRoute(
          path: '/pick_neighborhood',
          builder: (context, state) => const PickNeighborhoodView(),
        ),
      ],
      redirect: (context, state) {
        final user = FirebaseAuth.instance.currentUser;
      
        final bool loggedIn = user != null;
        final String location = state.matchedLocation;
        final bool isAuthRoute = (location == '/auth' || location == '/register');
    
        if (!loggedIn) {
          return isAuthRoute ? null : '/auth';
        }

        if (loggedIn && isAuthRoute) {
          return '/home';
        }
        return null; 
      },
    );
    return router;
  }