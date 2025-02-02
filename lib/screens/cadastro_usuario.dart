import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prototipo1precadastro/screens/home.dart';

class CadastroUsuario extends StatelessWidget {
  static const String id = 'cadastro_usuario';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _usuariosRef =
      Firestore.instance.collection('usuarios');
  final TextEditingController textEditingControllerEmail =
      new TextEditingController();
  final TextEditingController textEditingControllerSenha =
      new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Icon(
              Icons.person_add,
              size: 150,
            ),
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email',
              ),
              controller: textEditingControllerEmail,
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Senha',
              ),
              controller: textEditingControllerSenha,
            ),
            FlatButton(
              child: Text('Cadastrar'),
              onPressed: () async {
                var email = textEditingControllerEmail.text;
                var senha = textEditingControllerSenha.text;

                var resultado = await _auth.createUserWithEmailAndPassword(
                    email: email, password: senha);

                if (resultado.user != null) {
                  _usuariosRef.document(resultado.user.uid).setData({
                    'Email': email,
                    'Nome': '',
                  });
                  Navigator.of(context).pushReplacementNamed(Home.id);
                } else {
                  print('Erro');
                }
              },
            ),
            FlatButton(
              child: Text('Voltar'),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
