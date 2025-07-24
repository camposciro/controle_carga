import '../models/carga.dart';

class CargaRepository {
  final List<Carga> _cargas = [
    Carga(
      id: '1',
      numeroCTE: 'CTE12345',
      dataCarregamento: DateTime.now().subtract(Duration(days: 3)),
      pesoKg: 1500,
      status: 'Pendente',
      vale: false,
      motoristaId: 'm1',
      motoristaNome: 'João Silva',
    ),
    Carga(
      id: '2',
      numeroCTE: 'CTE67890',
      dataCarregamento: DateTime.now().subtract(Duration(days: 1)),
      pesoKg: 1200,
      status: 'Entregue',
      vale: true,
      motoristaId: 'm2',
      motoristaNome: 'Maria Souza',
    ),
  ];

  Future<List<Carga>> buscarTodasCargas() async {
    await Future.delayed(Duration(milliseconds: 500));
    return List.from(_cargas);
  }

  Future<void> excluirCarga(String id) async {
    _cargas.removeWhere((c) => c.id == id);
    await Future.delayed(Duration(milliseconds: 300));
  }

  Future<void> atualizarCarga(Carga cargaAtualizada) async {
    final index = _cargas.indexWhere((c) => c.id == cargaAtualizada.id);
    if (index != -1) {
      _cargas[index] = cargaAtualizada;
    }
    await Future.delayed(Duration(milliseconds: 300));
  }
}
