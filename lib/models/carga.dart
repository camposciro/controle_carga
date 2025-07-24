class Carga {
  final String id;
  final String numeroCTE;
  final DateTime dataCarregamento;
  final double pesoKg;
  final String status;
  final bool vale;
  final String motoristaId;
  final String motoristaNome;

  Carga({
    required this.id,
    required this.numeroCTE,
    required this.dataCarregamento,
    required this.pesoKg,
    required this.status,
    required this.vale,
    required this.motoristaId,
    required this.motoristaNome,
  });

  Carga copyWith({
    String? id,
    String? numeroCTE,
    DateTime? dataCarregamento,
    double? pesoKg,
    String? status,
    bool? vale,
    String? motoristaId,
    String? motoristaNome,
  }) {
    return Carga(
      id: id ?? this.id,
      numeroCTE: numeroCTE ?? this.numeroCTE,
      dataCarregamento: dataCarregamento ?? this.dataCarregamento,
      pesoKg: pesoKg ?? this.pesoKg,
      status: status ?? this.status,
      vale: vale ?? this.vale,
      motoristaId: motoristaId ?? this.motoristaId,
      motoristaNome: motoristaNome ?? this.motoristaNome,
    );
  }
}
