/**
 * Cloud Functions para CargoClick
 * Envía notificaciones push cuando se crean notificaciones en Firestore
 */

const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onCall} = require("firebase-functions/v2/https");
const {setGlobalOptions} = require("firebase-functions/v2");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();
setGlobalOptions({maxInstances: 10});

// Función que envía notificaciones push cuando se crea una notificación
exports.sendPushNotification = onDocumentCreated(
    "notificaciones/{notifId}",
    async (event) => {
      try {
        const notif = event.data.data();
        const userId = notif.user_id;
        const titulo = notif.titulo;
        const mensaje = notif.mensaje;
        const fleteId = notif.flete_id;

        console.log(`📩 Nueva notificación para ${userId}: ${titulo}`);

        // Buscar usuario en 'users' o 'transportistas'
        const db = getFirestore();
        let userDoc = await db.collection("users").doc(userId).get();

        if (!userDoc.exists) {
          userDoc = await db.collection("transportistas").doc(userId).get();
        }

        if (!userDoc.exists) {
          console.log(`⚠️ Usuario ${userId} no encontrado`);
          return null;
        }

        const userData = userDoc.data();
        const token = userData.fcm_token;

        if (!token) {
          console.log(`⚠️ Usuario ${userId} no tiene token FCM`);
          return null;
        }

        // Enviar notificación push
        const message = {
          notification: {
            title: titulo,
            body: mensaje,
          },
          data: {
            flete_id: fleteId || "",
            tipo: notif.tipo || "",
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
          token: token,
        };

        const response = await getMessaging().send(message);
        console.log(`✅ Notificación enviada: ${response}`);

        return response;
      } catch (error) {
        console.error(`❌ Error enviando notificación: ${error}`);
        return null;
      }
    });

// Función para actualizar token FCM (llamada desde la app)
exports.updateFCMToken = onCall(async (request) => {
  try {
    const {userId, token, collection} = request.data;

    if (!userId || !token || !collection) {
      throw new Error("Faltan parámetros: userId, token, collection");
    }

    const db = getFirestore();
    await db.collection(collection).doc(userId).update({
      fcm_token: token,
      fcm_updated_at: getFirestore.FieldValue.serverTimestamp(),
    });

    console.log(`✅ Token FCM actualizado para ${userId}`);
    return {success: true};
  } catch (error) {
    console.error(`❌ Error actualizando token: ${error}`);
    throw error;
  }
});
//   response.send("Hello from Firebase!");
// });
