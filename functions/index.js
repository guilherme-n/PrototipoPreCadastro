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
        console.log('nomeArquivo: ' + nomeArquivo)
        bucket.file(nomeArquivo).delete();
    })