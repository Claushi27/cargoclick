/**
 * Configuración de Email para CargoClick
 * 
 * IMPORTANTE: Estos son emails de PRUEBA
 * Cambiar antes de producción
 */

module.exports = {
  // Configuración SMTP (Gmail de prueba)
  smtp: {
    service: 'gmail',
    auth: {
      // ✅ EMAIL CONFIGURADO:
      user: 'cla270308@gmail.com',
      pass: 'aegb kezw zyyv kswf'  // App Password configurado
    }
  },

  // Emails por defecto para testing
  defaults: {
    from: '"CargoClick 🚛" <cla270308@gmail.com>',
    
    // Emails de prueba (todos los emails irán aquí durante testing)
    testEmails: {
      cliente: 'cabreraclaudiov@gmail.com',        // Email que RECIBE todo
      transportista: 'cabreraclaudiov@gmail.com',  // Email que RECIBE todo
      chofer: 'cabreraclaudiov@gmail.com',         // Email que RECIBE todo
      admin: 'cabreraclaudiov@gmail.com'           // Email que RECIBE todo
    }
  },

  // Si está en true, usa emails de prueba en lugar de emails reales
  useTestEmails: true,  // ✅ ACTIVADO - Todos los emails van a cabreraclaudiov@gmail.com

  // Templates de asuntos
  subjects: {
    asignacion: '✅ Flete Asignado - Datos de Transporte',
    completado: '🎉 Flete Completado',
    validacion: '✅ Camión/Chofer Aprobado',
    nuevoFlete: '🚛 Nuevo Flete Publicado'
  }
};
