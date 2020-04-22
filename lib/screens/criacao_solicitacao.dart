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
  Firestore _firestore = Firestore.instance;
  FirebaseUser _firebaseUser;
  Pedido pedido = Pedido();
  final _globalKeyForm = GlobalKey<FormState>();

  final StorageReference storageRef = FirebaseStorage.instance.ref();
  final pedidosRef = Firestore.instance.collection('pedidos');

  bool _isCarregando = false;
  File file;
  String idDocumento = Uuid().v4();

  final mascaraCelular = new MaskTextInputFormatter(
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
                this.pedido.solicitante.nome = value;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Celular'),
              keyboardType: TextInputType.number,
              inputFormatters: [mascaraCelular],
              validator: (value) {
                if (value.isEmpty) {
                  return 'Preencha o celular';
                }
                return null;
              },
              onSaved: (value) {
                this.pedido.solicitante.celular = value;
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
                this.pedido.solicitante.email = value;
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
                this.pedido.tipoPedido = value;
              },
            ),
            SizedBox(
              height: 20.0,
            ),
            BotaoEImagem(textoBotao: 'RG', posicaoArrayImagens: 0),
            SizedBox(height: 20.0),
            BotaoEImagem(textoBotao: 'CPF', posicaoArrayImagens: 1),
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

  Row BotaoEImagem(
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
                if (file == null) {
                  Platform.isIOS
                      ? selectImageiOS(context)
                      : selectImageAndroid(context);
                }
              },
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
            image: file == null
                ? null
                : DecorationImage(
                    image: FileImage(file),
                    fit: BoxFit.fill,
                  ),
          ),
        ),
      ],
    );
  }

  void _submit() async {
    setState(() {
      _isCarregando = true;
    });

    if (!_globalKeyForm.currentState.validate()) {
      return;
    }

    pedido.solicitante = Solicitante();
    _globalKeyForm.currentState.save();
    pedido.dataSolicitacao = DateTime.now();
    pedido.idUsuario = _firebaseUser.uid;

    try {
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
          title: Text(_kTextoTituloDialog),
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
