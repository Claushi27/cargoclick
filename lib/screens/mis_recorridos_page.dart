import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cargoclick/services/auth_service.dart';
import 'package:cargoclick/services/flete_service.dart';
import 'package:cargoclick/services/photo_service.dart';
import 'package:cargoclick/models/flete.dart';

class MisRecorridosPage extends StatefulWidget {
  final String choferId;
  const MisRecorridosPage({super.key, required this.choferId});

  @override
  State<MisRecorridosPage> createState() => _MisRecorridosPageState();
}

class _MisRecorridosPageState extends State<MisRecorridosPage> {
  final _fleteService = FleteService();
  final _photoService = PhotoService();
  final _picker = ImagePicker();

  Future<void> _subirFoto(BuildContext context, Flete flete) async {
    // Elegir fuente
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

    XFile? picked;
    try {
      picked = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 2400);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error abriendo cámara/galería: $e')));
      return;
    }
    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    final notaController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar subida de foto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(bytes, height: 180, fit: BoxFit.cover),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notaController,
                decoration: const InputDecoration(
                  labelText: 'Nota (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLength: 120,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Subir')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _photoService.uploadFletePhoto(
        fleteId: flete.id!,
        choferId: widget.choferId,
        bytes: bytes,
        contentType: 'image/jpeg',
        nota: notaController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto subida')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir foto: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Recorridos'),
      ),
      body: StreamBuilder<List<Flete>>(
        stream: _fleteService.getFletesAsignadosChofer(widget.choferId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final fletes = snapshot.data ?? [];
          if (fletes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.route_outlined, size: 80, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                  const SizedBox(height: 8),
                  const Text('No tienes recorridos activos.'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: fletes.length,
            itemBuilder: (context, index) {
              final f = fletes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${f.origen} → ${f.destino}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('En Progreso', style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Contenedor: ${f.numeroContenedor}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.scale_outlined, size: 16),
                          const SizedBox(width: 4),
                          Text('${f.peso} kg'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _subirFoto(context, f),
                          icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                          label: const Text('Subir Foto'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
