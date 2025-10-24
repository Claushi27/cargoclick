import 'package:flutter/material.dart';
import 'package:cargoclick/models/flete.dart';
import 'package:cargoclick/models/checkpoint.dart';
import 'package:cargoclick/services/checkpoint_service.dart';
import 'package:url_launcher/url_launcher.dart';

class FletesClienteDetallePage extends StatefulWidget {
  final Flete flete;

  const FletesClienteDetallePage({
    super.key,
    required this.flete,
  });

  @override
  State<FletesClienteDetallePage> createState() => _FletesClienteDetallePageState();
}

class _FletesClienteDetallePageState extends State<FletesClienteDetallePage> {
  final _checkpointService = CheckpointService();

  Future<void> _abrirLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el link: $url')),
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
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getEstadoColor(widget.flete.estado).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getEstadoTexto(widget.flete.estado),
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                            '$completados/$total checkpoints',
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

            // Lista de checkpoints con fotos
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Puntos de Control',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            StreamBuilder<List<Checkpoint>>(
              stream: _checkpointService.getCheckpoints(widget.flete.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ));
                }

                final checkpoints = snapshot.data ?? [];
                
                if (checkpoints.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Text('El chofer aún no ha subido checkpoints'),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: CheckpointService.checkpointTypes.length,
                  itemBuilder: (context, index) {
                    final checkpointType = CheckpointService.checkpointTypes[index];
                    final tipo = checkpointType['id'] as String;
                    
                    // Buscar si existe este checkpoint
                    final checkpoint = checkpoints.where((c) => c.tipo == tipo).firstOrNull;
                    final completado = checkpoint != null;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
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
                        subtitle: completado
                            ? Text(
                                'Completado: ${_formatDate(checkpoint.timestamp)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                ),
                              )
                            : Text(
                                checkpointType['descripcion'] as String,
                                style: const TextStyle(fontSize: 12),
                              ),
                        trailing: completado
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : const Icon(Icons.pending, color: Colors.grey),
                        children: completado
                            ? [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (checkpoint.notas != null && checkpoint.notas!.isNotEmpty) ...[
                                        Text(
                                          'Nota:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(checkpoint.notas!),
                                        const SizedBox(height: 12),
                                      ],
                                      if (checkpoint.gpsLink != null && checkpoint.gpsLink!.isNotEmpty) ...[
                                        ElevatedButton.icon(
                                          onPressed: () => _abrirLink(checkpoint.gpsLink!),
                                          icon: const Icon(Icons.location_on, size: 18),
                                          label: const Text('Ver ubicación en tiempo real'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      if (checkpoint.fotos.isNotEmpty) ...[
                                        Text(
                                          'Fotos (${checkpoint.fotos.length}):',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        GridView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 8,
                                            mainAxisSpacing: 8,
                                          ),
                                          itemCount: checkpoint.fotos.length,
                                          itemBuilder: (context, fotoIndex) {
                                            final foto = checkpoint.fotos[fotoIndex];
                                            return GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => Dialog(
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Image.network(foto.url, fit: BoxFit.contain),
                                                        Padding(
                                                          padding: const EdgeInsets.all(12.0),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text('Checkpoint: ${checkpointType['titulo']}'),
                                                              Text('Fecha: ${_formatDate(foto.createdAt)}'),
                                                            ],
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context),
                                                          child: const Text('Cerrar'),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.network(
                                                  foto.url,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context, child, progress) {
                                                    if (progress == null) return child;
                                                    return const Center(child: CircularProgressIndicator());
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ]
                            : [],
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 20),
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

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'disponible':
        return Colors.blue;
      case 'solicitado':
        return Colors.orange;
      case 'asignado':
        return Colors.green;
      case 'en_proceso':
        return Colors.blue;
      case 'completado':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getEstadoTexto(String estado) {
    switch (estado) {
      case 'disponible':
        return 'Disponible';
      case 'solicitado':
        return 'Solicitado';
      case 'asignado':
        return 'Asignado';
      case 'en_proceso':
        return 'En Proceso';
      case 'completado':
        return 'Completado';
      default:
        return estado;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
