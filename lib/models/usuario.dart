enum PerfilUsuario {
  motorista,
  administrador,
}

class Usuario {
  final String id;
  final String nome;
  final String login;
  final String senha;
  final PerfilUsuario perfil;

  Usuario({
    required this.id,
    required this.nome,
    required this.login,
    required this.senha,
    required this.perfil,
  });
}
