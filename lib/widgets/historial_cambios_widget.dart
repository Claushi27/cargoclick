import 'package:flutter/material.dart';
import 'package:cargoclick/services/flete_service.dart';
import 'package:cargoclick/models/cambio_asignacion.dart';
import 'package:intl/intl.dart';

class HistorialCambiosWidget extends StatelessWidget {
  final String fleteId;
  final bool esCliente;

  const HistorialCambiosWidget({
    super.key,
    required this.fleteId,
    this.esCliente = true,
  });

  @override
  Widget build(BuildContext context) {
    final fleteService = FleteService();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade700, Colors.orange.shade500],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.history, color: Colors.white),
                const SizedBox(width: 12),
                const Text(
                  'Historial de Cambios',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Lista de cambios
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: fleteService.getHistorialCambios(fleteId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final cambios = snapshot.data ?? [];

              if (cambios.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No ha habido cambios en la asignación',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: cambios.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final cambioData = cambios[index];
                  final cambio = CambioAsignacion.fromJson(
                    cambioData,
                    docId: cambioData['id'],
                  );

                  return _CambioCard(
                    cambio: cambio,
                    esCliente: esCliente,
                    fleteId: fleteId,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CambioCard extends StatelessWidget {
  final CambioAsignacion cambio;
  final bool esCliente;
  final String fleteId;

  const _CambioCard({
    required this.cambio,
    required this.esCliente,
    required this.fleteId,
  });

  Color _getColorEstado() {
    switch (cambio.estado) {
      case 'activo':
        return Colors.green;
      case 'rechazado_cliente':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconoEstado() {
    switch (cambio.estado) {
      case 'activo':
        return Icons.check_circle;
      case 'rechazado_cliente':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getTextoEstado() {
    switch (cambio.estado) {
      case 'activo':
        return 'Activo';
      case 'rechazado_cliente':
        return 'Rechazado';
      default:
        return cambio.estado;
    }
  }

  Future<void> _rechazarCambio(BuildContext context) async {
    final motivo = await showDialog<String>(
      context: context,
      builder: (context) => _RechazarDialog(),
    );

    if (motivo == null || motivo.isEmpty) return;

    // Mostrar loading
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final fleteService = FleteService();
      
      await fleteService.rechazarCambioAsignacion(
        cambioId: cambio.id!,
        fleteId: fleteId,
        motivo: motivo,
      );

      if (!context.mounted) return;
      
      Navigator.pop(context); // Cerrar loading

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Cambio rechazado. Se ha revertido a la asignación anterior.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      Navigator.pop(context); // Cerrar loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con fecha y estado
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(cambio.fechaCambio),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getColorEstado().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getIconoEstado(),
                        size: 14,
                        color: _getColorEstado(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTextoEstado(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getColorEstado(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Razón
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cambio.razon,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Cambio de Chofer
                _CambioRow(
                  titulo: 'Chofer',
                  icono: Icons.person,
                  anterior: cambio.choferAnteriorNombre,
                  nuevo: cambio.choferNuevoNombre,
                ),
                const SizedBox(height: 12),

                // Cambio de Camión
                _CambioRow(
                  titulo: 'Camión',
                  icono: Icons.local_shipping,
                  anterior: cambio.camionAnteriorPatente,
                  nuevo: cambio.camionNuevoPatente,
                ),

                // Información adicional para cliente
                if (esCliente && cambio.estado == 'activo') ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  if (cambio.puedeSerRechazado) ...[
                    // Tiempo restante
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Tiempo para rechazar: ${cambio.tiempoRestanteParaRechazar}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Botón rechazar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _rechazarCambio(context),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Rechazar Cambio'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_clock, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          const Text(
                            'Plazo expirado',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],

                // Si fue rechazado, mostrar motivo
                if (cambio.estado == 'rechazado_cliente' && cambio.motivoRechazo != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.block, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Motivo del rechazo:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cambio.motivoRechazo!,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CambioRow extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final String anterior;
  final String nuevo;

  const _CambioRow({
    required this.titulo,
    required this.icono,
    required this.anterior,
    required this.nuevo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, size: 18, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ANTERIOR',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      anterior,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.arrow_forward, size: 20),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NUEVO',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nuevo,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RechazarDialog extends StatefulWidget {
  @override
  State<_RechazarDialog> createState() => _RechazarDialogState();
}

class _RechazarDialogState extends State<_RechazarDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 12),
          Text('Rechazar Cambio'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Está seguro de rechazar este cambio?\n\n'
              'El flete volverá al chofer y camión anterior.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Motivo del rechazo:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ej: El chofer no tiene la experiencia requerida',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Debe indicar el motivo';
                }
                if (value.trim().length < 10) {
                  return 'Mínimo 10 caracteres';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Confirmar Rechazo'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
