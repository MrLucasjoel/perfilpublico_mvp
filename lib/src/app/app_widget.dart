import 'package:flutter/material.dart';
import 'package:perfilpublico/src/view/logo_view.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Perfil Publico',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 204, 204, 204)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 204, 204, 204),
          foregroundColor: Color.fromARGB(255, 0, 0, 0),
          elevation: 0,
        ),
      ),
      home: const LogoView(),
    );
  }
}