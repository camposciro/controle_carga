import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/usuario.dart';
import 'form_usuario_page.dart'; // Importa o formulário de usuário

class GestaoMotoristasPage extends StatefulWidget {
  final AuthService authService;

  const GestaoMotoristasPage({Key? key, required this.authService}) : super(key: key);

  @override
  _GestaoMotoristasPageState createState() => _GestaoMotoristasPageState();
}

class _GestaoMotoristasPageState extends State<GestaoMotoristasPage> {
  late List<Usuario> motoristas;
  Usuario? motoristaSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarMotoristas();
  }

  void _carregarMotoristas() {
    motoristas = widget.authService.usuarios
        .where((u) => u.perfil == PerfilUsuario.motorista)
        .toList();
    motoristaSelecionado = null;
  }

  void _selecionarMotorista(Usuario motorista) {
    setState(() {
      motoristaSelecionado = (motoristaSelecionado == motorista) ? null : motorista;
    });
  }

  Future<void> _adicionarMotorista() async {
    final perfilEscolhido = await showDialog<PerfilUsuario>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecione o tipo de usuário'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Motorista'),
              leading: const Icon(Icons.local_shipping),
              onTap: () => Navigator.pop(context, PerfilUsuario.motorista),
            ),
            ListTile(
              title: const Text('Administrador'),
              leading: const Icon(Icons.admin_panel_settings),
              onTap: () => Navigator.pop(context, PerfilUsuario.administrador),
            ),
          ],
        ),
      ),
    );

    if (perfilEscolhido != null) {
      final resultado = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => FormUsuarioPage(
            authService: widget.authService,
            perfilInicial: perfilEscolhido,
          ),
        ),
      );

      if (resultado == true) {
        setState(() {
          _carregarMotoristas();
        });
      }
    }
  }

  Future<void> _editarMotorista() async {
    if (motoristaSelecionado == null) return;

    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormUsuarioPage(
          authService: widget.authService,
          usuario: motoristaSelecionado,
          perfilInicial: motoristaSelecionado!.perfil,
        ),
      ),
    );

    if (resultado == true) {
      setState(() {
        _carregarMotoristas();
      });
    }
  }

  void _confirmarExcluirMotorista() {
    if (motoristaSelecionado == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja excluir o motorista ${motoristaSelecionado!.nome}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.authService.usuarios.removeWhere((u) => u.id == motoristaSelecionado!.id);
                _carregarMotoristas();
              });
              Navigator.pop(context);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Motoristas'),
      ),
      body: ListView.builder(
        itemCount: motoristas.length,
        itemBuilder: (context, index) {
          final motorista = motoristas[index];
          final selecionado = motorista == motoristaSelecionado;
          return ListTile(
            title: Text(motorista.nome),
            subtitle: Text('Login: ${motorista.login}'),
            selected: selecionado,
            onTap: () => _selecionarMotorista(motorista),
            selectedTileColor: Colors.blue.shade100,
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            onPressed: _adicionarMotorista,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'edit',
            onPressed: motoristaSelecionado == null ? null : _editarMotorista,
            backgroundColor: motoristaSelecionado == null ? Colors.grey : Colors.blue,
            child: const Icon(Icons.edit),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'delete',
            onPressed: motoristaSelecionado == null ? null : _confirmarExcluirMotorista,
            backgroundColor: motoristaSelecionado == null ? Colors.grey : Colors.red,
            child: const Icon(Icons.delete),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'logout',
            onPressed: () {
              Navigator.pop(context); // Retorna para a tela anterior
            },
            backgroundColor: Colors.black54,
            child: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
    );
  }
}
