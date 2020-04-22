import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prototipo1precadastro/Util/configuracoes_globais.dart';
import 'package:prototipo1precadastro/screens/cadastro_usuario.dart';
import 'package:prototipo1precadastro/screens/criacao_solicitacao.dart';
import 'package:prototipo1precadastro/screens/home.dart';
import 'package:prototipo1precadastro/screens/home.dart';
import 'package:prototipo1precadastro/screens/login.dart';
import 'package:prototipo1precadastro/screens/resetar_senha.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(PreCadastroApp());
  });
}

class PreCadastroApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ConfiguracoesGlobais>(
      create: (context) => ConfiguracoesGlobais(),
      child: GestureDetector(
        onTap: (){
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.blue[900],
            accentColor: Colors.blue[900],
          ),
          initialRoute: Home.id,
          routes: {
            Login.id: (context) => Login(),
            CadastroUsuario.id: (context) => CadastroUsuario(),
            Home.id: (context) => Home(),
            CriacaoSolicitacao.id: (context) => CriacaoSolicitacao(),
            ResetarSenha.id: (context) => ResetarSenha(),
          },
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
