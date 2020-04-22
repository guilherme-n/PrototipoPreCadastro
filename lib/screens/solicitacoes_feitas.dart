import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prototipo1precadastro/Util/configuracoes_globais.dart';
import 'package:prototipo1precadastro/components/card_solicitacoes_feitas.dart';
import 'package:prototipo1precadastro/components/header.dart';
import 'package:prototipo1precadastro/components/progress.dart';
import 'package:provider/provider.dart';

class SolicitacoesFeitas extends StatelessWidget {
  final CollectionReference _refPedidos =
      Firestore.instance.collection('pedidos');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(texto: 'Suas solicitações em aberto'),
      body: Column(
        children: <Widget>[
          Consumer<ConfiguracoesGlobais>(
            builder: (_, configuracao, __) => StreamBuilder<QuerySnapshot>(
              stream: _refPedidos
                  .where('idUsuario',
                      isEqualTo: configuracao.getIdUsuarioAtual())
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return circularProgress(context);
                }

                final pedidos = snapshot.data.documents;
                List<CardSolicitacoesFeitas> cards = [];

                for (var pedido in pedidos) {
                  String tipoCertidao = pedido.data['tipoPedido'];
                  Timestamp dataSolicitacao = pedido.data['dataSolicitacao'];

                  cards.add(CardSolicitacoesFeitas(
                    texto: tipoCertidao,
                    dataSolicitacao: dataSolicitacao.toDate(),
                  ));
                }

                return Expanded(
                  child: ListView(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                    children: cards,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
