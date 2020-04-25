import 'package:flutter/material.dart';
import 'package:prototipo1precadastro/components/header.dart';
import 'package:prototipo1precadastro/services/auth_service.dart';

class Configuracoes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(isAppTitle: false, texto: 'Configuracoes'),
      body: Center(
        child: FlatButton(
          color: Colors.yellow,
          child: Text('Sair'),
          onPressed: () async{
            AuthService().signout();
          },
        ),
      ),
    );
  }
}