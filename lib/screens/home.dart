import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  PageController pageController;
  int pageIndex = kIndicePaginaInicial;
  bool isUsuarioLogado = false;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final CollectionReference _usuariosRef =
      Firestore.instance.collection('usuarios');
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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

        if (isUsuarioLogado) configurePushNotification();

        pageIndex = kIndicePaginaInicial;
      });
    });

    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  configurePushNotification() async {
    var usuarioAtual = await FirebaseAuth.instance.currentUser();
    if (Platform.isIOS) getiOSPermission();

    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    _firebaseMessaging.getToken().then((token) {
      print('Firebase messaging token: $token\n');
      _usuariosRef
          .document(usuarioAtual.uid)
          .updateData({'androidNotificationToken': token});
    });

    _firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> message) async {},
      onResume: (Map<String, dynamic> message) async {},
//      onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
      onMessage: (Map<String, dynamic> message) async {
//        String recipientId;
//        if (Platform.isIOS) {
//          recipientId = message['recipient'];
//        } else {
//          recipientId = message['data']['recipient'];
//        }
//
//        print('recipientId: $recipientId');
//        print('usuarioAtual: $usuarioAtual');
//        if (recipientId == usuarioAtual.uid) {
//          displayNotification();
//          SnackBar snackBar =
//              SnackBar(content: Text('Boleto de pagamento disponível'));
//          _scaffoldKey.currentState.showSnackBar(snackBar);
//        }
      },
    );
  }

//  static Future<dynamic> myBackgroundMessageHandler(
//      Map<String, dynamic> message) async {
//    return Future<void>.value();
//  }

//  static Future<dynamic> fcmBackgroundMessageHandler(
//      Map<String, dynamic> message) {
//    if (message.containsKey('data')) {
//      // Handle data message
//      final dynamic data = message['data'];
//    }
//
//    if (message.containsKey('notification')) {
//      // Handle notification message
//      final dynamic notification = message['notification'];
//    }

//    displayNotification();

//    return null;
  // Or do other work.
//  }

  getiOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(alert: true, badge: true, sound: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print('Configuracoes registradas: $settings');
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
      key: _scaffoldKey,
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

  void displayNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
        0, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SolicitacoesFeitas()),
    );
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SolicitacoesFeitas(),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
