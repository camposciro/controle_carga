import '../models/usuario.dart';

class AuthService {
  // Lista fixa de usuários para teste
  final List<Usuario> _usuarios = [
    Usuario(
      id: '1',
      nome: 'Douglas',
      login: 'douglas',
      senha: '1234',
      perfil: PerfilUsuario.administrador,
    ),
    Usuario(
      id: '2',
      nome: 'João',
      login: 'joao',
      senha: 'abcd',
      perfil: PerfilUsuario.motorista,
    ),
  ];

  // Getter público para acessar todos os usuários
  List<Usuario> get usuarios => _usuarios;

  Usuario? _usuarioLogado;

  Usuario? get usuarioLogado => _usuarioLogado;

  // Método para login
  Future<bool> login(String login, String senha) async {
    // Simular demora para imitar uma requisição
    await Future.delayed(const Duration(seconds: 1));

    try {
      final usuario = _usuarios.firstWhere(
            (u) => u.login == login && u.senha == senha,
      );
      _usuarioLogado = usuario;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Método para logout
  void logout() {
    _usuarioLogado = null;
  }
}
