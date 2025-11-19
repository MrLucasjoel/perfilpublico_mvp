import 'package:flutter/material.dart';
import 'package:perfilpublico/src/view/registro_view.dart';

// O Drawer foi movido para uma classe separada para manter a HomeView mais limpa.
class AppMenu extends StatelessWidget {
  const AppMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 204, 204, 204),
            ),
            child: Text(
              'Menu',
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Início'),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Cadastrar Deputado'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (c) => const RegistroView()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}