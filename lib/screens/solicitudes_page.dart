import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cargoclick/services/solicitudes_service.dart';

class SolicitudesPage extends StatefulWidget {
  final String clienteId;
  const SolicitudesPage({super.key, required this.clienteId});

  @override
  State<SolicitudesPage> createState() => _SolicitudesPageState();
}

class _SolicitudesPageState extends State<SolicitudesPage> {
  final _solService = SolicitudesService();

  Future<void> _aprobar(String fleteId, String choferId) async {
    try {
      await _solService.aprobarSolicitud(fleteId: fleteId, choferId: choferId, clienteId: widget.clienteId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud aprobada')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _rechazar(String fleteId, String choferId) async {
    try {
      await _solService.rechazarSolicitud(fleteId: fleteId, choferId: choferId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud rechazada')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes de Choferes')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _solService.getSolicitudesCliente(widget.clienteId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No hay solicitudes pendientes'));
          }
          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final d = docs[index];
              final data = d.data();
              final fleteResumen = Map<String, dynamic>.from(data['flete_resumen'] ?? {});
              final choferResumen = Map<String, dynamic>.from(data['chofer_resumen'] ?? {});
              final fleteId = data['flete_id'] as String;
              final choferId = data['chofer_id'] as String;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Flete: ${fleteResumen['numero_contenedor'] ?? fleteId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Ruta: ${fleteResumen['origen'] ?? ''} → ${fleteResumen['destino'] ?? ''}'),
                      const SizedBox(height: 8),
                      Text('Chofer: ${choferResumen['nombre'] ?? choferResumen['uid'] ?? choferId}'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _aprobar(fleteId, choferId),
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text('Aprobar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () => _rechazar(fleteId, choferId),
                            icon: const Icon(Icons.close),
                            label: const Text('Rechazar'),
                          ),
                        ],
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
