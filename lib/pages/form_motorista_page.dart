import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/usuario.dart';

class FormUsuarioPage extends StatefulWidget {
  final AuthService authService;
  final Usuario? usuario;

  const FormUsuarioPage({Key? key, required this.authService, this.usuario}) : super(key: key);

  @override
  State<FormUsuarioPage> createState() => _FormUsuarioPageState();
}

class _FormUsuarioPageState extends State<FormUsuarioPage> {
  final _formKey = GlobalKey<FormState>();

  PerfilUsuario? _perfil;
  late TextEditingController _nomeController;
  late TextEditingController _loginController;
  late TextEditingController _senhaController;
  late TextEditingController _telefoneController;
  late TextEditingController _enderecoController;
  late TextEditingController _cnhController;
  DateTime? _dataAdmissao;

  @override
  void initState() {
    super.initState();
    final u = widget.usuario;
    if (u != null) {
      _perfil = u.perfil;
      _nomeController = TextEditingController(text: u.nome);
      _loginController = TextEditingController(text: u.login);
      _senhaController = TextEditingController(text: u.senha);
      if (u is MotoristaUsuario) {
        _telefoneController = TextEditingController(text: u.telefone);
        _enderecoController = TextEditingController(text: u.endereco);
        _cnhController = TextEditingController(text: u.cnh);
        _dataAdmissao = u.dataAdmissao;
      } else {
        _telefoneController = TextEditingController();
        _enderecoController = TextEditingController();
        _cnhController = TextEditingController();
      }
    } else {
      _perfil = PerfilUsuario.motorista; // padrão
      _nomeController = TextEditingController();
      _loginController = TextEditingController();
      _senhaController = TextEditingController();
      _telefoneController = TextEditingController();
      _enderecoController = TextEditingController();
      _cnhController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _loginController.dispose();
    _senhaController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    _cnhController.dispose();
    super.dispose();
  }

  Future<void> _selecionarDataAdmissao() async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataAdmissao ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (dataSelecionada != null) {
      setState(() {
        _dataAdmissao = dataSelecionada;
      });
    }
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    Usuario novoUsuario;

    if (_perfil == PerfilUsuario.motorista) {
      novoUsuario = MotoristaUsuario(
        id: widget.usuario?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        nome: _nomeController.text.trim(),
        login: _loginController.text.trim(),
        senha: _senhaController.text.trim(),
        perfil: PerfilUsuario.motorista,
        telefone: _telefoneController.text.trim(),
        endereco: _enderecoController.text.trim(),
        cnh: _cnhController.text.trim(),
        dataAdmissao: _dataAdmissao,
      );
    } else {
      novoUsuario = Usuario(
        id: widget.usuario?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        nome: _nomeController.text.trim(),
        login: _loginController.text.trim(),
        senha: _senhaController.text.trim(),
        perfil: PerfilUsuario.administrador,
      );
    }

    if (widget.usuario == null) {
      widget.authService.usuarios.add(novoUsuario);
    } else {
      final index = widget.authService.usuarios.indexWhere((u) => u.id == novoUsuario.id);
      if (index != -1) {
        widget.authService.usuarios[index] = novoUsuario;
      }
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditando = widget.usuario != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditando ? 'Editar Usuário' : 'Novo Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<PerfilUsuario>(
                value: _perfil,
                decoration: const InputDecoration(labelText: 'Perfil'),
                items: const [
                  DropdownMenuItem(
                    value: PerfilUsuario.motorista,
                    child: Text('Motorista'),
                  ),
                  DropdownMenuItem(
                    value: PerfilUsuario.administrador,
                    child: Text('Administrador'),
                  ),
                ],
                onChanged: (p) {
                  setState(() {
                    _perfil = p;
                  });
                },
              ),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Informe o nome' : null,
              ),
              TextFormField(
                controller: _loginController,
                decoration: const InputDecoration(labelText: 'Login'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Informe o login' : null,
              ),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (v) => v == null || v.trim().isEmpty ? 'Informe a senha' : null,
              ),
              if (_perfil == PerfilUsuario.motorista) ...[
                TextFormField(
                  controller: _telefoneController,
                  decoration: const InputDecoration(labelText: 'Telefone'),
                  keyboardType: TextInputType.phone,
                ),
                TextFormField(
                  controller: _enderecoController,
                  decoration: const InputDecoration(labelText: 'Endereço'),
                ),
                TextFormField(
                  controller: _cnhController,
                  decoration: const InputDecoration(labelText: 'CNH'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(_dataAdmissao == null
                          ? 'Data de Admissão não selecionada'
                          : 'Data de Admissão: ${_dataAdmissao!.toLocal().toString().split(' ')[0]}'),
                    ),
                    ElevatedButton(
                      onPressed: _selecionarDataAdmissao,
                      child: const Text('Selecionar Data'),
                    )
                  ],
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvar,
                child: Text(isEditando ? 'Salvar' : 'Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extensão da classe Usuario para Motorista com novos campos
class MotoristaUsuario extends Usuario {
  final String telefone;
  final String endereco;
  final String cnh;
  final DateTime? dataAdmissao;

  MotoristaUsuario({
    required super.id,
    required super.nome,
    required super.login,
    required super.senha,
    required super.perfil,
    this.telefone = '',
    this.endereco = '',
    this.cnh = '',
    this.dataAdmissao,
  });
}
