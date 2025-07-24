import 'package:flutter/material.dart';
import '../models/carga.dart';
import '../repositories/carga_repository.dart';

class EditarCargaPage extends StatefulWidget {
  final Carga carga;

  const EditarCargaPage({Key? key, required this.carga}) : super(key: key);

  @override
  State<EditarCargaPage> createState() => _EditarCargaPageState();
}

class _EditarCargaPageState extends State<EditarCargaPage> {
  final _formKey = GlobalKey<FormState>();
  final CargaRepository _cargaRepository = CargaRepository();

  late TextEditingController _numeroCTEController;
  late TextEditingController _statusController;

  @override
  void initState() {
    super.initState();
    _numeroCTEController = TextEditingController(text: widget.carga.numeroCTE);
    _statusController = TextEditingController(text: widget.carga.status);
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      // Atualize os dados da carga
      final cargaAtualizada = widget.carga.copyWith(
        numeroCTE: _numeroCTEController.text,
        status: _statusController.text,
      );
      await _cargaRepository.atualizarCarga(cargaAtualizada);
      Navigator.pop(context, true); // Retorna que foi atualizado
    }
  }

  @override
  void dispose() {
    _numeroCTEController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Carga')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _numeroCTEController,
                decoration: const InputDecoration(labelText: 'Número do CTE'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Informe o número do CTE' : null,
              ),
              TextFormField(
                controller: _statusController,
                decoration: const InputDecoration(labelText: 'Status'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Informe o status' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
