import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/add_match_page.dart';
import 'pages/stats_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const firebaseConfig = FirebaseOptions(
    apiKey: "AIzaSyDvSql-lg7hkvNQfH7roXPHA6eGR2W-YD0",
    authDomain: "autenticacion-1a723.firebaseapp.com",
    databaseURL: "https://autenticacion-1a723-default-rtdb.firebaseio.com",
    projectId: "autenticacion-1a723",
    storageBucket: "autenticacion-1a723.appspot.com",
    messagingSenderId: "727318054111",
    appId: "1:727318054111:web:3a0b9dcb6556d90821956a",
    measurementId: "G-TGQ55VD1YV",
  );

  await Firebase.initializeApp(options: firebaseConfig);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CS2 Match Tracker',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.orangeAccent,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return const HomePage();
          }
          return const LoginPage();
        },
      ),
      routes: {
        '/home': (context) => const HomePage(),
        '/add': (context) => const AddMatchPage(),
        '/stats': (context) => const StatsPage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
