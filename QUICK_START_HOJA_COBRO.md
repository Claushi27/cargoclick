# 🚀 QUICK START: Hoja de Detalle de Cobro

**Implementación rápida y uso del módulo de facturación**

---

## ✨ ¿Qué es?

Una **Hoja de Detalle de Cobro/Facturación** profesional que aparece automáticamente cuando un flete es marcado como "completado" por el chofer. Muestra un desglose completo de todos los conceptos facturables con cálculo automático de IVA.

---

## 🎯 Uso Básico

### En la App Cliente:

1. **Acceso:**
   ```
   Login → Mis Fletes → [Seleccionar flete completado]
   ```

2. **Visualización:**
   - Scroll hasta el final de la pantalla
   - La hoja aparece después de la información de asignación
   - Solo visible si `estado == 'completado'`

---

## 📝 Campos Firestore Requeridos

### Documento `/fletes/{fleteId}`:

```javascript
{
  // CAMPOS OBLIGATORIOS
  "estado": "completado",          // ⚠️ CRÍTICO
  "tarifa": 100000,                // Total del flete
  
  // CAMPOS OPCIONALES (para desglose)
  "tarifa_base": 100000,           // Base sin adicionales
  "valor_adicional_perimetro": 25000,
  "valor_adicional_sobrepeso": 30000,
  "valor_sobreestadia": 15000,
  "valor_adicional_extra": 10000,
  "requisitos_especiales": "Descripción de servicios"
}
```

---

## 💡 Ejemplo Mínimo

**Firestore:**
```json
{
  "estado": "completado",
  "tarifa": 100000
}
```

**Resultado en App:**
```
╔═══════════════════════════════════╗
║ HOJA DE DETALLE DE COBRO          ║
╠═══════════════════════════════════╣
║ Flete Origen → Destino  $ 100.000 ║
║ ──────────────────────────────────║
║ Subtotal                $ 100.000 ║
║ IVA (19%)               $  19.000 ║
║ ──────────────────────────────────║
║ TOTAL A FACTURAR        $ 119.000 ║
╚═══════════════════════════════════╝
```

---

## 💰 Ejemplo Completo

**Firestore:**
```json
{
  "estado": "completado",
  "tarifa": 300000,
  "tarifa_base": 180000,
  "valor_adicional_perimetro": 50000,
  "valor_adicional_sobrepeso": 40000,
  "valor_sobreestadia": 20000,
  "valor_adicional_extra": 10000,
  "requisitos_especiales": "Control de temperatura"
}
```

**Resultado en App:**
```
╔════════════════════════════════════════╗
║ HOJA DE DETALLE DE COBRO               ║
╠════════════════════════════════════════╣
║ CONCEPTO BASE                          ║
║ Flete Origen → Destino     $ 180.000   ║
║                                        ║
║ ADICIONALES                            ║
║ Recargo Fuera de Perímetro $  50.000   ║
║ Recargo por Sobrepeso      $  40.000   ║
║ Sobrestadía                $  20.000   ║
║ Requisitos Especiales      $  10.000   ║
║                                        ║
║ ────────────────────────────────────   ║
║ Subtotal                   $ 300.000   ║
║ IVA (19%)                  $  57.000   ║
║ ────────────────────────────────────   ║
║ TOTAL A FACTURAR           $ 357.000   ║
╚════════════════════════════════════════╝
```

---

## 🔧 Modificar Valores

### Opción 1: Firebase Console

1. Ir a Firestore Database
2. Collection `fletes` → [tu flete]
3. Editar campos:
   - `tarifa_base`
   - `valor_adicional_perimetro`
   - `valor_adicional_sobrepeso`
   - `valor_sobreestadia`
   - `valor_adicional_extra`
4. Guardar

### Opción 2: Desde código (FleteService)

```dart
await FirebaseFirestore.instance
  .collection('fletes')
  .doc(fleteId)
  .update({
    'tarifa_base': 150000,
    'valor_adicional_perimetro': 30000,
    'valor_sobreestadia': 15000,
  });
```

---

## 🎨 Conceptos y Sus Iconos

| Concepto | Icono | Campo Firestore |
|----------|-------|-----------------|
| Base | 📦 | `tarifa_base` |
| Perímetro | 📍 | `valor_adicional_perimetro` |
| Sobrepeso | 🏋️ | `valor_adicional_sobrepeso` |
| Sobrestadía | ⏰ | `valor_sobreestadia` |
| Especiales | 🔧 | `valor_adicional_extra` |

---

## ⚙️ Configuración del IVA

**Por defecto:** 19%

**Modificar en:** `lib/widgets/hoja_cobro_card.dart`

```dart
double _calcularIVA(double subtotal) {
  return subtotal * 0.19; // Cambiar aquí
}
```

---

## 🔍 Debug Rápido

### La hoja NO aparece:

✅ **Verificar:**
1. `estado` del flete es `'completado'` (no "Completado" ni "COMPLETADO")
2. El usuario logueado es el cliente del flete
3. El flete tiene `id` válido

### Los valores son incorrectos:

✅ **Verificar:**
1. Campos en Firestore son de tipo `number`, no `string`
2. No hay valores negativos
3. `tarifa` está definida

### Error "null check operator":

✅ **Solución:**
```dart
// El widget ya maneja nulls, pero si persiste:
tarifaBase: widget.flete.tarifaBase ?? widget.flete.tarifa
```

---

## 📱 Interfaz de Usuario

### Estados Visuales:

**Antes de Completar (otros estados):**
```
┌─────────────────────────────┐
│ Desglose de Costos          │  ← DesgloseCostosCard
│ (Vista previa sin IVA)      │
└─────────────────────────────┘
```

**Después de Completar:**
```
┌─────────────────────────────┐
│ HOJA DE DETALLE DE COBRO    │  ← HojaCobroCard
│ (Oficial con IVA)           │
└─────────────────────────────┘
```

---

## 🚦 Estados del Flete

| Estado | Widget Mostrado | IVA Incluido |
|--------|-----------------|--------------|
| `disponible` | DesgloseCostosCard | ❌ |
| `solicitado` | DesgloseCostosCard | ❌ |
| `asignado` | DesgloseCostosCard | ❌ |
| `en_proceso` | DesgloseCostosCard | ❌ |
| **`completado`** | **HojaCobroCard** | ✅ |

---

## 📂 Archivos Clave

```
lib/
├── models/
│   └── flete.dart                     # Modelo con campos nuevos
│
├── widgets/
│   └── hoja_cobro_card.dart           # Widget principal
│
└── screens/
    └── fletes_cliente_detalle_page.dart  # Integración
```

---

## 🎯 Checklist de Integración

Para usar en un nuevo proyecto:

- [ ] Copiar `lib/widgets/hoja_cobro_card.dart`
- [ ] Agregar campos al modelo `Flete`
- [ ] Importar en la vista de detalle
- [ ] Agregar condicional `if (estado == 'completado')`
- [ ] Actualizar reglas de Firestore (opcional)

---

## 📊 Fórmulas de Cálculo

```
Subtotal = tarifa_base 
         + valor_adicional_perimetro 
         + valor_adicional_sobrepeso 
         + valor_sobreestadia 
         + valor_adicional_extra

IVA = Subtotal * 0.19

Total = Subtotal + IVA
```

---

## 🔐 Seguridad

**Firestore Rules recomendadas:**

```javascript
match /fletes/{fleteId} {
  // Solo el cliente puede editar valores de facturación
  allow update: if request.auth.uid == resource.data.cliente_id
    && onlyUpdating([
      'tarifa_base',
      'valor_adicional_perimetro',
      'valor_adicional_sobrepeso',
      'valor_sobreestadia',
      'valor_adicional_extra'
    ]);
}
```

---

## 🎓 Recursos Adicionales

- **Implementación completa:** `HOJA_COBRO_IMPLEMENTADA.md`
- **Casos de prueba:** `GUIA_TESTING_HOJA_COBRO.md`
- **Código fuente:** `lib/widgets/hoja_cobro_card.dart`

---

## 💬 FAQ

**Q: ¿Puedo cambiar el porcentaje del IVA?**  
A: Sí, modificar en `_calcularIVA()` en `hoja_cobro_card.dart`

**Q: ¿Funciona sin `tarifa_base`?**  
A: Sí, usa `tarifa` como fallback automáticamente

**Q: ¿Puedo ocultar conceptos específicos?**  
A: Sí, conceptos con valor `null` o `0` se ocultan automáticamente

**Q: ¿Se puede exportar a PDF?**  
A: No actualmente, pero se puede implementar con `pdf` package

**Q: ¿El IVA se guarda en Firestore?**  
A: No, se calcula en tiempo real desde el widget

---

**Creado:** 14 Noviembre 2025  
**Versión:** 1.0  
**Mantenedor:** CargoClick Dev Team

🎉 **¡Listo para usar!** 🎉
