# 🎨 GUÍA DE INTEGRACIÓN: UI de Reasignación

## ✅ Widgets Creados

1. **`ReasignarDialog`** - Dialog para transportista (cambiar chofer/camión)
2. **`HistorialCambiosWidget`** - Widget para cliente (ver y rechazar cambios)

---

## 📍 DÓNDE INTEGRAR

### 1. Vista del Transportista (Flete Asignado)

**Archivo:** `lib/screens/flete_detalle_transportista_page.dart` (o similar)

**Agregar botón "Cambiar Chofer/Camión":**

```dart
// Import
import 'package:cargoclick/widgets/reasignar_dialog.dart';

// En el build, después de mostrar los datos del chofer/camión actual:
if (flete.estado == 'asignado' || flete.estado == 'en_proceso') {
  Padding(
    padding: const EdgeInsets.all(16),
    child: ElevatedButton.icon(
      onPressed: () async {
        final resultado = await showDialog(
          context: context,
          builder: (context) => ReasignarDialog(
            fleteId: flete.id,
            transportistaId: currentUser.uid, // ID del transportista actual
            choferActualId: flete.choferAsignado,
            camionActualId: flete.camionAsignado,
          ),
        );

        if (resultado == true) {
          // Opcional: Refrescar la vista
          setState(() {});
        }
      },
      icon: const Icon(Icons.swap_horiz),
      label: const Text('Cambiar Chofer/Camión'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  ),
}
```

---

### 2. Vista del Cliente (Detalle de Flete)

**Archivo:** `lib/screens/fletes_cliente_detalle_page.dart`

**Agregar el widget de historial:**

```dart
// Import
import 'package:cargoclick/widgets/historial_cambios_widget.dart';

// En el build, después de la información del chofer/camión:
// (Solo si el flete está asignado, en_proceso o completado)
if (widget.flete.estado == 'asignado' || 
    widget.flete.estado == 'en_proceso' || 
    widget.flete.estado == 'completado') {
  Padding(
    padding: const EdgeInsets.all(16),
    child: HistorialCambiosWidget(
      fleteId: widget.flete.id,
      esCliente: true,
    ),
  ),
}
```

---

## 🎨 EJEMPLO COMPLETO DE INTEGRACIÓN

### Vista Transportista:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Flete ${widget.flete.numeroContenedor}'),
    ),
    body: SingleChildScrollView(
      child: Column(
        children: [
          // ... Información del flete ...
          
          // Información del chofer y camión actual
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(
                    icono: Icons.person,
                    titulo: 'Chofer Asignado',
                    valor: choferNombre,
                  ),
                  const Divider(),
                  _InfoRow(
                    icono: Icons.local_shipping,
                    titulo: 'Camión Asignado',
                    valor: camionPatente,
                  ),
                ],
              ),
            ),
          ),

          // NUEVO: Botón de reasignación
          if (widget.flete.estado == 'asignado' || 
              widget.flete.estado == 'en_proceso') ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final resultado = await showDialog(
                    context: context,
                    builder: (context) => ReasignarDialog(
                      fleteId: widget.flete.id,
                      transportistaId: widget.transportistaId,
                      choferActualId: widget.flete.choferAsignado,
                      camionActualId: widget.flete.camionAsignado,
                    ),
                  );

                  if (resultado == true && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Flete reasignado correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Cambiar Chofer/Camión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ... Resto de la información ...
        ],
      ),
    ),
  );
}
```

---

### Vista Cliente:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Flete ${widget.flete.numeroContenedor}'),
    ),
    body: SingleChildScrollView(
      child: Column(
        children: [
          // ... Información del flete ...
          
          // Información del chofer y camión
          if (widget.flete.estado != 'disponible' && 
              widget.flete.estado != 'solicitado') ...[
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Asignación Actual',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icono: Icons.person,
                      titulo: 'Chofer',
                      valor: choferNombre,
                    ),
                    const Divider(),
                    _InfoRow(
                      icono: Icons.local_shipping,
                      titulo: 'Camión',
                      valor: camionPatente,
                    ),
                  ],
                ),
              ),
            ),

            // NUEVO: Historial de cambios
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: HistorialCambiosWidget(
                fleteId: widget.flete.id,
                esCliente: true,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ... Resto de la información ...
        ],
      ),
    ),
  );
}
```

---

## 🚨 BADGE DE NOTIFICACIÓN (Opcional)

Para mostrar un badge cuando hay cambios pendientes de revisar:

```dart
// En la vista del cliente, en el AppBar:
AppBar(
  title: Text('Flete ${widget.flete.numeroContenedor}'),
  actions: [
    StreamBuilder<List<Map<String, dynamic>>>(
      stream: FleteService().getHistorialCambios(widget.flete.id),
      builder: (context, snapshot) {
        final cambios = snapshot.data ?? [];
        final cambiosPendientes = cambios.where((c) {
          final cambio = CambioAsignacion.fromJson(c, docId: c['id']);
          return cambio.puedeSerRechazado;
        }).length;

        if (cambiosPendientes == 0) return const SizedBox.shrink();

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                // Scroll automático al historial
              },
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '$cambiosPendientes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    ),
  ],
),
```

---

## 📱 NOTIFICACIÓN IN-APP

Cuando el cliente recibe una notificación de cambio, puedes mostrar un banner:

```dart
// En la vista del cliente, dentro del build:
StreamBuilder<List<Map<String, dynamic>>>(
  stream: FleteService().getHistorialCambios(widget.flete.id),
  builder: (context, snapshot) {
    final cambios = snapshot.data ?? [];
    final cambiosActivos = cambios.where((c) {
      final cambio = CambioAsignacion.fromJson(c, docId: c['id']);
      return cambio.puedeSerRechazado;
    }).toList();

    if (cambiosActivos.isEmpty) return const SizedBox.shrink();

    final ultimoCambio = CambioAsignacion.fromJson(
      cambiosActivos.first,
      docId: cambiosActivos.first['id'],
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.orange),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '¡Cambio de Asignación Pendiente!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'El transportista cambió la asignación. '
            'Tienes ${ultimoCambio.tiempoRestanteParaRechazar} para revisarlo.',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  },
),
```

---

## ✅ CHECKLIST DE INTEGRACIÓN

### Transportista:
- [ ] Importar `ReasignarDialog`
- [ ] Agregar botón "Cambiar Chofer/Camión"
- [ ] Solo mostrar si `estado == 'asignado' || 'en_proceso'`
- [ ] Pasar IDs correctos al dialog
- [ ] Manejar resultado del dialog (opcional)

### Cliente:
- [ ] Importar `HistorialCambiosWidget` y `CambioAsignacion`
- [ ] Agregar widget después de info de chofer/camión
- [ ] Solo mostrar si flete está asignado o posterior
- [ ] Pasar `esCliente: true`
- [ ] Agregar badge de notificación (opcional)
- [ ] Agregar banner de alerta (opcional)

---

## 🎯 TESTING

1. **Login como Transportista**
2. **Ve a un flete asignado**
3. **Click en "Cambiar Chofer/Camión"**
4. **Selecciona nuevo chofer y camión**
5. **Escribe razón**
6. **Confirma**

**Verificar:**
- ✅ Dialog se muestra correctamente
- ✅ Dropdowns muestran opciones
- ✅ Validaciones funcionan
- ✅ Se envía notificación/email al cliente

7. **Login como Cliente**
8. **Ve al mismo flete**
9. **Verifica que aparece el historial de cambios**
10. **Click en "Rechazar Cambio"**
11. **Escribe motivo**
12. **Confirma**

**Verificar:**
- ✅ Historial se muestra correctamente
- ✅ Badge de estado correcto
- ✅ Tiempo restante se muestra
- ✅ Botón "Rechazar" funciona
- ✅ Flete se revierte a asignación anterior

---

**Tiempo estimado de integración:** 30-45 minutos  
**Archivos a modificar:** 2 (vista transportista + vista cliente)

🎉 **¡Widgets listos para usar!** 🎉
