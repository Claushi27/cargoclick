import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cargoclick/models/flete.dart';
import 'package:cargoclick/models/checkpoint.dart';
import 'package:cargoclick/services/checkpoint_service.dart';

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

    // Mostrar diálogo para elegir fuente
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

    // Recolectar fotos
    final fotos = <Uint8List>[];
    for (var i = 0; i < requiereFotos; i++) {
      try {
        final picked = await _picker.pickImage(
          source: source,
          imageQuality: 85,
          maxWidth: 2400,
        );
        if (picked == null) {
          if (i == 0) return; // Si cancela la primera, salir
          break; // Si cancela una subsecuente, continuar con las que tiene
        }
        final bytes = await picked.readAsBytes();
        fotos.add(bytes);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar foto: $e')),
        );
        return;
      }
    }

    if (fotos.isEmpty) return;

    // Mostrar preview y confirmar
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
              ...fotos.asMap().entries.map((entry) {
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
                        child: Image.memory(
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

    // Subir checkpoint
    try {
      await _checkpointService.subirCheckpoint(
        fleteId: widget.flete.id!,
        choferId: widget.choferId,
        tipo: tipo,
        fotos: fotos,
        notas: notaController.text.trim().isEmpty
            ? null
            : notaController.text.trim(),
        ubicacion: null, // TODO: Capturar GPS automático
        gpsLink: gpsLinkController.text.trim().isEmpty
            ? null
            : gpsLinkController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checkpoint subido exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir checkpoint: $e'),
          backgroundColor: Colors.red,
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
}
