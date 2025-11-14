# 📋 MÓDULOS 3 Y 4 - PLAN DE IMPLEMENTACIÓN

**Fecha:** 30 Enero 2025  
**Estado:** 📝 PLANIFICACIÓN

---

## 🎯 MÓDULO 3: Automatización de Correo Electrónico (Aduana)

### Objetivo:
Actualizar Cloud Functions para enviar correos electrónicos con información completa de aduana cuando se validan transportistas y cuando se asignan fletes.

---

### 3.1 Correo al Validar Transportista ✅ (Ya existe parcialmente)

**Trigger:** Cuando `is_validado_cliente` cambia a `true` en collection `transportistas`

**Destinatarios:**
- Email del transportista validado

**Contenido del correo:**
```
Asunto: ✅ Tu cuenta de Transportista ha sido validada

Hola [Razón Social],

¡Buenas noticias! Tu cuenta de transportista ha sido validada por el cliente.

Ahora puedes:
- Aceptar fletes publicados
- Asignar tus choferes y camiones validados
- Comenzar a operar en la plataforma

Datos de tu cuenta:
- RUT: [RUT]
- Razón Social: [Razón Social]
- Código Invitación: [Código]

Para más información, ingresa a la plataforma.

Saludos,
Equipo CargoClick
```

**Implementación:**
- Archivo: `functions/src/index.ts` (o crear nuevo)
- Trigger: `onUpdate` en `transportistas/{transportistaId}`
- Condición: `before.is_validado_cliente === false && after.is_validado_cliente === true`

---

### 3.2 Correo de Asignación a Aduana ⚠️ (CRÍTICO)

**Trigger:** Cuando `estado` cambia a `asignado` en collection `fletes`

**Destinatarios (2 opciones):**

**Opción A - Solo Cliente:**
- Email del cliente (para que él reenvíe)

**Opción B - 3 Correos Predefinidos:**
- Email del cliente
- Email Aduana 1 (configurado en perfil cliente)
- Email Aduana 2 (configurado en perfil cliente)

**IMPORTANTE:** El cliente debe poder configurar esto en su perfil.

**Contenido del correo:**
```
Asunto: 🚛 Flete Asignado - Datos para Ingreso a Puerto

INFORMACIÓN DEL FLETE:
- Número Contenedor: [Número]
- Tipo: [Tipo CTN]
- Peso Total: [Peso] kg
- Puerto Origen: [Puerto]
- Destino: [Destino]

DATOS DEL CHOFER:
- Nombre: [Nombre Completo]
- RUT: [RUT]
- Celular: [Teléfono]

DATOS DEL CAMIÓN:
- Patente Camión: [Patente]
- Patente Rampla: [Patente Rampla] (si existe)
- Tipo: [Tipo]

DATOS DE INGRESO A PUERTOS:
- RUT Ingreso STI: [RUT STI]
- RUT Ingreso PC: [RUT PC]

INFORMACIÓN ADICIONAL:
- Tipo de Rampla: [Tipo]
- Requisitos Especiales: [Requisitos]

Fecha Asignación: [Fecha]
```

**Implementación:**
- Archivo: `functions/src/index.ts`
- Trigger: `onUpdate` en `fletes/{fleteId}`
- Condición: `before.estado !== 'asignado' && after.estado === 'asignado'`
- Obtener datos de:
  - Flete (`fletes/{fleteId}`)
  - Chofer (`users/{chofer_asignado}`)
  - Camión (`camiones/{camion_asignado}`)
  - Cliente (`users/{cliente_id}`)

---

### 3.3 Configuración de Emails en Perfil Cliente

**Modelo Cliente actualizado:**

```typescript
interface Cliente {
  // ... campos existentes ...
  
  // MÓDULO 3: Configuración de emails
  emails_aduana?: {
    enviar_a_cliente_solo: boolean;  // true = solo cliente, false = 3 emails
    email_aduana_1?: string;
    email_aduana_2?: string;
  }
}
```

**UI necesaria:**
- Página de configuración del cliente
- Toggle: "Enviar emails de asignación"
  - Opción 1: "Solo a mí (yo reenvío)"
  - Opción 2: "A mí y a aduanas"
    - Campo: Email Aduana 1
    - Campo: Email Aduana 2

---

## 🎯 MÓDULO 4: Experiencia Chofer y Detalle de Cobro

### Objetivo:
Mejorar la vista del chofer con información clave y crear una vista de detalle de cobro con desglose tarifario.

---

### 4.1 Vista Chofer - Horarios y Retiro

**Archivo:** `lib/screens/mis_recorridos_page.dart` (chofer)

**Información destacada a mostrar:**
```
Card de Flete:
┌─────────────────────────────────┐
│ 🚛 [Número Contenedor]          │
│                                 │
│ ⏰ HORARIOS IMPORTANTES:        │
│  • Retiro: [Hora] hs            │
│  • Puerto: [Puerto Origen]      │
│  • Recepción: [Fecha/Hora]      │
│                                 │
│ 📍 Destino: [Destino]           │
│ ⚖️ Peso: [Peso] kg              │
│                                 │
│ [Ver Detalles] [Iniciar]       │
└─────────────────────────────────┘
```

**Campos a destacar:**
- `fechaHoraCarga` → Hora de Retiro
- `puertoOrigen` → Puerto de Retiro
- `fechaHoraCarga` (fecha) → Fecha de Recepción
- `destino` → Destino final

**Diseño:**
- Iconos grandes para horarios
- Colores diferenciados
- Badges de urgencia si está próximo

---

### 4.2 Hoja de Detalle de Cobro (Flete Terminado)

**Nueva Vista:** `lib/screens/detalle_cobro_page.dart`

**Trigger:** Se accede cuando el flete está en estado `completado`

**Estructura:**

```
┌─────────────────────────────────────┐
│     DETALLE DE COBRO FINAL          │
└─────────────────────────────────────┘

FLETE: [Número Contenedor]
Fecha Completado: [Fecha]

┌─────────────────────────────────────┐
│ DESGLOSE DE TARIFA                  │
├─────────────────────────────────────┤
│ Tarifa Base               $150,000  │
│                                     │
│ Adicionales:                        │
│ + Perímetro               $ 30,000  │
│ + Sobrepeso               $ 50,000  │
├─────────────────────────────────────┤
│ TOTAL A COBRAR           $230,000  │
└─────────────────────────────────────┘

[Exportar PDF] [Compartir] [Cerrar]
```

**Cálculo:**
```dart
double calcularTotalFlete(Flete flete) {
  double total = flete.tarifa;
  
  if (flete.valorAdicionalPerimetro != null) {
    total += flete.valorAdicionalPerimetro!;
  }
  
  if (flete.valorAdicionalSobrepeso != null) {
    total += flete.valorAdicionalSobrepeso!;
  }
  
  return total;
}
```

**Mostrar:**
- Tarifa base
- Cada adicional (si existe)
- Línea divisoria
- Total en grande y destacado

---

### 4.3 GPS (Revisión de Solución)

**Ya implementado en FASE 3.5**, solo necesita verificación:

**Funcionalidad actual:**
- 5 Checkpoints obligatorios
- Captura de GPS en cada uno
- Subida de fotos

**Revisar:**
1. ✅ GPS es obligatorio en cada checkpoint
2. ✅ Si GPS falla:
   - Mostrar alert al usuario
   - Permitir continuar (no bloquear)
   - Guardar ubicación como "no disponible"
   - Registrar en logs

**Implementación sugerida:**
```dart
Future<void> capturarCheckpoint() async {
  try {
    Position? position = await _obtenerUbicacion(timeout: 10);
    
    if (position == null) {
      // Mostrar diálogo
      bool continuar = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('⚠️ GPS No Disponible'),
          content: Text(
            'No se pudo obtener la ubicación GPS.\n\n'
            '¿Deseas continuar sin ubicación?\n'
            '(Se registrará como "Ubicación no disponible")'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Reintentar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Continuar sin GPS'),
            ),
          ],
        ),
      );
      
      if (!continuar) return;
    }
    
    // Continuar con checkpoint (con o sin GPS)
    await _guardarCheckpoint(position);
    
  } catch (e) {
    // Manejo de error
  }
}
```

---

## 📋 ORDEN DE IMPLEMENTACIÓN SUGERIDO

### Prioridad ALTA (Crítico para operación):
1. ✅ **MÓDULO 3.2 - Correo Asignación Aduana** (1-2 horas)
   - Cloud Function
   - Trigger en asignación
   - Template de email

2. ✅ **MÓDULO 4.1 - Vista Chofer Mejorada** (1 hora)
   - Destacar horarios
   - Rediseño de cards

### Prioridad MEDIA:
3. ✅ **MÓDULO 3.3 - Config Emails Cliente** (1 hora)
   - Modelo actualizado
   - UI configuración
   - Integración con Cloud Function

4. ✅ **MÓDULO 4.2 - Detalle de Cobro** (2 horas)
   - Nueva vista
   - Cálculo de total
   - UI del desglose

### Prioridad BAJA:
5. ✅ **MÓDULO 3.1 - Correo Validación** (30 min)
   - Ya existe parcialmente
   - Solo agregar trigger

6. ✅ **MÓDULO 4.3 - Revisión GPS** (30 min)
   - Verificar implementación actual
   - Ajustes menores si es necesario

---

## ⚠️ CONSIDERACIONES TÉCNICAS

### Cloud Functions:
- Usar Firebase Cloud Functions v2
- Configurar SMTP (SendGrid, Mailgun, etc.)
- Templates de email con HTML
- Error handling robusto

### Seguridad:
- Emails de aduana solo accesibles por cliente
- Validar permisos en Cloud Function
- No exponer datos sensibles en emails

### Testing:
- Probar envío de emails en desarrollo
- Verificar triggers funcionan
- Validar formato de emails
- Testear con diferentes escenarios

---

## 🚀 SIGUIENTE ACCIÓN

**COMENZAR CON MÓDULO 3.2 - Correo Asignación Aduana**

Este es el más crítico porque:
- Requerido para operación con aduanas
- Bloquea flujo de despacho
- Alta prioridad del cliente

---

**Tiempo total estimado:** 6-8 horas  
**Complejidad:** Media-Alta (requiere Cloud Functions)

🎯 ¿Listo para empezar con MÓDULO 3?
