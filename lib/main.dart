import 'package:flutter/material.dart';
import 'package:hackathon_camballey/routes/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PayMov',
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 12, 67, 145)),
        
        useMaterial3: true,
      ),
      routes: getRoutes(),
      // initialRoute: 'dashboard',
      initialRoute: 'login',
    );
}
}


