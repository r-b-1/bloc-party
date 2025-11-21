import 'package:blocparty/model/chat_model.dart';
import 'package:go_router/go_router.dart';
import 'package:blocparty/flutter_backend/go_router.dart'; // main function to go from page to page

import 'package:blocparty/view/navigation/navigation_bar.dart'; //Navigation
import 'package:blocparty/view/chat_view/chat_view.dart'; //chat view
import 'package:blocparty/view/private_item_descriptions_view.dart'; //Item dicription
import 'package:blocparty/view/login_views/login_view.dart'; //Login
import 'package:blocparty/view/schedule_view.dart'; //schedule
import 'package:blocparty/view/login_views/register_view.dart'; //register
import 'package:blocparty/view/login_views/create_profile_view.dart'; //Create Profile
import 'package:firebase_auth/firebase_auth.dart'; //Fire_auth
import 'package:blocparty/view/pick_neighborhood.dart'; //Pick Neighborhood
import 'package:blocparty/model/item_model.dart'; //Item Model
import 'package:blocparty/view/login_views/verify_email_view.dart'; //Verify that there email is real
import 'package:blocparty/view/public_item_descriptions_view.dart'; //Public Item Description
import 'package:blocparty/view/private_item_descriptions_view.dart'; //Private Item Description

GoRouter goRouts() {
  final GoRouter router = GoRouter(
    initialLocation: '/auth',
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    routes: [
      GoRoute(path: '/auth', builder: (context, state) => LoginView()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailView(),
      ),
      GoRoute(
        path: '/create-profile',
        builder: (context, state) => const CreateProfileView(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainNavigation(),
      ),
      GoRoute(
        path: '/public_item_description',
        builder: (context, state) {
          final item = state.extra as Item;
          return PublicItemDescriptionView(item: item);
        },
      ),
      GoRoute(
        path: '/private_item_description',
        builder: (context, state) {
          final item = state.extra as Item;
          return PrivateItemDescriptionView(item: item);
        },
      ),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const ScheduleView(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final chat = state.extra as Chat;
          return ChatView(curChat: chat);
        },
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
