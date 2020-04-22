import 'package:flutter/material.dart';

class BotaoSolicitarServico extends StatelessWidget {
  final IconData icone;
  final String texto;
  final Function onClick;

  const BotaoSolicitarServico(
      {Key key,
      @required this.icone,
      @required this.texto,
      @required this.onClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).primaryColor,
      child: InkWell(
        onTap: onClick,
        child: Container(
          height: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                this.icone,
                size: 50,
              ),
              SizedBox(
                width: 30,
              ),
              Text(
                this.texto,
                style: TextStyle(
                  fontSize: 30,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
