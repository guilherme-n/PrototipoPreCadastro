import 'package:flutter/material.dart';
import 'package:prototipo1precadastro/screens/login.dart';
import 'package:prototipo1precadastro/services/auth_service.dart';

class ResetarSenha extends StatelessWidget {
  static const String id = 'resetar_senha';
  final AuthService _authService = AuthService();

  TextEditingController _textEditingControllerEmail = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Redefinir senha'),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Email',
            ),
            controller: _textEditingControllerEmail,
          ),
          FlatButton(
            child: Text('Enviar'),
            onPressed: () async{
              var email = _textEditingControllerEmail.text;
              await _authService.sendPasswordResetEmail(email);
              Navigator.pushNamed(context, Login.id);
            },
          ),
        ],
      ),
    );
  }
}
