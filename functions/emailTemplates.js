/**
 * Templates HTML para Emails de CargoClick
 */

const emailStyles = `
  <style>
    body { font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 0; }
    .container { max-width: 600px; margin: 20px auto; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
    .header { background: linear-gradient(135deg, #2196F3 0%, #1976D2 100%); color: white; padding: 30px 20px; text-align: center; }
    .header h1 { margin: 0; font-size: 28px; }
    .content { padding: 30px 20px; }
    .info-box { background: #f9f9f9; border-left: 4px solid #2196F3; padding: 15px; margin: 20px 0; border-radius: 5px; }
    .info-row { margin: 10px 0; }
    .label { font-weight: bold; color: #555; }
    .value { color: #333; }
    .button { display: inline-block; background: #2196F3; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; margin: 20px 0; }
    .footer { background: #f4f4f4; padding: 20px; text-align: center; color: #666; font-size: 12px; }
    .alert { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; }
    .success { background: #d4edda; border-left: 4px solid #28a745; padding: 15px; margin: 20px 0; }
  </style>
`;

// Template 1: Email de Asignación (Cliente)
function templateAsignacion(fleteData, choferData, camionData) {
  return `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      ${emailStyles}
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>🚛 Flete Asignado</h1>
          <p>Datos del Transporte</p>
        </div>
        
        <div class="content">
          <p>Estimado Cliente,</p>
          <p>Su flete <strong>${fleteData.numero_contenedor}</strong> ha sido asignado exitosamente.</p>
          
          <div class="success">
            ✅ <strong>Estado:</strong> Flete Asignado
          </div>

          <h3>📦 Detalles del Flete</h3>
          <div class="info-box">
            <div class="info-row">
              <span class="label">Contenedor:</span>
              <span class="value">${fleteData.numero_contenedor}</span>
            </div>
            <div class="info-row">
              <span class="label">Tipo:</span>
              <span class="value">${fleteData.tipo_contenedor}</span>
            </div>
            <div class="info-row">
              <span class="label">Origen:</span>
              <span class="value">${fleteData.origen}</span>
            </div>
            <div class="info-row">
              <span class="label">Destino:</span>
              <span class="value">${fleteData.destino}</span>
            </div>
            <div class="info-row">
              <span class="label">Peso:</span>
              <span class="value">${fleteData.peso} kg</span>
            </div>
          </div>

          <h3>👨‍✈️ Datos del Chofer</h3>
          <div class="info-box">
            <div class="info-row">
              <span class="label">Nombre:</span>
              <span class="value">${choferData.display_name}</span>
            </div>
            <div class="info-row">
              <span class="label">Teléfono:</span>
              <span class="value">${choferData.phone_number || 'No disponible'}</span>
            </div>
            <div class="info-row">
              <span class="label">Email:</span>
              <span class="value">${choferData.email}</span>
            </div>
          </div>

          <h3>🚚 Datos del Camión</h3>
          <div class="info-box">
            <div class="info-row">
              <span class="label">Patente:</span>
              <span class="value"><strong>${camionData.patente}</strong></span>
            </div>
            <div class="info-row">
              <span class="label">Tipo:</span>
              <span class="value">${camionData.tipo}</span>
            </div>
            <div class="info-row">
              <span class="label">Capacidad:</span>
              <span class="value">${camionData.capacidad_carga} kg</span>
            </div>
            <div class="info-row">
              <span class="label">Seguro:</span>
              <span class="value">${camionData.seguro_carga}</span>
            </div>
          </div>

          <div class="alert">
            ⚠️ <strong>Nota:</strong> El chofer se pondrá en contacto con usted para coordinar la carga.
          </div>

          <center>
            <a href="https://cargoclick.web.app" class="button">Ver Detalles en la App</a>
          </center>
        </div>
        
        <div class="footer">
          <p>CargoClick - Sistema de Gestión de Fletes</p>
          <p>Este es un email automático, por favor no responder.</p>
        </div>
      </div>
    </body>
    </html>
  `;
}

// Template 2: Email de Validación de Camión (Transportista)
function templateValidacion(camionData) {
  return `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      ${emailStyles}
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>✅ Camión Aprobado</h1>
          <p>Validación Completada</p>
        </div>
        
        <div class="content">
          <p>Estimado Transportista,</p>
          <p>Su camión ha sido <strong>aprobado exitosamente</strong> por el cliente.</p>
          
          <div class="success">
            ✅ <strong>Estado:</strong> Camión Validado
          </div>

          <h3>🚚 Detalles del Camión Aprobado</h3>
          <div class="info-box">
            <div class="info-row">
              <span class="label">Patente:</span>
              <span class="value"><strong>${camionData.patente}</strong></span>
            </div>
            <div class="info-row">
              <span class="label">Tipo:</span>
              <span class="value">${camionData.tipo}</span>
            </div>
            <div class="info-row">
              <span class="label">Capacidad:</span>
              <span class="value">${camionData.capacidad_carga} kg</span>
            </div>
            <div class="info-row">
              <span class="label">Seguro:</span>
              <span class="value">${camionData.seguro_carga}</span>
            </div>
          </div>

          <div class="alert">
            📋 <strong>Próximos pasos:</strong>
            <ul>
              <li>Puede comenzar a operar con este camión</li>
              <li>Asegúrese de mantener la documentación actualizada</li>
              <li>Revise los fletes disponibles en la plataforma</li>
            </ul>
          </div>

          <center>
            <a href="https://cargoclick.web.app" class="button">Ir a la Plataforma</a>
          </center>
        </div>
        
        <div class="footer">
          <p>CargoClick - Sistema de Gestión de Fletes</p>
          <p>Este es un email automático, por favor no responder.</p>
        </div>
      </div>
    </body>
    </html>
  `;
}

// Template 3: Email de Flete Completado (Cliente y Transportista)
function templateCompletado(fleteData, destinatario = 'cliente') {
  const titulo = destinatario === 'cliente' 
    ? 'Flete Completado - Hoja de Cobro'
    : 'Flete Completado - Servicio Finalizado';

  return `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      ${emailStyles}
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>🎉 ${titulo}</h1>
          <p>Servicio Finalizado</p>
        </div>
        
        <div class="content">
          <p>${destinatario === 'cliente' ? 'Estimado Cliente' : 'Estimado Transportista'},</p>
          <p>El flete <strong>${fleteData.numero_contenedor}</strong> ha sido <strong>completado exitosamente</strong>.</p>
          
          <div class="success">
            ✅ <strong>Estado:</strong> Flete Completado
          </div>

          <h3>📦 Resumen del Flete</h3>
          <div class="info-box">
            <div class="info-row">
              <span class="label">Contenedor:</span>
              <span class="value">${fleteData.numero_contenedor}</span>
            </div>
            <div class="info-row">
              <span class="label">Ruta:</span>
              <span class="value">${fleteData.origen} → ${fleteData.destino}</span>
            </div>
            <div class="info-row">
              <span class="label">Peso:</span>
              <span class="value">${fleteData.peso} kg</span>
            </div>
            ${destinatario === 'cliente' ? `
            <div class="info-row">
              <span class="label">Tarifa Total:</span>
              <span class="value"><strong>$${fleteData.tarifa.toLocaleString('es-CL')}</strong></span>
            </div>
            ` : ''}
          </div>

          ${destinatario === 'cliente' ? `
          <div class="alert">
            💰 <strong>Facturación:</strong><br>
            Puede revisar la Hoja de Detalle de Cobro completa en la aplicación con el desglose de todos los conceptos e IVA incluido.
          </div>
          ` : `
          <div class="success">
            ✅ <strong>Servicio Finalizado:</strong><br>
            El servicio ha sido completado satisfactoriamente. El cliente procederá con el pago según lo acordado.
          </div>
          `}

          <center>
            <a href="https://cargoclick.web.app" class="button">Ver Detalles Completos</a>
          </center>
        </div>
        
        <div class="footer">
          <p>CargoClick - Sistema de Gestión de Fletes</p>
          <p>Este es un email automático, por favor no responder.</p>
        </div>
      </div>
    </body>
    </html>
  `;
}

module.exports = {
  templateAsignacion,
  templateValidacion,
  templateCompletado
};
