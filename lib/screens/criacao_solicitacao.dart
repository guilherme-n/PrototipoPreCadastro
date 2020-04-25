import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prototipo1precadastro/components/alert_dialog.dart';
import 'package:prototipo1precadastro/components/header.dart';
import 'package:prototipo1precadastro/models/pedido.dart';
import 'package:prototipo1precadastro/models/solicitante.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as Im;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

const String _kTextoTituloDialog =
    'Escolha de onde gostaria de enviar o documento';
const String _kTextoImgDaCamera = 'Câmera';
const String _kTextoImgDaGaleria = 'Galeria de imagens';

class CriacaoSolicitacao extends StatefulWidget {
  static const String id = 'criacao_solicitacao';

  @override
  _CriacaoSolicitacaoState createState() => _CriacaoSolicitacaoState();
}

class _CriacaoSolicitacaoState extends State<CriacaoSolicitacao> {
  FirebaseUser _firebaseUser;
  Pedido _pedido = Pedido();
  final _globalKeyForm = GlobalKey<FormState>();

  final StorageReference _storageRef = FirebaseStorage.instance.ref();
  final CollectionReference _pedidosRef =
      Firestore.instance.collection('pedidos');

  bool _isCarregando = false;
  final List<File> _imagens = [null, null];

  final _mascaraCelular = new MaskTextInputFormatter(
      mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {
      _firebaseUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(texto: 'Solicitação de certidão'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ModalProgressHUD(
          inAsyncCall: _isCarregando,
          child: formNovo(),
        ),
      ),
    );
  }

  Form formNovo() {
    return Form(
      key: _globalKeyForm,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'Nome'),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Preencha o nome';
                }
                return null;
              },
              onSaved: (value) {
                this._pedido.solicitante.nome = value;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Celular'),
              keyboardType: TextInputType.number,
              inputFormatters: [_mascaraCelular],
              validator: (value) {
                if (value.isEmpty) {
                  return 'Preencha o celular';
                }
                return null;
              },
              onSaved: (value) {
                this._pedido.solicitante.celular = value;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Preencha o email';
                }
                return null;
              },
              onSaved: (value) {
                this._pedido.solicitante.email = value;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Tipo do pedido'),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Preencha o tipo do pedido';
                }
                return null;
              },
              onSaved: (value) {
                this._pedido.tipoPedido = value;
              },
            ),
            SizedBox(
              height: 20.0,
            ),
            botaoEImagem(textoBotao: 'RG', posicaoArrayImagens: 0),
            SizedBox(height: 20.0),
            botaoEImagem(textoBotao: 'CPF', posicaoArrayImagens: 1),
            SizedBox(height: 20.0),
            RaisedButton(
              color: Colors.green,
              child: const Text(
                'Enviar',
              ),
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Row botaoEImagem(
      {@required String textoBotao, @required int posicaoArrayImagens}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Container(
            color: MediaQuery.of(context).platformBrightness == Brightness.light
                ? Theme.of(context).primaryColorDark
                : Theme.of(context).primaryColorLight,
            child: ListTile(
              leading: Icon(Icons.attach_file),
              title: Text(textoBotao),
              onTap: () {
                if (_imagens[posicaoArrayImagens] == null) {
                  FocusScope.of(context).unfocus();
                  Platform.isIOS
                      ? selectImageiOS(context, posicaoArrayImagens)
                      : selectImageAndroid(context, posicaoArrayImagens);
                }
              },
              trailing: Visibility(
                visible: _imagens[posicaoArrayImagens] != null,
                child: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      _imagens[posicaoArrayImagens] = null;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 20.0,
        ),
        Container(
          width: 100.0,
          height: 100.0,
          decoration: BoxDecoration(
            border: Border.all(),
            image: _imagens[posicaoArrayImagens] == null
                ? null
                : DecorationImage(
                    image: FileImage(_imagens[posicaoArrayImagens]),
                    fit: BoxFit.fill,
                  ),
          ),
        ),
      ],
    );
  }

  void _submit() async {
    if (!_globalKeyForm.currentState.validate()) {
      return;
    }

    setState(() {
      _isCarregando = true;
    });

    _pedido.solicitante = Solicitante();
    _globalKeyForm.currentState.save();
    _pedido.dataSolicitacao = DateTime.now();
    _pedido.idUsuario = _firebaseUser.uid;

    try {
      DocumentReference resultado = await _pedidosRef.add(_pedido.toJson());

      for (File imagem in _imagens) {
        if (imagem != null) {
          String id = Uuid().v4();
          File imagemComprimida = await compressImage(imagem, id);
          String urlArquivo = await uploadImage(imagemComprimida, id);

          await Firestore.instance
              .collection('pedidos/${resultado.documentID}/documentos')
              .add({
            'nomeArquivo': '$id.jgp',
            'urlArquivo': urlArquivo,
            'dataCriacao': _pedido.dataSolicitacao,
          });

          imagem = null;
        }
      }

      if (true) {
        await alertDialog(
          context: context,
          titulo: "Enviado com sucesso.",
          conteudo:
              "Agora é só aguardar. Em poucas horas seu pedido será analisado.",
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text(e)),
      );
    }
    setState(() {
      _isCarregando = false;
    });
  }

  handleTakePhoto(int posicaoArrayImagens) async {
    print('1');
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      _imagens[posicaoArrayImagens] = file;
    });
  }

  handleChooseFromGallery(posicaoArrayImagens) async {
    print('2');
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imagens[posicaoArrayImagens] = file;
    });
  }

  selectImageAndroid(BuildContext parentContext, int posicaoArrayImagens) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text(_kTextoTituloDialog),
          children: <Widget>[
            SimpleDialogOption(
              child: Text(_kTextoImgDaCamera),
              onPressed: (){
                handleTakePhoto(posicaoArrayImagens);
              }
            ),
            SimpleDialogOption(
              child: Text(_kTextoImgDaGaleria),
              onPressed: (){
                handleChooseFromGallery(posicaoArrayImagens);
              }
            ),
            SimpleDialogOption(
              child: Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  selectImageiOS(BuildContext context, int posicaoArrayImagens) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(_kTextoTituloDialog),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text(
                _kTextoImgDaCamera,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onPressed: () {
                handleTakePhoto(posicaoArrayImagens);
              },
            ),
            CupertinoActionSheetAction(
              child: Text(
                _kTextoImgDaGaleria,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onPressed: () {
                handleChooseFromGallery(posicaoArrayImagens);
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(
              'Cancelar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  Future<String> uploadImage(File imageFile, String id) async {
    StorageUploadTask uploadTask =
        _storageRef.child('$id.jpg').putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    return await storageSnap.ref.getDownloadURL();
  }

  Future<File> compressImage(File arquivo, String id) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(arquivo.readAsBytesSync());
    final compressedImageFile = File('$path/img_$id.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));

    return compressedImageFile;
  }
}
