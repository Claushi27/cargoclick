# 🧪 GUÍA DE TESTING - FASE 3

**Fecha:** 2025-01-28  
**Funcionalidades a probar:** Rating, Tarifas Mínimas, Desglose de Costos

---

## 🚀 ANTES DE EMPEZAR

### 1. Compilar el Proyecto
```bash
cd C:\Proyectos\Cargo_click_mockpup
flutter pub get
flutter run -d chrome
```

### 2. Verificar que no hay errores
- Revisar consola de Flutter
- Verificar que la app carga sin errores
- Verificar que no hay warnings críticos

---

## ⭐ TESTING: SISTEMA DE RATING

### Test 1: Calificar Servicio Completado

**Prerequisitos:**
- Tener un flete en estado "completado"
- Estar logueado como cliente que creó el flete

**Pasos:**
1. Ir a "Mis Fletes" desde homepage
2. Seleccionar un flete completado
3. Scroll hasta el final de la página
4. ✅ Verificar que aparece botón amarillo "Calificar Servicio"
5. Presionar el botón
6. ✅ Modal se abre con 5 estrellas
7. Presionar en estrella 5 (última)
8. ✅ Texto cambia a "Excelente"
9. Escribir comentario: "Excelente servicio, muy puntual"
10. Presionar "Enviar"
11. ✅ SnackBar verde: "¡Gracias por tu calificación!"
12. ✅ Botón cambia a card verde: "¡Gracias por calificar!"

**Resultado esperado:** ✅ Rating guardado en Firestore

---

### Test 2: Rating Ya Existe (No Duplicar)

**Pasos:**
1. Intentar calificar el mismo flete del Test 1
2. ✅ Debe mostrar card verde de "Ya calificado"
3. ✅ No debe permitir calificar nuevamente

**Resultado esperado:** ✅ No se pueden duplicar ratings

---

### Test 3: Ver Estadísticas (Transportista)

**Prerequisitos:**
- Estar logueado como transportista que recibió rating

**Pasos:**
1. Desde homepage transportista, ir a "Mi Perfil"
2. Scroll hasta sección "CALIFICACIONES"
3. ✅ Verificar que muestra promedio (ej: 4.7)
4. ✅ Verificar que muestra estrellas visuales
5. ✅ Verificar distribución (5⭐: X, 4⭐: Y, etc.)
6. ✅ Verificar total de calificaciones

**Resultado esperado:** ✅ Estadísticas correctas y visibles

---

### Test 4: Rating en Listado de Transportistas

**Prerequisitos:**
- Estar logueado como cliente

**Pasos:**
1. Desde homepage, presionar icono 👥 (Ver Transportistas)
2. ✅ En cada card de transportista debe aparecer rating
3. ✅ Estrellas con promedio numérico
4. ✅ Si no tiene ratings: "Sin calificar"

**Resultado esperado:** ✅ Rating visible en todos los transportistas

---

## 💰 TESTING: SISTEMA DE TARIFAS MÍNIMAS

### Test 5: Configurar Tarifa Mínima

**Prerequisitos:**
- Estar logueado como transportista

**Pasos:**
1. Ir a "Mi Perfil"
2. Buscar sección "CONFIGURACIÓN DE FLETES"
3. ✅ Ver card de "Tarifa Mínima Aceptable"
4. Presionar botón "Editar"
5. ✅ Aparece input de texto
6. Ingresar: 150000
7. Presionar "Guardar"
8. ✅ SnackBar verde: "Tarifa mínima actualizada"
9. ✅ Card se actualiza mostrando: "$ 150.000 CLP"
10. ✅ Card tiene fondo verde claro

**Resultado esperado:** ✅ Tarifa guardada en Firestore

---

### Test 6: Filtrado Automático de Fletes

**Prerequisitos:**
- Tener tarifa mínima configurada ($150.000)
- Tener fletes disponibles con diferentes tarifas

**Pasos:**
1. Ir a "Fletes Disponibles"
2. ✅ En la parte superior debe aparecer banner verde
3. ✅ Banner dice: "Filtro de tarifa mínima activo: $150.000 CLP"
4. ✅ Banner tiene botón "Cambiar"
5. ✅ Lista solo muestra fletes con tarifa >= $150.000
6. ✅ En cada card aparece badge "Compatible" (verde)
7. Presionar "Cambiar" en banner
8. ✅ Navega a perfil del transportista

**Resultado esperado:** ✅ Solo fletes compatibles visibles

---

### Test 7: Badge de Compatibilidad

**Prerequisitos:**
- Tarifa mínima: $200.000
- Flete A con tarifa $250.000
- Flete B con tarifa $150.000

**Pasos:**
1. Ver lista de fletes disponibles
2. Buscar Flete A ($250.000)
3. ✅ Badge verde "Compatible" con check
4. Buscar Flete B ($150.000)
5. ✅ Badge naranja "Bajo mínimo" con warning
6. (Flete B puede no aparecer si filtro está activo)

**Resultado esperado:** ✅ Badges correctos según tarifa

---

### Test 8: Eliminar Tarifa Mínima

**Pasos:**
1. Ir a perfil transportista
2. Presionar "Editar" en tarifa mínima
3. Borrar todo el texto del input
4. Presionar "Guardar"
5. ✅ SnackBar verde: "Tarifa mínima eliminada"
6. ✅ Card cambia a gris: "Sin tarifa mínima"
7. Ir a "Fletes Disponibles"
8. ✅ No aparece banner verde de filtro
9. ✅ Se ven todos los fletes
10. ✅ No aparecen badges de compatibilidad

**Resultado esperado:** ✅ Filtro desactivado, todos los fletes visibles

---

## 💵 TESTING: DESGLOSE DE COSTOS

### Test 9: Ver Desglose Básico

**Prerequisitos:**
- Flete con solo tarifa base (sin servicios adicionales)

**Pasos:**
1. Como cliente, ir a "Mis Fletes"
2. Seleccionar cualquier flete
3. Buscar card "Desglose de Costos"
4. ✅ Debe aparecer después de info básica
5. ✅ Header con icono de recibo
6. ✅ "Tarifa base de transporte: $ XXX CLP"
7. ✅ "TOTAL" en container verde
8. ✅ Nota informativa en azul claro
9. ✅ Total = Tarifa base (sin adicionales)

**Resultado esperado:** ✅ Desglose visible y correcto

---

### Test 10: Desglose con Servicios Adicionales

**Prerequisitos:**
- Flete con servicios adicionales que incluyan palabra "seguro"

**Pasos:**
1. Ver detalle del flete
2. Buscar "Desglose de Costos"
3. ✅ Tarifa base: $ XXX
4. ✅ Seguro de carga: $ 15.000
5. ✅ Total = Base + 15.000
6. ✅ Container verde con total destacado

**Resultado esperado:** ✅ Adicionales detectados y sumados

---

### Test 11: Contenedor Reefer

**Prerequisitos:**
- Flete con tipo contenedor "CTN Reefer 40"

**Pasos:**
1. Ver detalle del flete
2. Buscar desglose
3. ✅ Debe aparecer "Control de temperatura: $ 30.000"
4. ✅ Aunque no esté en serviciosAdicionales
5. ✅ Total incluye este costo

**Resultado esperado:** ✅ Tipo de contenedor detectado correctamente

---

### Test 12: Múltiples Adicionales

**Prerequisitos:**
- Flete con "seguro" y "escolta" en serviciosAdicionales
- Flete con "rampa" en requisitosEspeciales

**Pasos:**
1. Ver desglose de costos
2. ✅ Seguro de carga: $ 15.000
3. ✅ Servicio de escolta: $ 50.000
4. ✅ Equipo de descarga: $ 25.000
5. ✅ Total = Base + 15.000 + 50.000 + 25.000
6. ✅ Todos los items listados correctamente

**Resultado esperado:** ✅ Suma correcta de múltiples adicionales

---

## 🔗 TESTING DE INTEGRACIÓN

### Test 13: Flujo Completo Cliente

**Pasos:**
1. Cliente publica flete (tarifa: $200.000)
2. ✅ Ve desglose de costos estimado
3. Transportista (tarifa mínima $150.000) ve el flete
4. ✅ Flete aparece en lista (cumple con mínimo)
5. ✅ Badge "Compatible" visible
6. Transportista acepta y asigna
7. Flete se completa
8. Cliente califica con 5 estrellas
9. ✅ Rating guardado
10. Transportista ve rating en su perfil
11. ✅ Promedio actualizado
12. Otros clientes ven rating en listado
13. ✅ Rating visible para todos

**Resultado esperado:** ✅ Flujo completo funciona end-to-end

---

## 🐛 CASOS DE ERROR A VERIFICAR

### Error 1: Calificar Sin Transportista Asignado
- Flete sin transportista
- Botón "Calificar" no debe aparecer
- O debe mostrar mensaje de error

### Error 2: Tarifa Negativa
- Intentar guardar tarifa -1000
- Debe mostrar error de validación

### Error 3: Tarifa No Numérica
- Intentar guardar "abc123"
- Debe mostrar error de validación

### Error 4: Costos Sin Datos
- Flete sin serviciosAdicionales ni requisitosEspeciales
- Debe mostrar solo tarifa base
- No debe crashear

---

## ✅ CHECKLIST GENERAL

### Funcionalidad:
- [ ] Rating: Crear calificación
- [ ] Rating: Ver estadísticas
- [ ] Rating: Visible en listados
- [ ] Rating: No duplicar
- [ ] Tarifas: Configurar mínimo
- [ ] Tarifas: Filtrado automático
- [ ] Tarifas: Badges compatibilidad
- [ ] Tarifas: Eliminar configuración
- [ ] Costos: Desglose visible
- [ ] Costos: Cálculo correcto
- [ ] Costos: Formato chileno
- [ ] Costos: Múltiples adicionales

### UI/UX:
- [ ] Todas las vistas cargan correctamente
- [ ] No hay errores en consola
- [ ] Animaciones fluidas
- [ ] Loading states funcionan
- [ ] SnackBars aparecen
- [ ] Colores y estilos consistentes
- [ ] Responsive en diferentes tamaños

### Datos:
- [ ] Firestore guarda correctamente
- [ ] Firestore lee correctamente
- [ ] Cálculos son precisos
- [ ] Formato de moneda correcto
- [ ] Timestamps se guardan bien

---

## 🚀 DESPUÉS DEL TESTING

### Si TODO funciona:
```bash
# Build release
flutter clean
flutter pub get
flutter build web --release

# Deploy
firebase deploy --only hosting,firestore:rules

# Probar en producción (incógnito)
```

### Si hay ERRORES:
1. Anotar errores encontrados
2. Reproducir pasos
3. Revisar consola de Flutter
4. Corregir código
5. Repetir testing

---

## 📊 REPORTE DE TESTING

Al finalizar, completar:

### Funcionalidades Probadas: __/12
### Tests Pasados: __/13
### Errores Encontrados: __
### Tiempo de Testing: __ horas

### Notas:
```
[Anotar aquí cualquier observación, error o mejora detectada]
```

---

**Última actualización:** 2025-01-28  
**Versión:** Fase 3 Completa  
**Estado:** ⏳ Listo para testing
