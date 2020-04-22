import 'package:flutter/foundation.dart';
import 'package:prototipo1precadastro/services/auth_service.dart';

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