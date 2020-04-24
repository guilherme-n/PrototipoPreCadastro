import 'package:flutter/foundation.dart';

class ConfiguracoesGlobais extends ChangeNotifier{
  String _idUsuarioAtual;

  setIdUsuarioAtual(String idUsuarioAtual){
    _idUsuarioAtual = idUsuarioAtual;
    notifyListeners();
  }

  String getIdUsuarioAtual(){
    return _idUsuarioAtual;
  }
}