import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CardSolicitacoesFeitas extends StatelessWidget {
  final String texto;
  final DateTime dataSolicitacao;

  const CardSolicitacoesFeitas({Key key, this.texto, this.dataSolicitacao}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: Theme.of(context).primaryColor,
          padding: EdgeInsets.symmetric(vertical: 20),
          child: ListTile(
            leading: Icon(Icons.announcement),
            title: Text(texto),
            subtitle: Text('Solicitado em: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(dataSolicitacao)}'),
          ),
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }
}