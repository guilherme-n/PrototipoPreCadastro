import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prototipo1precadastro/components/botao_solicitar_servico.dart';
import 'package:prototipo1precadastro/components/header.dart';
import 'criacao_solicitacao.dart';

class TiposSolicitacao extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(isAppTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              BotaoSolicitarServico(
                icone: Icons.map,
                texto: 'Solicitar certidão',
                onClick: () {
                  Navigator.of(context).pushNamed(CriacaoSolicitacao.id);
                },
              ),
              SizedBox(
                height: 40,
              ),
              BotaoSolicitarServico(
                icone: Icons.announcement,
                texto: 'Solicitar escritura',
                onClick: () async {

                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
