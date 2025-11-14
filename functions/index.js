/**
 * Cloud Functions para CargoClick
 * Envía notificaciones push cuando se crean notificaciones en Firestore
 */

const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onDocumentUpdated} = require("firebase-functions/v2/firestore");
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

// NUEVA: Enviar email cuando se asigna chofer/camión
exports.sendEmailOnAssignment = onDocumentUpdated(
    "fletes/{fleteId}",
    async (event) => {
      try {
        const before = event.data.before.data();
        const after = event.data.after.data();

        // Solo si cambió a estado 'asignado'
        if (before.estado !== "asignado" && after.estado === "asignado") {
          console.log(`📧 Enviando email de asignación para flete ${event.params.fleteId}`);

          const db = getFirestore();

          // Obtener datos del cliente
          const clienteDoc = await db.collection("users").doc(after.cliente_id).get();
          const clienteEmail = clienteDoc.data().email;

          // Obtener datos del chofer
          const choferDoc = await db.collection("users").doc(after.chofer_asignado).get();
          const choferData = choferDoc.data();

          // Obtener datos del camión
          const camionDoc = await db.collection("camiones").doc(after.camion_asignado).get();
          const camionData = camionDoc.data();

          // Aquí agregarías el servicio de email (SendGrid, Nodemailer, etc.)
          // Por ahora solo log
          console.log(`📧 Email a enviar a: ${clienteEmail}`);
          console.log(`   Chofer: ${choferData.display_name}`);
          console.log(`   Camión: ${camionData.patente}`);
          console.log(`   Flete: ${after.numero_contenedor}`);

          // TODO: Implementar envío real de email
          // await sendEmail({
          //   to: clienteEmail,
          //   subject: 'Flete Asignado - Datos de Transporte',
          //   html: templateEmailAsignacion(after, choferData, camionData)
          // });
        }

        return null;
      } catch (error) {
        console.error(`❌ Error enviando email: ${error}`);
        return null;
      }
    });

// NUEVA: Enviar email cuando se aprueba camión/chofer
exports.sendEmailOnValidation = onDocumentUpdated(
    "camiones/{camionId}",
    async (event) => {
      try {
        const before = event.data.before.data();
        const after = event.data.after.data();

        // Solo si cambió a validado
        if (!before.is_validado_cliente && after.is_validado_cliente) {
          console.log(`📧 Camión validado: ${event.params.camionId}`);

          const db = getFirestore();

          // Obtener datos del transportista
          const transportistaDoc = await db.collection("transportistas")
              .doc(after.transportista_id).get();
          const transportistaEmail = transportistaDoc.data().email;

          console.log(`📧 Email a enviar a transportista: ${transportistaEmail}`);
          console.log(`   Camión aprobado: ${after.patente}`);

          // TODO: Implementar envío real
          // await sendEmail({
          //   to: transportistaEmail,
          //   subject: '✅ Camión Aprobado',
          //   html: templateCamionAprobado(after)
          // });
        }

        return null;
      } catch (error) {
        console.error(`❌ Error: ${error}`);
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
