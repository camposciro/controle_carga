import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/usuario.dart';

class FormUsuarioPage extends StatefulWidget {
  final AuthService authService;
  final Usuario? usuario;
  final PerfilUsuario perfilInicial; // perfil fixo

  const FormUsuarioPage({
    Key? key,
    required this.authService,
    this.usuario,
    required this.perfilInicial,
  }) : super(key: key);

  @override
  State<FormUsuarioPage> createState() => _FormUsuarioPageState();
}

class _FormUsuarioPageState extends State<FormUsuarioPage> {
  final _formKey = GlobalKey<FormState>();

  late PerfilUsuario _perfil;
  late TextEditingController _nomeController;
  late TextEditingController _loginController;
  late TextEditingController _senhaController;

  // Novos campos sempre exibidos (não obrigatórios)
  late TextEditingController _telefoneController;
  late TextEditingController _enderecoController;
  late TextEditingController _documentoCpfController;

  // Campos específicos de motorista
  late TextEditingController _documentoCnhController;
  DateTime? _dataAdmissao;

  @override
  void initState() {
    super.initState();
    final u = widget.usuario;
    _perfil = widget.perfilInicial;

    if (u != null) {
      _nomeController = TextEditingController(text: u.nome);
      _loginController = TextEditingController(text: u.login);
      _senhaController = TextEditingController(text: u.senha);

      if (u is MotoristaUsuario) {
        _telefoneController = TextEditingController(text: u.telefone);
        _enderecoController = TextEditingController(text: u.endereco);
        _documentoCpfController = TextEditingController(text: u.cpf);
        _documentoCnhController = TextEditingController(text: u.cnh);
        _dataAdmissao = u.dataAdmissao;
      } else {
        _telefoneController = TextEditingController();
        _enderecoController = TextEditingController();
        _documentoCpfController = TextEditingController();
        _documentoCnhController = TextEditingController();
      }
    } else {
      _nomeController = TextEditingController();
      _loginController = TextEditingController();
      _senhaController = TextEditingController();
      _telefoneController = TextEditingController();
      _enderecoController = TextEditingController();
      _documentoCpfController = TextEditingController();
      _documentoCnhController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _loginController.dispose();
    _senhaController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    _documentoCpfController.dispose();
    _documentoCnhController.dispose();
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
        cpf: _documentoCpfController.text.trim(),
        cnh: _documentoCnhController.text.trim(),
        dataAdmissao: _dataAdmissao,
      );
    } else {
      novoUsuario = UsuarioComDocumento(
        id: widget.usuario?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        nome: _nomeController.text.trim(),
        login: _loginController.text.trim(),
        senha: _senhaController.text.trim(),
        perfil: PerfilUsuario.administrador,
        telefone: _telefoneController.text.trim(),
        endereco: _enderecoController.text.trim(),
        cpf: _documentoCpfController.text.trim(),
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
              // Sem campo perfil

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

              // Novos campos opcionais (aparece para todos os perfis)
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
                controller: _documentoCpfController,
                decoration: const InputDecoration(labelText: 'Documento (ex: CPF)'),
              ),

              // Campos exclusivos para Motorista
              if (_perfil == PerfilUsuario.motorista) ...[
                TextFormField(
                  controller: _documentoCnhController,
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

// MotoristaUsuario estendido com novos campos
class MotoristaUsuario extends Usuario {
  final String telefone;
  final String endereco;
  final String cpf;
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
    this.cpf = '',
    this.cnh = '',
    this.dataAdmissao,
  });
}

// Novo usuário com documento para Admin (pode extender Usuario)
class UsuarioComDocumento extends Usuario {
  final String telefone;
  final String endereco;
  final String cpf;

  UsuarioComDocumento({
    required super.id,
    required super.nome,
    required super.login,
    required super.senha,
    required super.perfil,
    this.telefone = '',
    this.endereco = '',
    this.cpf = '',
  });
}
