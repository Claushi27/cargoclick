import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cargoclick/services/auth_service.dart';
import 'package:cargoclick/services/flete_service.dart';
import 'package:cargoclick/models/flete.dart';
import 'package:cargoclick/screens/flete_detail_page.dart';
import 'package:cargoclick/widgets/recorrido_chofer_card.dart';

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
          
          // Separar fletes activos de completados
          final fletesActivos = fletes.where((f) => 
            f.estado == 'asignado' || f.estado == 'en_proceso'
          ).toList();
          final fletesCompletados = fletes.where((f) => 
            f.estado == 'completado'
          ).toList();
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Fletes activos con card optimizado
              if (fletesActivos.isNotEmpty) ...[
                Text(
                  'FLETES ACTIVOS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                ...fletesActivos.map((flete) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: RecorridoChoferCard(
                    flete: flete,
                    onVerDetalles: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FleteDetailPage(
                            flete: flete,
                            choferId: widget.choferId,
                          ),
                        ),
                      );
                    },
                  ),
                )).toList(),
              ],
              
              // Fletes completados (listado simple)
              if (fletesCompletados.isNotEmpty) ...[
                if (fletesActivos.isNotEmpty) const SizedBox(height: 24),
                Text(
                  'FLETES COMPLETADOS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                ...fletesCompletados.map((f) => _buildFleteCompletadoCard(context, f)).toList(),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildFleteCompletadoCard(BuildContext context, Flete flete) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FleteDetailPage(
                flete: flete,
                choferId: widget.choferId,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CTN ${flete.numeroContenedor}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${flete.origen} → ${flete.destino}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
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
