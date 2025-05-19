import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'services/firestore_service.dart';
import 'providers/menu_provider.dart';
import 'providers/order_provider.dart';
import 'screens/main_menu.dart';

/// Flutter POS and KDS Application
///
/// This application demonstrates a point-of-sale (POS) and kitchen display (KDS) system
/// using Flutter on Android. The app connects to Firebase Firestore as a backend. It
/// provides dynamic menu editing, NFC/QR based table ordering, and real-time order dispatch
/// to the kitchen. State management is handled by Provider for menus and orders.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: kIsWeb ? DefaultFirebaseOptions.web : DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

/// The root widget of the application, setting up providers and main routes.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use MultiProvider to inject dependencies and state across the app.
    return MultiProvider(
      providers: [
        // Firestore service for data operations.
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        // Provider for menu-related state.
        ChangeNotifierProvider<MenuProvider>(
          create: (context) => MenuProvider(firestoreService: context.read<FirestoreService>()),
        ),
        // Provider for order-related state.
        ChangeNotifierProvider<OrderProvider>(
          create: (context) => OrderProvider(firestoreService: context.read<FirestoreService>()),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter POS and KDS',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          // Additional theme configuration can go here.
        ),
        home: MainMenu(), // Initial screen with role selection.
      ),
    );
  }
}

/// End of main.dart. The app starts here with multi-provider state and Firestore integration.
