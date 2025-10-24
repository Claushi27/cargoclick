import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cargoclick/services/auth_service.dart';
import 'package:cargoclick/services/flete_service.dart';
import 'package:cargoclick/models/flete.dart';
import 'package:cargoclick/screens/flete_detail_page.dart';

class MisRecorridosPage extends StatefulWidget {
  final String choferId;
  const MisRecorridosPage({super.key, required this.choferId});

  @override
  State<MisRecorridosPage> createState() => _MisRecorridosPageState();
}

class _MisRecorridosPageState extends State<MisRecorridosPage> {
  final _fleteService = FleteService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Recorridos'),
      ),
      body: StreamBuilder<List<Flete>>(
        stream: _fleteService.getFletesChoferAsignado(widget.choferId),
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
                  Icon(Icons.route_outlined,
                      size: 80,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.3)),
                  const SizedBox(height: 8),
                  const Text('No tienes recorridos activos.'),
                  const SizedBox(height: 4),
                  Text(
                    'Los fletes asignados por tu transportista aparecerán aquí',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
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
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FleteDetailPage(
                          flete: f,
                          choferId: widget.choferId,
                        ),
                      ),
                    );
                  },
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getEstadoColor(f.estado)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getEstadoTexto(f.estado),
                                style: TextStyle(color: _getEstadoColor(f.estado)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Contenedor: ${f.numeroContenedor}'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.scale_outlined, size: 16),
                            const SizedBox(width: 4),
                            Text('${f.peso} kg'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FleteDetailPage(
                                        flete: f,
                                        choferId: widget.choferId,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('Ver Detalles y Subir Fotos'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'asignado':
      case 'en_proceso':
        return Colors.blue;
      case 'completado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getEstadoTexto(String estado) {
    switch (estado) {
      case 'asignado':
        return 'Asignado';
      case 'en_proceso':
        return 'En Progreso';
      case 'completado':
        return 'Completado';
      default:
        return estado;
    }
  }
}
