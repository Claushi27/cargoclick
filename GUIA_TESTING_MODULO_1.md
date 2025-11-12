# 🧪 GUÍA DE TESTING - MÓDULO 1: Sistema de Validación

**Fecha:** 30 Enero 2025  
**Módulo:** Sistema de Validación de Flota  
**Tiempo estimado:** 30-40 minutos

---

## 📋 PRE-REQUISITOS

Antes de empezar, asegúrate de tener:
- ✅ Código compilado sin errores
- ✅ Firebase Hosting deployado con últimos cambios
- ✅ Reglas de Firestore actualizadas
- ✅ 3 cuentas de prueba:
  - **Cliente:** `cliente@test.com`
  - **Transportista:** `transportista@test.com`
  - **Chofer:** `chofer@test.com`

---

## 🔄 FLUJO COMPLETO A TESTEAR

### **Escenario:** Cliente valida flota y transportista asigna flete

```
1. Transportista registra camión con póliza
2. Cliente valida camión y chofer
3. Cliente publica flete
4. Transportista acepta flete
5. Transportista asigna chofer y camión validados
```

---

## ✅ TEST 1: Agregar Camión con Póliza de Seguro (5 min)

### Objetivo:
Verificar que el transportista puede agregar un camión con los 3 campos nuevos de póliza.

### Pasos:

1. **Login como Transportista**
   ```
   Email: transportista@test.com
   Password: [tu password]
   ```

2. **Ir a Gestión de Flota**
   - Click en botón "Gestión de Flota" desde el home
   - Tab "Camiones"

3. **Agregar Nuevo Camión**
   - Click en botón flotante "+" (Agregar Camión)
   - Llenar formulario:
     ```
     Patente: ABCD12
     Tipo: CTN Std 40
     Monto Seguro: 50000
     
     --- Información de Póliza ---
     Número de Póliza: POL-2025-12345
     Compañía de Seguro: Chilena Consolidada
     Nombre del Seguro: Seguro Todo Riesgo Carga
     
     Fecha Vencimiento: [Fecha futura, ej: 31/12/2025]
     ```
   - Click "Guardar"

4. **Verificar**
   - ✅ El camión aparece en la lista
   - ✅ Se muestra patente ABCD12
   - ✅ Tipo CTN Std 40 visible
   - ✅ Semáforo verde (doc OK)
   - ✅ NO hay error en consola

5. **Verificar en Firestore Console** (Opcional)
   ```
   Firebase Console → Firestore → Collection: camiones
   Buscar documento recién creado
   Verificar campos:
   - numero_poliza: "POL-2025-12345"
   - compania_seguro: "Chilena Consolidada"
   - nombre_seguro: "Seguro Todo Riesgo Carga"
   - is_validado_cliente: false
   ```

**✅ Resultado Esperado:** Camión creado con toda la información de póliza

---

## ✅ TEST 2: Dashboard de Validación - Cliente (10 min)

### Objetivo:
Verificar que el cliente puede ver y validar transportistas, choferes y camiones.

### Pasos:

1. **Login como Cliente**
   ```
   Email: cliente@test.com
   Password: [tu password]
   ```

2. **Abrir Dashboard de Validación**
   - En el AppBar, buscar ícono de escudo/usuario (🛡️ Icons.verified_user)
   - Click en "Validar Flota"

3. **Verificar Vista General**
   - ✅ Se abre pantalla con 3 tabs
   - ✅ Tabs visibles: "Transportistas", "Choferes", "Camiones"
   - ✅ Barra de búsqueda presente
   - ✅ Toggle "Pendientes/Validados" en AppBar

4. **Tab TRANSPORTISTAS**
   - ✅ Ver lista de transportistas pendientes
   - ✅ Buscar por RUT o nombre en barra de búsqueda
   - ✅ Ver card con información completa:
     - Razón Social
     - RUT
     - Teléfono
     - Email
     - Código Invitación
     - Badge naranja "PENDIENTE"
   - Click "Aprobar" en un transportista
   - ✅ Aparece confirmación: "¿Está seguro de validar...?"
   - Click "Validar"
   - ✅ SnackBar verde: "✅ Transportista validado correctamente"
   - ✅ Card desaparece de vista pendientes
   - Toggle "Ver Validados"
   - ✅ Ahora aparece con badge verde "VALIDADO"
   - ✅ Muestra fecha de validación

5. **Tab CHOFERES**
   - Click tab "Choferes"
   - ✅ Ver lista de choferes pendientes
   - ✅ Card muestra:
     - Nombre completo
     - Email
     - Teléfono
     - Badge naranja "PENDIENTE"
   - Buscar chofer específico
   - Click "Aprobar"
   - ✅ Confirmación y validación exitosa
   - ✅ Badge cambia a verde "VALIDADO"

6. **Tab CAMIONES**
   - Click tab "Camiones"
   - ✅ Ver lista de camiones pendientes
   - ✅ Card muestra:
     - Patente (ej: ABCD12)
     - Tipo (CTN Std 40)
     - Semáforo de documentación (verde/naranja/rojo)
     - **INFORMACIÓN DE SEGURO** (nuevo):
       - Póliza: POL-2025-12345
       - Compañía: Chilena Consolidada
       - Seguro: Seguro Todo Riesgo Carga
     - Badge naranja "PENDIENTE"
   - Click "Aprobar" en el camión ABCD12
   - ✅ Confirmación exitosa
   - ✅ Badge verde "VALIDADO"
   - ✅ Muestra fecha de validación

7. **Verificar Estados Vacíos**
   - Toggle a "Ver Validados"
   - Si todos están validados:
     - ✅ Mensaje: "No hay [entidades] pendientes"
     - ✅ Ícono y texto centrados

**✅ Resultado Esperado:** Cliente puede validar todas las entidades y ver información completa

---

## ✅ TEST 3: Asignación SOLO con Validados (CRÍTICO - 10 min)

### Objetivo:
Verificar que el transportista SOLO puede asignar choferes y camiones validados.

### Parte A: SIN Validación (Debe fallar)

1. **Login como Transportista**
   ```
   Email: transportista@test.com
   ```

2. **Crear Chofer Nuevo NO Validado**
   - Registrar un nuevo chofer con código del transportista
   - Este chofer NO será validado aún

3. **Ir a Fletes Disponibles**
   - Ver un flete publicado por el cliente

4. **Intentar Asignar**
   - Click "Aceptar y Asignar"
   
5. **Verificar Restricción CHOFERES**
   - ✅ Banner azul visible: "Solo se muestran choferes validados por el cliente"
   - ✅ Si NO hay choferes validados:
     - Mensaje naranja: "No tienes choferes validados. El cliente debe aprobar..."
     - NO aparece ningún chofer en la lista
   - ✅ Si hay validados:
     - SOLO aparecen choferes con badge verde "VALIDADO"
     - Choferes no validados NO aparecen

6. **Verificar Restricción CAMIONES**
   - ✅ Banner azul visible: "Solo se muestran camiones validados por el cliente"
   - ✅ Si NO hay camiones validados:
     - Mensaje naranja: "No tienes camiones validados. El cliente debe aprobar..."
   - ✅ Si hay validados:
     - SOLO aparecen camiones con badge verde "VALIDADO"
     - Camiones no validados NO aparecen

**✅ Resultado Esperado:** NO puede asignar si no tiene entidades validadas

---

### Parte B: CON Validación (Debe funcionar)

1. **Cliente Valida Chofer y Camión**
   - Login como cliente
   - Ir a "Validar Flota"
   - Aprobar 1 chofer y 1 camión

2. **Transportista Refresca Vista**
   - Volver a "Aceptar y Asignar" del flete
   - Refrescar página si es necesario (F5)

3. **Verificar Choferes Validados**
   - ✅ Ahora aparece el chofer validado
   - ✅ Badge verde "VALIDADO" visible
   - ✅ Ícono de check verde en avatar
   - ✅ Puede seleccionarlo (highlight azul)

4. **Verificar Camiones Validados**
   - ✅ Aparece el camión validado
   - ✅ Badge verde "VALIDADO" visible
   - ✅ Ícono de check verde en avatar
   - ✅ Semáforo de documentación presente
   - ✅ Puede seleccionarlo

5. **Asignar Flete**
   - Seleccionar chofer validado
   - Seleccionar camión validado
   - Click "Asignar Flete"
   - ✅ SnackBar: "Flete asignado correctamente"
   - ✅ Navegación exitosa

**✅ Resultado Esperado:** Puede asignar SOLO con validados

---

## ✅ TEST 4: Búsqueda y Filtros (5 min)

### Objetivo:
Verificar funcionalidad de búsqueda y filtros en Dashboard.

### Pasos:

1. **Login como Cliente**
   - Ir a "Validar Flota"

2. **Búsqueda en Transportistas**
   - Escribir RUT parcial (ej: "12345")
   - ✅ Filtra en tiempo real
   - ✅ Solo muestra coincidencias
   - Borrar búsqueda
   - ✅ Vuelven a aparecer todos

3. **Búsqueda en Choferes**
   - Tab "Choferes"
   - Escribir nombre (ej: "Juan")
   - ✅ Filtra correctamente
   - ✅ Mensaje "No se encontraron resultados" si no hay

4. **Búsqueda en Camiones**
   - Tab "Camiones"
   - Escribir patente (ej: "ABCD")
   - ✅ Filtra por patente
   - Escribir tipo (ej: "Std 40")
   - ✅ Filtra por tipo

5. **Toggle Pendientes/Validados**
   - Estado: Pendientes activo
   - ✅ Banner naranja: "Mostrando solo pendientes"
   - Toggle a Validados
   - ✅ Banner verde: "Mostrando entidades validadas"
   - ✅ Lista cambia a validados
   - Toggle de vuelta
   - ✅ Vuelve a pendientes

**✅ Resultado Esperado:** Búsqueda y filtros funcionan correctamente

---

## ✅ TEST 5: Revocar Validación (5 min)

### Objetivo:
Verificar que el cliente puede revocar validaciones.

### Pasos:

1. **Login como Cliente**
   - Ir a "Validar Flota"

2. **Ver Validados**
   - Toggle a "Ver Validados"
   - Tab "Camiones"
   - Ver camión con badge verde "VALIDADO"

3. **Revocar Validación**
   - Click botón "Revocar" (rojo)
   - ✅ Aparece confirmación: "¿Está seguro de revocar...?"
   - ✅ Mensaje: "No podrá ser asignado a fletes."
   - Click "Revocar"
   - ✅ SnackBar naranja: "Validación revocada"
   - ✅ Camión desaparece de validados
   - Toggle a "Pendientes"
   - ✅ Ahora aparece con badge naranja "PENDIENTE"

4. **Verificar Efecto en Asignación**
   - Login como transportista
   - Ir a asignar flete
   - ✅ El camión revocado YA NO aparece en la lista

**✅ Resultado Esperado:** Revocación funciona y afecta asignación

---

## ✅ TEST 6: Validación de Formulario Camión (3 min)

### Objetivo:
Verificar validaciones de campos requeridos.

### Pasos:

1. **Login como Transportista**
   - Ir a "Gestión de Flota"
   - Click "+" Agregar Camión

2. **Intentar Guardar SIN Datos**
   - No llenar nada
   - Click "Guardar"
   - ✅ Errores visibles:
     - "Ingresa la patente"
     - "Ingresa el monto"
     - "Ingresa el número de póliza"
     - "Ingresa la compañía"
     - "Ingresa el nombre del seguro"
     - "Selecciona la fecha de vencimiento"

3. **Llenar Solo Campos Básicos**
   - Llenar patente, tipo, monto, fecha
   - Dejar vacíos los 3 campos de póliza
   - Click "Guardar"
   - ✅ Errores en campos de póliza:
     - "Ingresa el número de póliza"
     - "Ingresa la compañía"
     - "Ingresa el nombre del seguro"

4. **Llenar Todos los Campos**
   - Completar TODOS los campos
   - Click "Guardar"
   - ✅ Se guarda exitosamente
   - ✅ SnackBar: "Camión agregado exitosamente"

**✅ Resultado Esperado:** Validaciones funcionan correctamente

---

## 📊 CHECKLIST DE TESTING COMPLETO

### Funcionalidades Principales:
- [ ] ✅ Agregar camión con 3 campos de póliza
- [ ] ✅ Dashboard de validación se abre correctamente
- [ ] ✅ Ver transportistas pendientes
- [ ] ✅ Ver choferes pendientes
- [ ] ✅ Ver camiones pendientes con info de póliza
- [ ] ✅ Aprobar transportista
- [ ] ✅ Aprobar chofer
- [ ] ✅ Aprobar camión
- [ ] ✅ Ver badges "VALIDADO" verdes
- [ ] ✅ Ver fechas de validación
- [ ] ✅ Búsqueda funciona en tiempo real
- [ ] ✅ Toggle pendientes/validados funciona
- [ ] ✅ Restricción: NO asignar sin validados
- [ ] ✅ Restricción: SOLO asignar validados
- [ ] ✅ Badges verdes en asignación
- [ ] ✅ Banners informativos visibles
- [ ] ✅ Revocar validación funciona
- [ ] ✅ Validaciones de formulario funcionan

### Estados de UI:
- [ ] ✅ Loading spinner mientras carga
- [ ] ✅ Estado vacío con mensaje
- [ ] ✅ Estado sin resultados de búsqueda
- [ ] ✅ SnackBars de confirmación
- [ ] ✅ Diálogos de confirmación

### Responsive:
- [ ] ✅ Dashboard se ve bien en pantalla completa
- [ ] ✅ Cards no se rompen en pantalla chica
- [ ] ✅ Badges no se sobreponen

---

## 🐛 ERRORES COMUNES Y SOLUCIONES

### Error 1: "No aparecen entidades en Dashboard"
**Causa:** No hay datos en Firestore  
**Solución:** Crear transportista, chofer y camión primero

### Error 2: "Botón Validar Flota no aparece"
**Causa:** Usuario no es Cliente  
**Solución:** Login con cuenta tipo Cliente

### Error 3: "Camiones no se filtran en asignación"
**Causa:** Reglas de Firestore no actualizadas  
**Solución:** Deploy reglas de Firestore

### Error 4: "Error al validar: Permission Denied"
**Causa:** Reglas de Firestore no permiten update  
**Solución:** Verificar reglas en Firebase Console

### Error 5: "Campos de póliza no se guardan"
**Causa:** Modelo no actualizado  
**Solución:** Verificar que crearCamion() tiene los 3 parámetros nuevos

---

## 🎯 CRITERIOS DE ÉXITO

### Para considerar el testing exitoso, DEBE cumplir:

1. ✅ **Funcionalidad Core:**
   - Cliente puede validar transportistas, choferes y camiones
   - Transportista solo puede asignar entidades validadas
   - Dashboard muestra información completa de pólizas

2. ✅ **UX:**
   - Badges verdes/naranjas visibles y claros
   - Mensajes de error/éxito apropiados
   - Confirmaciones antes de acciones importantes

3. ✅ **Seguridad:**
   - NO se puede asignar entidades no validadas
   - Queries filtran correctamente por is_validado_cliente
   - Cliente solo puede actualizar campos de validación

4. ✅ **Performance:**
   - Dashboard carga en <2 segundos
   - Búsqueda filtra instantáneamente
   - No hay lag al cambiar tabs

---

## 📝 REPORTE DE BUGS

Si encuentras algún bug durante el testing, documenta:

```
BUG #[número]
Título: [Breve descripción]
Severidad: [Crítico/Alto/Medio/Bajo]
Pasos para reproducir:
1. [Paso 1]
2. [Paso 2]
3. [Paso 3]
Resultado esperado: [Qué debería pasar]
Resultado actual: [Qué pasa realmente]
Capturas: [Si es posible]
```

---

## 🚀 DESPUÉS DEL TESTING

Una vez que todo funcione:

1. ✅ **Marcar todos los checkboxes** de esta guía
2. ✅ **Documentar bugs** encontrados
3. ✅ **Build de producción:**
   ```bash
   flutter clean
   flutter pub get
   flutter build web --release --no-tree-shake-icons
   ```
4. ✅ **Deploy:**
   ```bash
   firebase deploy --only hosting,firestore:rules --force
   ```
5. ✅ **Hard refresh** en producción (Ctrl+Shift+R)
6. ✅ **Testing final** en URL de producción

---

## 📞 CONTACTO

Si encuentras problemas graves o bugs críticos:
- Revisar consola del navegador (F12)
- Revisar logs de Firestore
- Verificar reglas de seguridad

---

**Creado:** 30 Enero 2025  
**Módulo:** 1 - Sistema de Validación  
**Versión:** 1.0  
**Estado:** ✅ LISTO PARA USAR

🧪 **¡Buena suerte con el testing!** 🧪
