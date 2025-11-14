import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cargoclick/models/flete.dart';
import 'package:cargoclick/models/checkpoint.dart';
import 'package:cargoclick/services/checkpoint_service.dart';
import 'package:cargoclick/services/permission_service.dart';
import 'package:cargoclick/screens/detalle_cobro_page.dart'; // MÓDULO 4
import 'package:intl/intl.dart';

class FleteDetailPage extends StatefulWidget {
  final Flete flete;
  final String choferId;

  const FleteDetailPage({
    super.key,
    required this.flete,
    required this.choferId,
  });

  @override
  State<FleteDetailPage> createState() => _FleteDetailPageState();
}

class _FleteDetailPageState extends State<FleteDetailPage> {
  final _checkpointService = CheckpointService();
  final _picker = ImagePicker();

  Future<void> _subirCheckpoint(Map<String, dynamic> checkpointType) async {
    final tipo = checkpointType['id'] as String;
    final requiereFotos = checkpointType['requiereFotos'] as int;
    final esUbicacionGPS = tipo == 'ubicacion_gps';

    // 1. SOLICITAR PERMISO DE CÁMARA
    if (!await PermissionService.requestCameraPermission(context)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se necesita permiso de cámara para tomar fotos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2. Mostrar diálogo para elegir fuente
    final source = await showModalBottomSheet<ImageSource?>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Cámara'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_outlined),
              title: const Text('Galería / Archivos'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    // 3. Recolectar fotos (ahora guardamos Files en lugar de Uint8List)
    final fotosFiles = <File>[];
    for (var i = 0; i < requiereFotos; i++) {
      try {
        final picked = await _picker.pickImage(
          source: source,
          imageQuality: 85, // Calidad inicial razonable
          maxWidth: 2400,   // Límite de tamaño inicial
        );
        if (picked == null) {
          if (i == 0) return; // Si cancela la primera, salir
          break; // Si cancela una subsecuente, continuar con las que tiene
        }
        
        // Guardar como File para usar compresión después
        final file = File(picked.path);
        fotosFiles.add(file);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar foto: $e')),
        );
        return;
      }
    }

    if (fotosFiles.isEmpty) return;

    // 4. Mostrar preview y confirmar
    final notaController = TextEditingController();
    final gpsLinkController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(checkpointType['titulo'] as String),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                checkpointType['descripcion'] as String,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              ...fotosFiles.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Foto ${entry.key + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          entry.value,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              if (esUbicacionGPS) ...[
                TextField(
                  controller: gpsLinkController,
                  decoration: const InputDecoration(
                    labelText: 'Link GPS en tiempo real (opcional)',
                    hintText: 'https://maps.google.com/...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Text(
                  'Puedes pegar un link de Google Maps u otro servicio de GPS',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: notaController,
                decoration: const InputDecoration(
                  labelText: 'Nota (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLength: 200,
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Subir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 5. Mostrar loading mientras sube
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Comprimiendo y subiendo fotos...'),
              ],
            ),
          ),
        ),
      ),
    );

    // 6. Subir checkpoint con COMPRESIÓN AUTOMÁTICA
    try {
      await _checkpointService.subirCheckpointOptimizado(
        fleteId: widget.flete.id!,
        choferId: widget.choferId,
        tipo: tipo,
        fotosFiles: fotosFiles, // ← Ahora usa Files y comprime automáticamente
        notas: notaController.text.trim().isEmpty
            ? null
            : notaController.text.trim(),
        ubicacion: null, // TODO: Capturar GPS automático
        gpsLink: gpsLinkController.text.trim().isEmpty
            ? null
            : gpsLinkController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context); // Cerrar loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Checkpoint subido exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Cerrar loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al subir checkpoint: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Flete ${widget.flete.numeroContenedor}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del flete
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.primaryContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.flete.origen} → ${widget.flete.destino}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 16,
                          color: theme.colorScheme.onPrimaryContainer),
                      const SizedBox(width: 4),
                      Text(
                        'Contenedor: ${widget.flete.numeroContenedor}',
                        style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.scale_outlined,
                          size: 16,
                          color: theme.colorScheme.onPrimaryContainer),
                      const SizedBox(width: 4),
                      Text(
                        'Peso: ${widget.flete.peso} kg',
                        style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // NUEVO: Dropdown con TODA la información del flete
            Padding(
              padding: const EdgeInsets.all(16),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  title: Text(
                    '📋 Ver Información Completa del Flete',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  subtitle: const Text(
                    'Toca para ver todos los detalles',
                    style: TextStyle(fontSize: 13),
                  ),
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('📦 Número Contenedor', widget.flete.numeroContenedor, bold: true),
                          const Divider(height: 20),
                          _buildInfoRow('📐 Tipo Contenedor', widget.flete.tipoContenedor),
                          _buildInfoRow('⚖️ Peso Total', '${NumberFormat('#,###', 'es_CL').format(widget.flete.peso)} kg'),
                          if (widget.flete.pesoCargaNeta != null)
                            _buildInfoRow('  📦 Carga Neta', '${NumberFormat('#,###', 'es_CL').format(widget.flete.pesoCargaNeta)} kg'),
                          if (widget.flete.pesoTara != null)
                            _buildInfoRow('  ⚖️ Tara', '${NumberFormat('#,###', 'es_CL').format(widget.flete.pesoTara)} kg'),
                          const Divider(height: 20),
                          _buildInfoRow('🏭 Origen', widget.flete.origen, bold: true),
                          if (widget.flete.puertoOrigen != null)
                            _buildInfoRow('  ⚓ Puerto Origen', widget.flete.puertoOrigen!),
                          if (widget.flete.rutIngresoSti != null)
                            _buildInfoRow('  🆔 RUT STI', widget.flete.rutIngresoSti!),
                          if (widget.flete.rutIngresoPc != null)
                            _buildInfoRow('  🆔 RUT PC', widget.flete.rutIngresoPc!),
                          const Divider(height: 20),
                          _buildInfoRow('🎯 Destino', widget.flete.destino, bold: true),
                          if (widget.flete.direccionDestino != null)
                            _buildInfoRow('  📍 Dirección', widget.flete.direccionDestino!),
                          const Divider(height: 20),
                          if (widget.flete.fechaHoraCarga != null)
                            _buildInfoRow('📅 Fecha y Hora Carga', 
                              DateFormat('dd/MM/yyyy HH:mm').format(widget.flete.fechaHoraCarga!), 
                              bold: true),
                          _buildInfoRow('💰 Tarifa', '\$${NumberFormat('#,###', 'es_CL').format(widget.flete.tarifa)}', bold: true),
                          if (widget.flete.tarifaBase != null)
                            _buildInfoRow('💵 Tarifa Base', '\$${NumberFormat('#,###', 'es_CL').format(widget.flete.tarifaBase)}'),
                          if (widget.flete.isFueraDePerimetro)
                            _buildInfoRow('📍 Fuera de Perímetro', 'SÍ', bold: true),
                          if (widget.flete.valorAdicionalPerimetro != null)
                            _buildInfoRow('💰 Valor Perímetro', '\$${NumberFormat('#,###', 'es_CL').format(widget.flete.valorAdicionalPerimetro)}'),
                          if (widget.flete.valorAdicionalSobrepeso != null)
                            _buildInfoRow('⚠️ Valor Sobrepeso', '\$${NumberFormat('#,###', 'es_CL').format(widget.flete.valorAdicionalSobrepeso)}'),
                          if (widget.flete.tipoDeRampla != null)
                            _buildInfoRow('🚛 Tipo Rampla', widget.flete.tipoDeRampla!),
                          const Divider(height: 20),
                          if (widget.flete.requisitosEspeciales != null) ...[
                            _buildInfoRow('⚠️ Requisitos Especiales', widget.flete.requisitosEspeciales!, multiline: true),
                            const SizedBox(height: 12),
                          ],
                          if (widget.flete.serviciosAdicionales != null) ...[
                            _buildInfoRow('➕ Servicios Adicionales', widget.flete.serviciosAdicionales!, multiline: true),
                            const SizedBox(height: 12),
                          ],
                          if (widget.flete.devolucionCtnVacio != null) ...[
                            _buildInfoRow('↩️ Devolución Contenedor', widget.flete.devolucionCtnVacio!, multiline: true),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(),

            // Progreso general
            FutureBuilder<Map<String, int>>(
              future: _checkpointService.getProgreso(widget.flete.id!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final completados = snapshot.data!['completados']!;
                final total = snapshot.data!['total']!;
                final progreso = completados / total;

                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progreso del Flete',
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            '$completados/$total',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progreso,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                );
              },
            ),

            const Divider(),

            // Lista de checkpoints
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Puntos de Control',
                style: theme.textTheme.titleMedium,
              ),
            ),

            ...CheckpointService.checkpointTypes.map((checkpointType) {
              return StreamBuilder<Checkpoint?>(
                stream: _checkpointService.getCheckpoint(
                  widget.flete.id!,
                  checkpointType['id'] as String,
                ),
                builder: (context, snapshot) {
                  final checkpoint = snapshot.data;
                  final completado = checkpoint?.completado ?? false;

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(
                        _getIconData(checkpointType['icon'] as String),
                        color: completado ? Colors.green : Colors.grey,
                        size: 32,
                      ),
                      title: Text(
                        checkpointType['titulo'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: completado ? Colors.green : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(checkpointType['descripcion'] as String),
                          if (completado && checkpoint != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Completado: ${_formatDate(checkpoint.timestamp)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                              ),
                            ),
                            if (checkpoint.gpsLink != null && checkpoint.gpsLink!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () {
                                  // TODO: Abrir link en navegador
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('GPS: ${checkpoint.gpsLink}')),
                                  );
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 14, color: Colors.blue),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Ver ubicación en tiempo real',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                      trailing: completado
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : ElevatedButton.icon(
                              onPressed: () => _subirCheckpoint(checkpointType),
                              icon: const Icon(Icons.camera_alt, size: 16),
                              label: const Text('Subir'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.secondary,
                                foregroundColor: theme.colorScheme.onSecondary,
                              ),
                            ),
                    ),
                  );
                },
              );
            }),

            const SizedBox(height: 16),
            
            // MÓDULO 4: Botón de Detalle de Cobro (solo si está completado)
            if (widget.flete.estado == 'completado') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const Divider(thickness: 2),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade50,
                            Colors.green.shade100,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.shade300, width: 2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade600,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '¡FLETE COMPLETADO!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Ver detalle de cobro final',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetalleCobroPage(flete: widget.flete),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.receipt_long, size: 24),
                              label: const Text(
                                'VER DETALLE DE COBRO',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'local_shipping':
        return Icons.local_shipping;
      case 'location_on':
        return Icons.location_on;
      case 'place':
        return Icons.place;
      case 'exit_to_app':
        return Icons.exit_to_app;
      case 'check_circle':
        return Icons.check_circle;
      default:
        return Icons.fiber_manual_record;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildInfoRow(String label, String value, {bool bold = false, bool multiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: bold ? Colors.black87 : Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
