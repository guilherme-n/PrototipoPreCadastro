import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
                  FlutterLocalNotificationsPlugin
                      flutterLocalNotificationsPlugin =
                      FlutterLocalNotificationsPlugin();
                  var initializationSettingsAndroid =
                      AndroidInitializationSettings('app_icon');
                  var initializationSettingsIOS = IOSInitializationSettings(
                    requestSoundPermission: false,
                    requestBadgePermission: false,
                    requestAlertPermission: false,
                    onDidReceiveLocalNotification:
                        onDidReceiveLocalNotification,
                  );
                  var initializationSettings = InitializationSettings(
                      initializationSettingsAndroid, initializationSettingsIOS);
                  await flutterLocalNotificationsPlugin.initialize(
                      initializationSettings,
                      onSelectNotification: (_) {});

                  await flutterLocalNotificationsPlugin
                      .resolvePlatformSpecificImplementation<
                          IOSFlutterLocalNotificationsPlugin>()
                      ?.requestPermissions(
                        alert: true,
                        badge: true,
                        sound: true,
                      );

                  var androidPlatformChannelSpecifics =
                      AndroidNotificationDetails('your channel id',
                          'your channel name', 'your channel description',
                          importance: Importance.Max,
                          priority: Priority.High,
                          ticker: 'ticker');
                  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
                  var platformChannelSpecifics = NotificationDetails(
                      androidPlatformChannelSpecifics,
                      iOSPlatformChannelSpecifics);
                  await flutterLocalNotificationsPlugin.show(
                      0, 'plain title', 'plain body', platformChannelSpecifics,
                      payload: 'item x');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
//    showDialog(
//      context: context,
//      builder: (BuildContext context) => CupertinoAlertDialog(
//        title: Text(title),
//        content: Text(body),
//        actions: [
//          CupertinoDialogAction(
//            isDefaultAction: true,
//            child: Text('Ok'),
//            onPressed: () async {
//              Navigator.of(context, rootNavigator: true).pop();
//              await Navigator.push(
//                context,
//                MaterialPageRoute(
//                  builder: (context) => CriacaoSolicitacao(),
//                ),
//              );
//            },
//          )
//        ],
//      );
  }
}
