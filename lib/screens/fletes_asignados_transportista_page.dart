import 'package:flutter/material.dart';
import 'package:cargoclick/services/flete_service.dart';
import 'package:cargoclick/services/auth_service.dart';
import 'package:cargoclick/services/rating_service.dart';
import 'package:cargoclick/models/flete.dart';
import 'package:cargoclick/widgets/flete_card_transportista.dart';
import 'package:cargoclick/widgets/progress_timeline.dart';
import 'package:cargoclick/widgets/contact_card.dart';
import 'package:cargoclick/widgets/instrucciones_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class FletesAsignadosTransportistaPage extends StatefulWidget {
  const FletesAsignadosTransportistaPage({super.key});

  @override
  State<FletesAsignadosTransportistaPage> createState() => _FletesAsignadosTransportistaPageState();
}

class _FletesAsignadosTransportistaPageState extends State<FletesAsignadosTransportistaPage> {
  final _fleteService = FleteService();
  final _authService = AuthService();
  final _ratingService = RatingService();
  String? _transportistaId;

  @override
  void initState() {
    super.initState();
    _cargarTransportistaId();
  }

  Future<void> _cargarTransportistaId() async {
    final transportista = await _authService.getCurrentTransportista();
    if (mounted) {
      setState(() => _transportistaId = transportista?.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_transportistaId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Fletes Asignados'),
      ),
      body: StreamBuilder<List<Flete>>(
        stream: _fleteService.getFletesAsignadosTransportista(_transportistaId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final fletes = snapshot.data ?? [];

          if (fletes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay fletes asignados',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los fletes que aceptes aparecerán aquí',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
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
              return _buildFleteAsignadoCard(fletes[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildFleteAsignadoCard(Flete flete) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _mostrarDetallesFlete(flete),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estado
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getColorPorEstado(flete.estado),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconoPorEstado(flete.estado),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CTN ${flete.numeroContenedor}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getColorPorEstado(flete.estado).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getTextoEstado(flete.estado),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getColorPorEstado(flete.estado),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${NumberFormat('#,###', 'es_CL').format(flete.tarifa)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      Text(
                        'CLP',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Línea de tiempo de estados
              ProgressTimeline(
                estados: ['asignado', 'en_proceso', 'completado'],
                estadoActual: flete.estado,
              ),
              
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              
              // Ruta
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.trip_origin, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        flete.origen,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: Colors.blue.shade600, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        flete.destino,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Icon(Icons.location_on, color: Colors.red.shade700, size: 20),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Info del cliente con rating
              FutureBuilder<Map<String, dynamic>>(
                future: _ratingService.getInfoCliente(flete.clienteId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData) return const SizedBox.shrink();

                  final clienteInfo = snapshot.data!;
                  final totalFletes = clienteInfo['totalFletes'] as int;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.grey[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                clienteInfo['nombre'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '$totalFletes flete${totalFletes != 1 ? 's' : ''} publicado${totalFletes != 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 12),
              
              // Info chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    icon: Icons.scale,
                    label: '${NumberFormat('#,###', 'es_CL').format(flete.peso)} kg',
                    color: Colors.orange,
                  ),
                  if (flete.fechaAsignacion != null)
                    _buildInfoChip(
                      icon: Icons.assignment,
                      label: 'Asignado ${_formatearFechaRelativa(flete.fechaAsignacion!)}',
                      color: Colors.purple,
                    ),
                  if (flete.fechaHoraCarga != null)
                    _buildInfoChip(
                      icon: Icons.schedule,
                      label: 'Cargue: ${DateFormat('dd/MM HH:mm').format(flete.fechaHoraCarga!)}',
                      color: Colors.blue,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _darkenColor(color, 0.2)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _darkenColor(color, 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Color _darkenColor(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color _getColorPorEstado(String estado) {
    switch (estado) {
      case 'asignado':
        return Colors.blue;
      case 'en_proceso':
        return Colors.orange;
      case 'completado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconoPorEstado(String estado) {
    switch (estado) {
      case 'asignado':
        return Icons.assignment_turned_in;
      case 'en_proceso':
        return Icons.local_shipping;
      case 'completado':
        return Icons.check_circle;
      default:
        return Icons.inventory_2;
    }
  }

  String _getTextoEstado(String estado) {
    switch (estado) {
      case 'asignado':
        return 'ASIGNADO';
      case 'en_proceso':
        return 'EN PROCESO';
      case 'completado':
        return 'COMPLETADO';
      default:
        return estado.toUpperCase();
    }
  }

  String _formatearFechaRelativa(DateTime fecha) {
    final diferencia = DateTime.now().difference(fecha);
    
    if (diferencia.inDays == 0) {
      if (diferencia.inHours == 0) {
        return 'hace ${diferencia.inMinutes}m';
      }
      return 'hace ${diferencia.inHours}h';
    } else if (diferencia.inDays == 1) {
      return 'ayer';
    } else if (diferencia.inDays < 7) {
      return 'hace ${diferencia.inDays}d';
    }
    
    return DateFormat('dd/MM/yy').format(fecha);
  }

  void _mostrarDetallesFlete(Flete flete) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Contenido
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Header con timeline
                    Text(
                      'CTN ${flete.numeroContenedor}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Línea de tiempo
                    ProgressTimeline(
                      estados: ['asignado', 'en_proceso', 'completado'],
                      estadoActual: flete.estado,
                      size: 28,
                    ),
                    
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    // Información del Cliente
                    FutureBuilder<Map<String, dynamic>>(
                      future: _ratingService.getInfoCliente(flete.clienteId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        if (!snapshot.hasData) {
                          return const SizedBox.shrink();
                        }
                        
                        final clienteInfo = snapshot.data!;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'INFORMACIÓN DEL CLIENTE',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ContactCard(
                              nombre: clienteInfo['nombre'],
                              empresa: clienteInfo['empresa'],
                              telefono: clienteInfo['telefono'],
                              email: clienteInfo['email'],
                            ),
                          ],
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Detalles del flete
                    _buildSeccion('DETALLES DEL FLETE', [
                      _buildDetalle('Tipo Contenedor', flete.tipoContenedor),
                      _buildDetalle('Número Contenedor', flete.numeroContenedor),
                      _buildDetalle('Peso Total', '${NumberFormat('#,###', 'es_CL').format(flete.peso)} kg'),
                      _buildDetalle('Tarifa', '\$${NumberFormat('#,###', 'es_CL').format(flete.tarifa)} CLP'),
                    ]),
                    
                    const SizedBox(height: 16),
                    
                    // Ruta
                    _buildSeccion('RUTA', [
                      _buildDetalle('Origen', flete.origen),
                      if (flete.puertoOrigen != null)
                        _buildDetalle('Puerto Origen', flete.puertoOrigen!),
                      _buildDetalle('Destino', flete.destino),
                      if (flete.direccionDestino != null)
                        _buildDetalle('Dirección Destino', flete.direccionDestino!),
                      if (flete.fechaHoraCarga != null)
                        _buildDetalle(
                          'Fecha/Hora Cargue',
                          DateFormat('dd/MM/yyyy HH:mm').format(flete.fechaHoraCarga!),
                        ),
                    ]),
                    
                    const SizedBox(height: 16),
                    
                    // Instrucciones especiales
                    if (flete.requisitosEspeciales != null || 
                        flete.serviciosAdicionales != null ||
                        flete.devolucionCtnVacio != null) ...[
                      Text(
                        'INSTRUCCIONES IMPORTANTES',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InstruccionesCard(
                        instrucciones: [
                          if (flete.requisitosEspeciales != null)
                            flete.requisitosEspeciales!,
                          if (flete.serviciosAdicionales != null)
                            'Servicios: ${flete.serviciosAdicionales!}',
                          if (flete.devolucionCtnVacio != null)
                            'Devolución: ${flete.devolucionCtnVacio!}',
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Asignación actual
                    _buildSeccion('ASIGNACIÓN ACTUAL', [
                      if (flete.choferAsignado != null)
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(flete.choferAsignado)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data!.exists) {
                              final choferData = snapshot.data!.data() as Map<String, dynamic>;
                              final choferNombre = choferData['display_name'] ?? 'Sin nombre';
                              return _buildDetalle('Chofer Asignado', choferNombre);
                            }
                            return _buildDetalle('Chofer Asignado', 'ID: ${flete.choferAsignado}');
                          },
                        ),
                      if (flete.camionAsignado != null)
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('camiones')
                              .doc(flete.camionAsignado)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data!.exists) {
                              final camionData = snapshot.data!.data() as Map<String, dynamic>;
                              final patente = camionData['patente'] ?? 'Sin patente';
                              final tipo = camionData['tipo'] ?? '';
                              return _buildDetalle('Camión Asignado', '$patente${tipo.isNotEmpty ? " ($tipo)" : ""}');
                            }
                            return _buildDetalle('Camión Asignado', 'ID: ${flete.camionAsignado}');
                          },
                        ),
                      if (flete.fechaAsignacion != null)
                        _buildDetalle('Fecha Asignación', 
                          DateFormat('dd/MM/yyyy HH:mm').format(flete.fechaAsignacion!)),
                    ]),
                    
                    const SizedBox(height: 24),
                    
                    // Botones de acción
                    if (flete.direccionDestino != null) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _abrirMapa(flete.direccionDestino!),
                          icon: const Icon(Icons.map),
                          label: const Text('Abrir en Google Maps'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
              
              // Botón cerrar
              Container(
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cerrar'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _abrirMapa(String direccion) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(direccion)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildSeccion(String titulo, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildDetalle(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
