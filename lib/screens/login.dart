import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prototipo1precadastro/screens/cadastro_usuario.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:prototipo1precadastro/screens/resetar_senha.dart';

class Login extends StatefulWidget {
  static const String id = 'login';
  static const String kUserIdName = 'userId';

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  FirebaseAuth _auth;
  TextEditingController _textEditingControllerEmail;
  TextEditingController _textEditingControllerSenha;
  bool _isCarregando;

  @override
  void initState() {
    super.initState();

    _auth = FirebaseAuth.instance;
    _textEditingControllerEmail = new TextEditingController();
    _textEditingControllerSenha = new TextEditingController();
    _isCarregando = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: _isCarregando,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(
                Icons.person_pin,
                size: 150,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                ),
                controller: _textEditingControllerEmail,
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Senha',
                ),
                controller: _textEditingControllerSenha,
              ),
              Builder(
                builder: (parentContext) => FlatButton(
                  child: Text('Entrar'),
                  onPressed: () async {
                    var email = _textEditingControllerEmail.text;
                    var senha = _textEditingControllerSenha.text;

                    setState(() {
                      _isCarregando = true;
                    });

                    String _msgErro;

                    try {
                      await _auth.signInWithEmailAndPassword(
                        email: email,
                        password: senha,
                      );
                    } catch (error) {
                      print(error);
                      switch (error.code) {
                        case "ERROR_INVALID_EMAIL":
                          _msgErro = "Endereço de email mal formatado";
                          break;
                        case "ERROR_WRONG_PASSWORD":
                          _msgErro = "Senha errada.";
                          break;
                        case "ERROR_USER_NOT_FOUND":
                          _msgErro = "Email não cadastrado";
                          break;
                        case "ERROR_USER_DISABLED":
                          _msgErro = "Usuário desabilitado";
                          break;
                        case "ERROR_TOO_MANY_REQUESTS":
                          _msgErro =
                              "Muitas requisições. Tente novamente mais tarde.";
                          break;
                        case "ERROR_OPERATION_NOT_ALLOWED":
                          _msgErro =
                              "Este tipo de autenticação não está habilitado.";
                          break;
                        default:
                          _msgErro = "Erro desconhecido.";
                      }
                    }

                    if (this.mounted) {
                      setState(() {
                        _isCarregando = false;
                      });
                    }

                    if (_msgErro != null) {
                      Scaffold.of(parentContext).hideCurrentSnackBar();
                      Scaffold.of(parentContext).showSnackBar(SnackBar(
                        content: (Text(_msgErro)),
                      ));
                    }
                  },
                ),
              ),
              FlatButton(
                child: Text('Não tem conta? Crie agora.'),
                onPressed: () {
                  Navigator.pushNamed(context, CadastroUsuario.id);
                },
              ),
              FlatButton(
                child: Text('Esqueceu a senha?'),
                onPressed: () {
                  Navigator.pushNamed(context, ResetarSenha.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
