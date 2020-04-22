import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prototipo1precadastro/screens/configuracoes.dart';
import 'package:prototipo1precadastro/screens/login.dart';
import 'package:prototipo1precadastro/screens/solicitacoes_feitas.dart';
import 'package:prototipo1precadastro/screens/tipos_solicitacao.dart';

const IconData kIconePrimeiraOpcao = Icons.home;
const IconData kIconeSegundaOpcao = Icons.contacts;
const IconData kIconeTerceiraOpcao = Icons.settings;
const String kTextPrimeiraOpcao = 'Início';
const String kTextSegundaOpcao = 'Solicitações';
const String kTextTerceiraOpcao = 'Cadastro';
const int kIndicePaginaInicial = 0;

class Home extends StatefulWidget {
  static String id = 'Home';
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PageController pageController;
  int pageIndex = kIndicePaginaInicial;
  bool isUsuarioLogado = false;

  static List<Widget> _telasNavegacao = <Widget>[
    TiposSolicitacao(),
    SolicitacoesFeitas(),
    Configuracoes(),
  ];

  static List<BottomNavigationBarItem> _itensNavegacao = [
    BottomNavigationBarItem(
      icon: Icon(kIconePrimeiraOpcao),
      title: Text(kTextPrimeiraOpcao),
    ),
    BottomNavigationBarItem(
      icon: Icon(kIconeSegundaOpcao),
      title: Text(kTextSegundaOpcao),
    ),
    BottomNavigationBarItem(
      icon: Icon(kIconeTerceiraOpcao),
      title: Text(kTextTerceiraOpcao),
    ),
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController();

    FirebaseAuth.instance.onAuthStateChanged.listen((firebaseUser) {
      setState(() {
        isUsuarioLogado = (firebaseUser != null);
        pageIndex = kIndicePaginaInicial;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isUsuarioLogado ? buildTelaInicialUsuarioAutorizado() : Login();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Scaffold buildTelaInicialUsuarioAutorizado() {
    return Scaffold(
      body: PageView(
        children: _telasNavegacao,
        controller: pageController,
        onPageChanged: _onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: Platform.isIOS
          ? _buildBottomNavigationBariOS()
          : _buildBottomNavigationBarAndroid(),
    );
  }

  void _onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  void _onTap(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  CupertinoTabBar _buildBottomNavigationBariOS() {
    return CupertinoTabBar(
      currentIndex: pageIndex,
      onTap: _onTap,
      items: _itensNavegacao,
    );
  }

  BottomNavigationBar _buildBottomNavigationBarAndroid() {
    return BottomNavigationBar(
      currentIndex: pageIndex,
      onTap: _onTap,
      items: _itensNavegacao,
    );
  }
}
