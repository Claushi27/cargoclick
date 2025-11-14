# 📝 GUÍA DE TESTING: HOJA DE COBRO/FACTURACIÓN

Esta guía proporciona casos de prueba específicos para validar la funcionalidad de la Hoja de Detalle de Cobro.

---

## 🧪 CASOS DE PRUEBA

### Test 1: Flete Simple - Solo Tarifa Base

**Objetivo:** Verificar el cálculo correcto con el mínimo de datos.

**Datos de entrada:**
```dart
Flete(
  id: 'test-001',
  clienteId: 'cliente-123',
  numeroContenedor: 'CTN-TEST-001',
  estado: 'completado',
  origen: 'Puerto San Antonio',
  destino: 'Santiago Centro',
  tarifa: 100000,
  tarifaBase: 100000,
  // Sin adicionales
)
```

**Resultado esperado:**
```
CONCEPTO BASE
📦 Flete Origen → Destino          $ 100.000

────────────────────────────────────────────
Subtotal                           $ 100.000
IVA (19%)                          $  19.000
────────────────────────────────────────────
TOTAL A FACTURAR                   $ 119.000
```

---

### Test 2: Flete con Recargo por Perímetro

**Objetivo:** Validar cálculo de adicional por perímetro.

**Datos de entrada:**
```dart
Flete(
  id: 'test-002',
  clienteId: 'cliente-123',
  numeroContenedor: 'CTN-TEST-002',
  estado: 'completado',
  origen: 'Valparaíso',
  destino: 'Los Ángeles',
  tarifa: 180000,
  tarifaBase: 150000,
  valorAdicionalPerimetro: 30000,
  isFueraDePerimetro: true,
)
```

**Resultado esperado:**
```
CONCEPTO BASE
📦 Flete Origen → Destino          $ 150.000

ADICIONALES
📍 Recargo Fuera de Perímetro      $  30.000

────────────────────────────────────────────
Subtotal                           $ 180.000
IVA (19%)                          $  34.200
────────────────────────────────────────────
TOTAL A FACTURAR                   $ 214.200
```

---

### Test 3: Flete con Sobrepeso

**Objetivo:** Validar cálculo de adicional por sobrepeso.

**Datos de entrada:**
```dart
Flete(
  id: 'test-003',
  clienteId: 'cliente-123',
  numeroContenedor: 'CTN-TEST-003',
  estado: 'completado',
  origen: 'Puerto San Antonio',
  destino: 'Santiago',
  peso: 28000, // 28 toneladas (excede 25)
  tarifa: 170000,
  tarifaBase: 130000,
  valorAdicionalSobrepeso: 40000,
)
```

**Resultado esperado:**
```
CONCEPTO BASE
📦 Flete Origen → Destino          $ 130.000

ADICIONALES
🏋️ Recargo por Sobrepeso           $  40.000

────────────────────────────────────────────
Subtotal                           $ 170.000
IVA (19%)                          $  32.300
────────────────────────────────────────────
TOTAL A FACTURAR                   $ 202.300
```

---

### Test 4: Flete con Sobrestadía

**Objetivo:** Validar cálculo de sobrestadía.

**Datos de entrada:**
```dart
Flete(
  id: 'test-004',
  clienteId: 'cliente-123',
  numeroContenedor: 'CTN-TEST-004',
  estado: 'completado',
  origen: 'Puerto Valparaíso',
  destino: 'Viña del Mar',
  tarifa: 135000,
  tarifaBase: 120000,
  valorSobreestadia: 15000, // 3 horas @ $5.000/hora
)
```

**Resultado esperado:**
```
CONCEPTO BASE
📦 Flete Origen → Destino          $ 120.000

ADICIONALES
⏰ Sobrestadía                      $  15.000
   Tiempo adicional de espera

────────────────────────────────────────────
Subtotal                           $ 135.000
IVA (19%)                          $  25.650
────────────────────────────────────────────
TOTAL A FACTURAR                   $ 160.650
```

---

### Test 5: Flete con Requisitos Especiales

**Objetivo:** Validar cálculo de servicios adicionales.

**Datos de entrada:**
```dart
Flete(
  id: 'test-005',
  clienteId: 'cliente-123',
  numeroContenedor: 'CTN-TEST-005',
  estado: 'completado',
  origen: 'San Antonio',
  destino: 'Santiago',
  tarifa: 160000,
  tarifaBase: 140000,
  valorAdicionalExtra: 20000,
  requisitosEspeciales: 'Descarga con montacargas y personal especializado',
)
```

**Resultado esperado:**
```
CONCEPTO BASE
📦 Flete Origen → Destino          $ 140.000

ADICIONALES
🔧 Requisitos Especiales            $  20.000
   Descarga con montacargas y 
   personal especializado

────────────────────────────────────────────
Subtotal                           $ 160.000
IVA (19%)                          $  30.400
────────────────────────────────────────────
TOTAL A FACTURAR                   $ 190.400
```

---

### Test 6: Flete Completo - Todos los Adicionales

**Objetivo:** Validar el escenario más complejo con todos los conceptos.

**Datos de entrada:**
```dart
Flete(
  id: 'test-006',
  clienteId: 'cliente-123',
  numeroContenedor: 'CTN-FULL-001',
  estado: 'completado',
  origen: 'Puerto San Antonio',
  destino: 'Los Ángeles',
  peso: 30000, // 30 toneladas
  tarifa: 300000,
  tarifaBase: 180000,
  valorAdicionalPerimetro: 50000,
  valorAdicionalSobrepeso: 40000,
  valorSobreestadia: 20000,
  valorAdicionalExtra: 10000,
  requisitosEspeciales: 'Carga refrigerada - Control de temperatura',
  isFueraDePerimetro: true,
)
```

**Resultado esperado:**
```
CONCEPTO BASE
📦 Flete Origen → Destino          $ 180.000

ADICIONALES
📍 Recargo Fuera de Perímetro      $  50.000
   Destino fuera del radio estándar

🏋️ Recargo por Sobrepeso           $  40.000
   Excede las 25 toneladas

⏰ Sobrestadía                      $  20.000
   Tiempo adicional de espera

🔧 Requisitos Especiales            $  10.000
   Carga refrigerada - Control 
   de temperatura

────────────────────────────────────────────
Subtotal                           $ 300.000
IVA (19%)                          $  57.000
────────────────────────────────────────────
TOTAL A FACTURAR                   $ 357.000
```

---

### Test 7: Flete Sin Tarifa Base (Fallback)

**Objetivo:** Validar que funciona cuando `tarifaBase` es null.

**Datos de entrada:**
```dart
Flete(
  id: 'test-007',
  clienteId: 'cliente-123',
  numeroContenedor: 'CTN-OLD-001',
  estado: 'completado',
  origen: 'Santiago',
  destino: 'Valparaíso',
  tarifa: 90000,
  // tarifaBase: null (no definido)
)
```

**Resultado esperado:**
```
CONCEPTO BASE
📦 Flete Origen → Destino          $  90.000

────────────────────────────────────────────
Subtotal                           $  90.000
IVA (19%)                          $  17.100
────────────────────────────────────────────
TOTAL A FACTURAR                   $ 107.100
```

---

### Test 8: Flete NO Completado (No Mostrar Hoja)

**Objetivo:** Verificar que la hoja solo aparece en estado 'completado'.

**Datos de entrada:**
```dart
Flete(
  id: 'test-008',
  clienteId: 'cliente-123',
  numeroContenedor: 'CTN-ASIG-001',
  estado: 'asignado', // ❌ NO completado
  origen: 'San Antonio',
  destino: 'Santiago',
  tarifa: 100000,
  tarifaBase: 100000,
)
```

**Resultado esperado:**
```
✅ NO mostrar HojaCobroCard
✅ Mostrar DesgloseCostosCard en su lugar
```

---

## 🛠️ CÓMO EJECUTAR LOS TESTS

### Opción 1: Testing Manual en App

1. **Preparar datos en Firestore:**
```javascript
// Firebase Console → Firestore → Collection 'fletes'
// Crear documento con los datos del test deseado
```

2. **Navegar en la app:**
```
Login como Cliente → Mis Fletes → [Seleccionar flete completado]
```

3. **Verificar la hoja:**
- Scroll hasta el final
- Verificar que aparezca "HOJA DE DETALLE DE COBRO"
- Validar cada concepto y valor

### Opción 2: Widget Test (Código)

```dart
// test/widgets/hoja_cobro_card_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:cargoclick/widgets/hoja_cobro_card.dart';

void main() {
  testWidgets('Test 1: Flete Simple', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HojaCobroCard(
            tarifaBase: 100000,
            total: 100000,
          ),
        ),
      ),
    );

    // Verificar que aparece el título
    expect(find.text('HOJA DE DETALLE DE COBRO'), findsOneWidget);
    
    // Verificar subtotal
    expect(find.text('\$ 100.000'), findsOneWidget);
    
    // Verificar IVA
    expect(find.text('\$ 19.000'), findsOneWidget);
    
    // Verificar total
    expect(find.text('\$ 119.000'), findsOneWidget);
  });
}
```

### Opción 3: Testing con Hot Reload

1. **Modificar temporalmente un flete en código:**
```dart
// En fletes_cliente_detalle_page.dart (SOLO PARA TEST)
// Agregar en el widget build():

if (kDebugMode && widget.flete.id == 'test-id') {
  // Override temporal para testing
  return HojaCobroCard(
    tarifaBase: 180000,
    valorAdicionalPerimetro: 50000,
    valorAdicionalSobrepeso: 40000,
    valorSobreestadia: 20000,
    valorAdicionalExtra: 10000,
    requisitosEspeciales: 'Test completo',
    total: 300000,
  );
}
```

2. **Ejecutar con hot reload:**
```bash
flutter run
# Luego al modificar valores, usar 'r' para hot reload
```

---

## ✅ CHECKLIST DE VALIDACIÓN

Después de ejecutar cada test, verificar:

### Visual:
- [ ] Card tiene bordes redondeados
- [ ] Gradiente de fondo visible
- [ ] Icono de recibo en header
- [ ] Cada concepto tiene su icono
- [ ] Total destacado en azul
- [ ] Nota informativa al pie

### Cálculos:
- [ ] Subtotal = suma correcta de conceptos
- [ ] IVA = 19% del subtotal
- [ ] Total = Subtotal + IVA
- [ ] Formateo de moneda correcto ($ XX.XXX)

### Condicional:
- [ ] Solo aparece si estado == 'completado'
- [ ] Si no está completado, muestra DesgloseCostosCard
- [ ] Conceptos con valor 0 se ocultan
- [ ] Si tarifaBase es null, usa tarifa

### Funcionalidad:
- [ ] Responsive en diferentes tamaños de pantalla
- [ ] Scroll funciona correctamente
- [ ] No hay overflow de texto
- [ ] Iconos correctos para cada concepto

---

## 🐛 ERRORES COMUNES

### Error 1: "null check operator"
**Causa:** Falta manejar valores null
**Solución:** Usar operador `??` para valores por defecto

### Error 2: "RenderFlex overflow"
**Causa:** Texto muy largo sin wrap
**Solución:** Widget `Expanded` ya implementado

### Error 3: Total no coincide
**Causa:** No se están sumando todos los adicionales
**Solución:** Revisar método `_calcularSubtotal()`

### Error 4: Hoja no aparece
**Causa:** Estado no es 'completado'
**Solución:** Verificar `widget.flete.estado == 'completado'`

---

## 📊 VALORES DE REFERENCIA

### Tarifas Típicas en CLP:

| Concepto | Rango Típico |
|----------|--------------|
| Tarifa Base | $80.000 - $200.000 |
| Perímetro | $20.000 - $60.000 |
| Sobrepeso | $30.000 - $50.000 |
| Sobrestadía (por hora) | $5.000 - $8.000 |
| Requisitos Especiales | $10.000 - $30.000 |

### IVA:
- Tasa actual: **19%**
- Aplicado sobre el subtotal

---

## 🎯 CRITERIOS DE ACEPTACIÓN

Para considerar la implementación exitosa:

1. ✅ **Cálculos correctos** en todos los tests
2. ✅ **UI profesional** y clara
3. ✅ **Condicional funciona** (solo en 'completado')
4. ✅ **Sin errores** en consola
5. ✅ **Responsive** en diferentes dispositivos
6. ✅ **Formateo correcto** de moneda CLP

---

**Última actualización:** 14 Noviembre 2025  
**Autor:** Sistema de Testing CargoClick  
**Versión:** 1.0
