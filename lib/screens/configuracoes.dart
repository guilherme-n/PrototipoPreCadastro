import 'package:flutter/material.dart';
import 'package:prototipo1precadastro/components/header.dart';
import 'package:prototipo1precadastro/services/auth_service.dart';

class Configuracoes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(isAppTitle: false, texto: 'Configuracoes'),
      body: Column(
        children: <Widget>[
          FlatButton(
            child: Text('Sair'),
            onPressed: () async{
              AuthService auth = AuthService();
              auth.signout();
            },
          ),
        ],
      ),
    );
  }
}