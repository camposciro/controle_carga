import 'package:flutter/material.dart';
import 'form_usuario_page.dart';
import 'cadastro_carga_page.dart';
import 'listar_cargas_page.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  final AuthService authService;

  const HomePage({Key? key, required this.authService}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late bool isAdmin;

  @override
  void initState() {
    super.initState();
    isAdmin = widget.authService.usuarioLogado?.perfil == PerfilUsuario.administrador;
    _tabController = TabController(length: isAdmin ? 4 : 1, vsync: this);
  }

  void _abrirPagina(BuildContext context, String titulo) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaginaPlaceholder(titulo: titulo)),
    );
  }

  Future<void> _escolherPerfilECadastrar() async {
    final perfilEscolhido = await showDialog<PerfilUsuario>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Tipo de Usuário'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.local_shipping),
              title: const Text('Motorista'),
              onTap: () => Navigator.pop(context, PerfilUsuario.motorista),
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Administrador'),
              onTap: () => Navigator.pop(context, PerfilUsuario.administrador),
            ),
          ],
        ),
      ),
    );

    if (perfilEscolhido != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FormUsuarioPage(
            authService: widget.authService,
            perfilInicial: perfilEscolhido,
          ),
        ),
      );
    }
  }

  List<_BotaoHome> _botoesCarga() => [
    _BotaoHome(Icons.add_box, 'Cadastrar', () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CadastroCargaPage()),
      );
    }),
    _BotaoHome(Icons.list, 'Listar', () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListarCargasPage(authService: widget.authService),
        ),
      );
    }),
  ];

  List<_BotaoHome> _botoesMotorista() => [
    _BotaoHome(Icons.local_shipping, 'Motoristas', () => _abrirPagina(context, 'Listar Motoristas')),
    _BotaoHome(Icons.person_add, 'Adicionar', () => _abrirPagina(context, 'Adicionar Motorista')),
    _BotaoHome(Icons.person, 'Editar', () => _abrirPagina(context, 'Editar Motorista')),
    _BotaoHome(Icons.delete_forever, 'Excluir', () => _abrirPagina(context, 'Excluir Motorista')),
  ];

  List<_BotaoHome> _botoesUsuario() => [
    _BotaoHome(Icons.group, 'Usuários', () => _abrirPagina(context, 'Listar Usuários')),
    _BotaoHome(Icons.person_add_alt, 'Cadastrar', _escolherPerfilECadastrar),
    _BotaoHome(Icons.edit_attributes, 'Editar', () => _abrirPagina(context, 'Editar Usuário')),
  ];

  List<_BotaoHome> _botoesRelatorio() => [
    _BotaoHome(Icons.attach_money, 'Ganhos', () => _abrirPagina(context, 'Relatório de Ganhos')),
    _BotaoHome(Icons.show_chart, 'Atividades', () => _abrirPagina(context, 'Resumo de Atividades')),
    _BotaoHome(Icons.receipt, 'Relatórios', () => _abrirPagina(context, 'Relatórios por Motorista')),
  ];

  List<_BotaoHome> _botoesMotoristaSimples() => [
    _BotaoHome(Icons.list, 'Listar', () => _abrirPagina(context, 'Listar Cargas')),
    _BotaoHome(Icons.attach_money, 'Ganhos', () => _abrirPagina(context, 'Relatório de Ganhos')),
    _BotaoHome(Icons.settings, 'Configurações', () => _abrirPagina(context, 'Configurações')),
    _BotaoHome(Icons.lock, 'Senha', () => _abrirPagina(context, 'Trocar Senha')),
    _BotaoHome(Icons.exit_to_app, 'Sair', () => Navigator.pop(context)),
  ];

  int _calcularColunas(double largura) {
    if (largura >= 1200) return 8;
    if (largura >= 900) return 6;
    if (largura >= 600) return 4;
    return 2;
  }

  Widget _buildGrid(List<_BotaoHome> botoes, double largura) {
    final colunas = _calcularColunas(largura);
    return GridView.count(
      crossAxisCount: colunas,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1,
      physics: const BouncingScrollPhysics(),
      children: botoes
          .map(
            (b) => OutlinedButton(
          onPressed: b.onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(8),
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.blue.shade300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(b.icon, size: 28, color: Colors.blue.shade700),
              const SizedBox(height: 8),
              Text(
                b.label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final largura = constraints.maxWidth;
            return isAdmin
                ? Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 4),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: const [
                      Tab(text: 'Cargas'),
                      Tab(text: 'Motoristas'),
                      Tab(text: 'Usuários'),
                      Tab(text: 'Relatórios'),
                    ],
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(fontSize: 14),
                    unselectedLabelStyle: const TextStyle(fontSize: 14),
                    indicatorColor: Colors.blue,
                    indicatorWeight: 3,
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildGrid(_botoesCarga(), largura),
                      _buildGrid(_botoesMotorista(), largura),
                      _buildGrid(_botoesUsuario(), largura),
                      _buildGrid(_botoesRelatorio(), largura),
                    ],
                  ),
                )
              ],
            )
                : _buildGrid(_botoesMotoristaSimples(), largura);
          },
        ),
      ),
    );
  }
}

class _BotaoHome {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  _BotaoHome(this.icon, this.label, this.onPressed);
}

class PaginaPlaceholder extends StatelessWidget {
  final String titulo;

  const PaginaPlaceholder({Key? key, required this.titulo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(child: Text('Página "$titulo" em construção')),
    );
  }
}
