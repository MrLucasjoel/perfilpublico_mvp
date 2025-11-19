import 'package:flutter/material.dart';
import 'home_view.dart'; 

class LogoView extends StatelessWidget {
  const LogoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // A sua logo foi inserida aqui usando o widget Image.asset.
            // NOTA: O caminho 'assets/perfil_publico_logo.jpeg' é um exemplo.
            // Você precisa seguir os passos abaixo para que a imagem seja carregada.
            Image.asset(
              'assets/perfil_publico_logo.jpeg',
              // Definindo um tamanho adequado para a imagem
              height: 400, 
              fit: BoxFit.contain,
            ),
            
            const SizedBox(height: 30),
            
            // O texto 'Perfil Público' foi comentado aqui, pois a sua imagem de logo 
            // já contém esse texto, evitando que ele apareça duplicado.
            // const Text(
            //   'Perfil Público',
            //   style: TextStyle(
            //     fontSize: 24,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),

            const SizedBox(height: 80),

            // Botão "Entrar"
            ElevatedButton(
              onPressed: () {
                // Navega para a HomeView
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeView()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'ENTRAR',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}