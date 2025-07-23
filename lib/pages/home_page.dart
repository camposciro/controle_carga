import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/usuario.dart';
import 'gestao_motoristas_page.dart';


class HomePage extends StatelessWidget {
  final AuthService authService;

  const HomePage({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    final Usuario? usuario = authService.usuarioLogado;

    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-vindo, ${usuario?.nome ?? 'Usuário'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: Center(
        child: usuario == null
            ? const Text('Usuário não encontrado')
            : usuario.perfil == PerfilUsuario.administrador
            ? AdminMenu(authService: authService)
            : MotoristaMenu(),
      ),
    );
  }
}

class AdminMenu extends StatelessWidget {
  final AuthService authService;

  const AdminMenu({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            // Navegar para a tela de gestão de motoristas
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GestaoMotoristasPage(authService: authService),
              ),
            );
          },
          child: const Text('Gerenciar Motoristas'),
        ),
        ElevatedButton(
          onPressed: () {
            // Navegar para gestão de veículos (a criar)
          },
          child: const Text('Gerenciar Veículos'),
        ),
        ElevatedButton(
          onPressed: () {
            // Navegar para relatórios (a criar)
          },
          child: const Text('Relatórios'),
        ),
      ],
    );
  }
}

class MotoristaMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            // Navegar para controle de status geral (a criar)
          },
          child: const Text('Status Geral Cargas'),
        ),
        ElevatedButton(
          onPressed: () {
            // Navegar para minhas viagens (a criar)
          },
          child: const Text('Minhas Viagens'),
        ),
        ElevatedButton(
          onPressed: () {
            // Navegar para relatórios pessoais (a criar)
          },
          child: const Text('Relatórios'),
        ),
      ],
    );
  }
}
