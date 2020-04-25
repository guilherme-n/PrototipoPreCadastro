const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

//exports.onCreateDocumento = functions.firestore
//    .document("/pedidos/{pedidoId}/documentos/{documentoId}")
//    .onCreate(async (snapshot, context) => {
//
//        const pedidoId = context.params.pedidoId;
//        const documentoId = context.params.documentoId;
//
//        const guiasRef = admin
//                .firestore()
//                .collection('pedidos')
//                .doc(pedidoId)
//                .collection('guias');
//
//        const pedidosRef = admin
//                .firestore()
//                .collection('pedidos')
//                .doc(pedidoId);
//
//        const querySnapshot = await pedidosRef.get();
//        guiasRef.add(querySnapshot.data());
//    })

exports.onDeleteDocumento = functions.firestore
    .document("/pedidos/{pedidoId}/documentos/{documentoId}")
    .onDelete(async (snapshot, context) => {
        const bucket = admin.storage().bucket();
        const nomeArquivo = snapshot.data().nomeArquivo;
        console.log('nomeArquivo: ' + nomeArquivo);
        bucket.file(nomeArquivo).delete();
    })

exports.onCreateGuia = functions.firestore
    .document("/pedidos/{pedidoId}/guias/{guiaId}")
    .onCreate(async (snapshot, context) => {
        const pedidoId = context.params.pedidoId;

        const pedidoDoc = await admin.firestore().collection('pedidos').doc(pedidoId).get();
        const userId = pedidoDoc.data().idUsuario;

        const userRef = admin.firestore().collection('usuarios').doc(userId);
        const usuarioDoc = await userRef.get();

        // 2) pegar o token
        const androidNotificationToken = usuarioDoc.data().androidNotificationToken;
        if(androidNotificationToken){
            sendNotification(androidNotificationToken, snapshot.data());
        } else{
            console.log("Sem token para o usuario, nao eh possivel mandar notificacao");
        }

        function sendNotification(androidNotificationToken, guiaDoc){
            let body = guiaDoc.nomeArquivo;

            const message = {
                notification: { title: 'hi', body: 'corpo' },
                token: androidNotificationToken,
                data: { recipient: userId }
            };

            console.log('message', message);

            // 5) enviar mensagem
            admin.messaging().send(message)
            .then(response => {
                console.log("mensagem enviada com sucesso", response);
            })
            .catch(erro => {
                console.log('Erro ao enviar mensagem: ', erro);
            })

        }
    })