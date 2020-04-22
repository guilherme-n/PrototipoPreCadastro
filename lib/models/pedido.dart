import 'package:prototipo1precadastro/models/solicitante.dart';

class Pedido {
  String idUsuario;
  String tipoPedido;
  Solicitante solicitante;
  DateTime dataSolicitacao;

  Pedido({
    this.idUsuario,
    this.tipoPedido,
    this.solicitante,
    this.dataSolicitacao,
  });

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': this.idUsuario,
      'tipoPedido': this.tipoPedido,
      'solicitante': this.solicitante.toJson(),
      'dataSolicitacao': this.dataSolicitacao,
    };
  }
}
