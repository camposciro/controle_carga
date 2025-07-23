import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../repositories/usuario_repository.dart'; // ajuste para o local correto do seu repositório

class CadastroCargaPage extends StatefulWidget {
  const CadastroCargaPage({super.key});

  @override
  State<CadastroCargaPage> createState() => _CadastroCargaPageState();
}

class _CadastroCargaPageState extends State<CadastroCargaPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _numeroCTEController = TextEditingController();
  final TextEditingController _dataCarregamentoController = TextEditingController();
  final TextEditingController _pesoKgController = TextEditingController();

  String _status = 'Pendente';
  bool _vale = false;

  List<Usuario> _motoristas = [];
  Usuario? _motoristaSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarMotoristas();
  }

  Future<void> _carregarMotoristas() async {
    try {
      final motoristas = await UsuarioRepository().listarMotoristas(); // <-- ajuste conforme seu projeto
      setState(() {
        _motoristas = motoristas;
      });
    } catch (e) {
      print('Erro ao carregar motoristas: $e');
      // Você pode exibir um erro amigável aqui, se desejar
    }
  }

  void _salvarCarga() {
    if (_formKey.currentState!.validate()) {
      if (_motoristaSelecionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione um motorista')),
        );
        return;
      }

      print('Motorista: ${_motoristaSelecionado!.nome}');
      print('CTE: ${_numeroCTEController.text}');
      print('Data: ${_dataCarregamentoController.text}');
      print('Peso: ${_pesoKgController.text}');
      print('Status: $_status');
      print('Vale: $_vale');

      // Aqui você pode chamar seu método para salvar a carga com os dados acima

      Navigator.pop(context); // Retorna à tela anterior após salvar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Carga')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Usuario>(
                decoration: const InputDecoration(labelText: 'Motorista'),
                value: _motoristaSelecionado,
                items: _motoristas.map((usuario) {
                  return DropdownMenuItem<Usuario>(
                    value: usuario,
                    child: Text(usuario.nome),
                  );
                }).toList(),
                onChanged: (usuario) {
                  setState(() => _motoristaSelecionado = usuario);
                },
                validator: (value) => value == null ? 'Selecione um motorista' : null,
              ),
              TextFormField(
                controller: _numeroCTEController,
                decoration: const InputDecoration(labelText: 'Número do CTE'),
                validator: (value) => value!.isEmpty ? 'Informe o número do CTE' : null,
              ),
              TextFormField(
                controller: _dataCarregamentoController,
                decoration: const InputDecoration(labelText: 'Data de Carregamento'),
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final data = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2022),
                    lastDate: DateTime(2100),
                  );
                  if (data != null) {
                    _dataCarregamentoController.text = data.toIso8601String().split('T').first;
                  }
                },
              ),
              TextFormField(
                controller: _pesoKgController,
                decoration: const InputDecoration(labelText: 'Peso (KG)'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['Pendente', 'Carregada', 'Entregue']
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) => setState(() => _status = value!),
              ),
              SwitchListTile(
                title: const Text('Possui Vale?'),
                value: _vale,
                onChanged: (value) => setState(() => _vale = value),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: _salvarCarga, child: const Text('Salvar')),
                  OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
