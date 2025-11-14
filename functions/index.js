/**
 * Cloud Functions para CargoClick
 * Envía notificaciones push y emails cuando ocurren eventos importantes
 */

const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onDocumentUpdated} = require("firebase-functions/v2/firestore");
const {onCall} = require("firebase-functions/v2/https");
const {setGlobalOptions} = require("firebase-functions/v2");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const nodemailer = require("nodemailer");
const emailConfig = require("./emailConfig");
const {templateAsignacion, templateValidacion, templateCompletado, templateCambioAsignacion} = require("./emailTemplates");

initializeApp();
setGlobalOptions({maxInstances: 10});

// Configurar transportador de email
const transporter = nodemailer.createTransport(emailConfig.smtp);

// Función helper para enviar emails
async function sendEmail(to, subject, html) {
  try {
    // Si está en modo test, usa email de prueba
    const finalTo = emailConfig.useTestEmails 
      ? emailConfig.defaults.testEmails.cliente 
      : to;

    const info = await transporter.sendMail({
      from: emailConfig.defaults.from,
      to: finalTo,
      subject: subject,
      html: html
    });

    console.log(`✅ Email enviado: ${info.messageId}`);
    console.log(`   To: ${finalTo} (original: ${to})`);
    return info;
  } catch (error) {
    console.error(`❌ Error enviando email: ${error}`);
    throw error;
  }
}


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

// Enviar email cuando se asigna chofer/camión
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

          console.log(`📧 Preparando email para: ${clienteEmail}`);
          console.log(`   Chofer: ${choferData.display_name}`);
          console.log(`   Camión: ${camionData.patente}`);
          console.log(`   Flete: ${after.numero_contenedor}`);

          // Enviar email al cliente con datos del transporte
          const htmlContent = templateAsignacion(after, choferData, camionData);
          await sendEmail(
            clienteEmail,
            emailConfig.subjects.asignacion,
            htmlContent
          );

          console.log(`✅ Email de asignación enviado exitosamente`);
        }

        return null;
      } catch (error) {
        console.error(`❌ Error enviando email de asignación: ${error}`);
        return null;
      }
    });

// Enviar email cuando se aprueba camión/chofer
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

          console.log(`📧 Preparando email para transportista: ${transportistaEmail}`);
          console.log(`   Camión aprobado: ${after.patente}`);

          // Enviar email al transportista
          const htmlContent = templateValidacion(after);
          await sendEmail(
            transportistaEmail,
            emailConfig.subjects.validacion,
            htmlContent
          );

          console.log(`✅ Email de validación enviado exitosamente`);
        }

        return null;
      } catch (error) {
        console.error(`❌ Error enviando email de validación: ${error}`);
        return null;
      }
    });

// Enviar email cuando se completa el flete
exports.sendEmailOnCompletion = onDocumentUpdated(
    "fletes/{fleteId}",
    async (event) => {
      try {
        const before = event.data.before.data();
        const after = event.data.after.data();

        // Solo si cambió a estado 'completado'
        if (before.estado !== "completado" && after.estado === "completado") {
          console.log(`📧 Enviando emails de completado para flete ${event.params.fleteId}`);

          const db = getFirestore();

          // Obtener datos del cliente
          const clienteDoc = await db.collection("users").doc(after.cliente_id).get();
          const clienteEmail = clienteDoc.data().email;

          // Obtener datos del transportista
          let transportistaEmail = null;
          if (after.transportista_id) {
            const transportistaDoc = await db.collection("transportistas")
                .doc(after.transportista_id).get();
            transportistaEmail = transportistaDoc.data().email;
          }

          console.log(`📧 Flete completado: ${after.numero_contenedor}`);
          console.log(`   Cliente: ${clienteEmail}`);
          console.log(`   Transportista: ${transportistaEmail}`);

          // Email al cliente (con info de facturación)
          const htmlCliente = templateCompletado(after, 'cliente');
          await sendEmail(
            clienteEmail,
            emailConfig.subjects.completado,
            htmlCliente
          );

          // Email al transportista (confirmación de servicio)
          if (transportistaEmail) {
            const htmlTransportista = templateCompletado(after, 'transportista');
            await sendEmail(
              transportistaEmail,
              emailConfig.subjects.completado,
              htmlTransportista
            );
          }

          console.log(`✅ Emails de completado enviados exitosamente`);
        }

        return null;
      } catch (error) {
        console.error(`❌ Error enviando emails de completado: ${error}`);
        return null;
      }
    });

// Enviar email cuando hay un cambio de asignación
exports.sendEmailOnCambioAsignacion = onDocumentCreated(
    "cambios_asignacion/{cambioId}",
    async (event) => {
      try {
        const cambioData = event.data.data();
        const fleteId = cambioData.flete_id;

        console.log(`📧 Enviando email de cambio de asignación para flete ${fleteId}`);

        const db = getFirestore();

        // Obtener datos del flete
        const fleteDoc = await db.collection("fletes").doc(fleteId).get();
        const fleteData = fleteDoc.data();

        // Obtener email del cliente
        const clienteDoc = await db.collection("users").doc(fleteData.cliente_id).get();
        const clienteEmail = clienteDoc.data().email;

        console.log(`📧 Preparando email para cliente: ${clienteEmail}`);
        console.log(`   Cambio: ${cambioData.chofer_anterior_nombre} → ${cambioData.chofer_nuevo_nombre}`);
        console.log(`   Razón: ${cambioData.razon}`);

        // Enviar email al cliente
        const htmlContent = templateCambioAsignacion(cambioData, fleteData);
        await sendEmail(
          clienteEmail,
          "🔄 Cambio de Chofer/Camión - Tiene 24h para Revisar",
          htmlContent
        );

        console.log(`✅ Email de cambio de asignación enviado exitosamente`);

        return null;
      } catch (error) {
        console.error(`❌ Error enviando email de cambio: ${error}`);
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
