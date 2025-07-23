import '../models/usuario.dart';

class UsuarioRepository {
  Future<List<Usuario>> listarMotoristas() async {
    // Simulação de carregamento de motoristas
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      Usuario(
        id: '1',
        nome: 'João Silva',
        login: 'joao.silva',
        senha: 'senha123', // só exemplo, normalmente não armazenar senha assim
        perfil: PerfilUsuario.motorista,
      ),
      Usuario(
        id: '2',
        nome: 'Maria Oliveira',
        login: 'maria.oliveira',
        senha: 'senha123',
        perfil: PerfilUsuario.motorista,
      ),
    ];
  }
}
