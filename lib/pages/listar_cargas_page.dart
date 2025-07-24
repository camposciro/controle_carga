import 'package:flutter/material.dart';
import '../models/carga.dart';
import '../repositories/carga_repository.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import 'editar_carga_page.dart';

class ListarCargasPage extends StatefulWidget {
  final AuthService authService;

  const ListarCargasPage({Key? key, required this.authService}) : super(key: key);

  @override
  State<ListarCargasPage> createState() => _ListarCargasPageState();
}

class _ListarCargasPageState extends State<ListarCargasPage> {
  final CargaRepository _cargaRepository = CargaRepository();

  List<Carga> _cargas = [];
  List<Carga> _cargasFiltradas = [];
  Carga? _cargaSelecionada;

  String _filtroCTE = '';
  String _filtroStatus = 'Todos';

  bool get isAdmin => widget.authService.usuarioLogado?.perfil == PerfilUsuario.administrador;

  @override
  void initState() {
    super.initState();
    _carregarCargas();
  }

  Future<void> _carregarCargas() async {
    List<Carga> todasCargas = await _cargaRepository.buscarTodasCargas();

    if (!isAdmin) {
      final usuarioId = widget.authService.usuarioLogado?.id;
      todasCargas = todasCargas.where((c) => c.motoristaId == usuarioId).toList();
    }

    setState(() {
      _cargas = todasCargas;
      _aplicarFiltro();
    });
  }

  void _aplicarFiltro() {
    setState(() {
      _cargasFiltradas = _cargas.where((c) {
        final cteMatch = _filtroCTE.isEmpty || c.numeroCTE.toLowerCase().contains(_filtroCTE.toLowerCase());
        final statusMatch = _filtroStatus == 'Todos' || c.status == _filtroStatus;
        return cteMatch && statusMatch;
      }).toList();
    });
  }

  void _editarCarga() async {
    if (_cargaSelecionada == null) return;
    final atualizado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditarCargaPage(carga: _cargaSelecionada!)),
    );
    if (atualizado == true) {
      await _carregarCargas();
    }
  }

  void _excluirCarga() async {
    if (_cargaSelecionada == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmação'),
        content: Text('Deseja excluir a carga ${_cargaSelecionada!.numeroCTE}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );

    if (confirm == true) {
      await _cargaRepository.excluirCarga(_cargaSelecionada!.id);
      await _carregarCargas();
      setState(() => _cargaSelecionada = null);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Carga excluída com sucesso')));
    }
  }

  void _sair() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listar Cargas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (isMobile)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Número do CTE',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _filtroCTE = value;
                      _aplicarFiltro();
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _filtroStatus,
                    items: ['Todos', 'Pendente', 'Carregada', 'Entregue']
                        .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _filtroStatus = value;
                        _aplicarFiltro();
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Número do CTE',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _filtroCTE = value;
                        _aplicarFiltro();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _filtroStatus,
                      items: ['Todos', 'Pendente', 'Carregada', 'Entregue']
                          .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _filtroStatus = value;
                          _aplicarFiltro();
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Expanded(
              child: _cargasFiltradas.isEmpty
                  ? const Center(child: Text('Nenhuma carga encontrada'))
                  : ListView.separated(
                itemCount: _cargasFiltradas.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final carga = _cargasFiltradas[index];
                  return ListTile(
                    title: Text('CTE: ${carga.numeroCTE}'),
                    subtitle: Text('Status: ${carga.status}\nMotorista: ${carga.motoristaNome}'),
                    isThreeLine: true,
                    selected: _cargaSelecionada == carga,
                    selectedTileColor: Colors.blue.shade50,
                    onTap: isAdmin
                        ? () {
                      setState(() {
                        _cargaSelecionada =
                        _cargaSelecionada == carga ? null : carga;
                      });
                    }
                        : null,
                  );
                },
              ),
            ),
            if (isAdmin)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cada botão ocupa espaço igual
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton.icon(
                          onPressed: _cargaSelecionada == null ? null : _editarCarga,
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _cargaSelecionada == null ? Colors.grey : Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton.icon(
                          onPressed: _cargaSelecionada == null ? null : _excluirCarga,
                          icon: const Icon(Icons.delete),
                          label: const Text('Excluir'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _cargaSelecionada == null ? Colors.grey : Colors.red,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton.icon(
                          onPressed: _sair,
                          icon: const Icon(Icons.exit_to_app),
                          label: const Text('Sair'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade50,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
