import 'package:prototipo1precadastro/models/solicitante.dart';

class Pedido {
  final String idUsuario;
  final String tipoPedido;
  final Solicitante solicitante;
  final DateTime dataSolicitacao;

  Pedido(
      {this.idUsuario, this.tipoPedido, this.solicitante, this.dataSolicitacao});

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': this.idUsuario,
      'tipoPedido': this.tipoPedido,
      'solicitante': this.solicitante.toJson(),
      'dataSolicitacao': this.dataSolicitacao,
    };
  }
}
