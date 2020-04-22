import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:prototipo1precadastro/components/alert_dialog.dart';
import 'package:prototipo1precadastro/components/header.dart';
import 'package:prototipo1precadastro/models/pedido.dart';
import 'package:prototipo1precadastro/models/solicitante.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as Im;

const String _kTextoTituloDialog =
    'Escolha de onde gostaria de enviar o documento';
const String _kTextoImgDaCamera = 'Através da camera';
const String _kTextoImgDaGaleria = 'Documento da galeria de imagens';

class CriacaoSolicitacao extends StatefulWidget {
  static const String id = 'criacao_solicitacao';

  @override
  _CriacaoSolicitacaoState createState() => _CriacaoSolicitacaoState();
}

class _CriacaoSolicitacaoState extends State<CriacaoSolicitacao> {
  Firestore _firestore = Firestore.instance;
  FirebaseUser _firebaseUser;

  final StorageReference storageRef = FirebaseStorage.instance.ref();
  final pedidosRef = Firestore.instance.collection('pedidos');

  bool _isCarregando = false;
  File file;
  String idDocumento = Uuid().v4();
  final TextEditingController _textEditingControllerNome =
      new TextEditingController();
  final TextEditingController _textEditingControllerCelular =
      new TextEditingController();
  final TextEditingController _textEditingControllerEmail =
      new TextEditingController();
  final TextEditingController _textEditingControllerTipopedido =
      new TextEditingController();

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
          child: Column(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  hintText: 'Nome',
                ),
                controller: _textEditingControllerNome,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Celular',
                ),
                controller: _textEditingControllerCelular,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Email',
                ),
                controller: _textEditingControllerEmail,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Tipo do pedido',
                ),
                controller: _textEditingControllerTipopedido,
              ),
              Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width / 2,
                color: Theme.of(context).primaryColor,
                child: ListTile(
                  onTap: () {
                    if (file == null) {
                      Platform.isIOS
                          ? selectImageiOS(context)
                          : selectImageAndroid(context);
                    }
                  },
                  leading: const Icon(Icons.attach_file),
                  title: const Text('RG'),
                  trailing: Visibility(
                    visible: file != null,
                    child: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          file = null;
                        });
                      },
                    ),
                  ),
                ),
//                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    children: <Widget>[
//                      Icon(Icons.attach_file),
//                      Text('RG'),
//                    ],
//                  ),
              ),
              FlatButton(
                  child: const Text(
                    'Enviar',
                  ),
                  onPressed: _enviarSolicitacao),
            ],
          ),
        ),
      ),
    );
  }

  void _enviarSolicitacao() async {
    setState(() {
      _isCarregando = true;
    });

    try {
      String nome = _textEditingControllerNome.text;
      String celular = _textEditingControllerCelular.text;
      String email = _textEditingControllerEmail.text;
      String tipoPedido = _textEditingControllerTipopedido.text;

      Solicitante solicitante = Solicitante(
        nome: nome,
        celular: celular,
        email: email,
      );

      Pedido pedido = Pedido(
        dataSolicitacao: DateTime.now(),
        solicitante: solicitante,
        tipoPedido: tipoPedido,
        idUsuario: _firebaseUser.uid,
      );

      DocumentReference resultado =
          await _firestore.collection('pedidos').add(pedido.toJson());

      if (file != null) {
        String mediaUrl = await uploadImage(file);

        await Firestore.instance
            .collection('pedidos/${resultado.documentID}/documentos')
            .add({'mediaUrl': mediaUrl});
      }

      setState(() {
        file = null;
        idDocumento = Uuid().v4();
      });

      if (resultado != null) {
        await alertDialog(
          context: context,
          titulo: "Criado com sucesso",
          conteudo:
              "Agora é só aguardar. Em poucas horas seu pedido será analisado.",
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      print(e);
    } finally {
      _isCarregando = false;
    }
  }

  selectImageAndroid(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text(_kTextoTituloDialog),
          children: <Widget>[
            SimpleDialogOption(
                child: Text(_kTextoImgDaCamera), onPressed: handleTakePhoto),
            SimpleDialogOption(
                child: Text(_kTextoImgDaGaleria),
                onPressed: handleChooseFromGallery),
            SimpleDialogOption(
              child: Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  selectImageiOS(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text('Seleção de documento'),
          message: Text(_kTextoTituloDialog),
          cancelButton: CupertinoActionSheetAction(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text(_kTextoImgDaCamera),
              onPressed: () {
                handleTakePhoto();
              },
            ),
            CupertinoActionSheetAction(
              child: Text(_kTextoImgDaGaleria),
              onPressed: () {
                handleChooseFromGallery();
              },
            ),
          ],
        );
      },
    );
  }

  handleTakePhoto() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("$idDocumento.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

//  handleSubmit() async {
////    setState(() {
//////      isUploading = true;
////    });
////    await compressImage();
//    String mediaUrl = await uploadImage(file);
////    createPostInFirestore(
////      mediaUrl: mediaUrl,
//////      location: locationController.text,
//////      description: captionController.text,
////    );
////    captionController.clear();
////    locationController.clear();
//    setState(() {
//      file = null;
////      isUploading = false;
//      idDocumento = Uuid().v4();
//    });
//  }

//  compressImage() async {
//    final tempDir = await getTemporaryDirectory();
//    final path = tempDir.path;
//    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
//    final compressedImageFile = File('$path/img_$postId.jpg')
//      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
//    setState(() {
//      file = compressedImageFile;
//    });
//  }

}
