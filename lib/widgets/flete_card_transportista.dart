import 'package:flutter/material.dart';
import 'package:cargoclick/models/flete.dart';
import 'package:intl/intl.dart';

class FleteCardTransportista extends StatelessWidget {
  final Flete flete;
  final VoidCallback onTap;
  final VoidCallback onAceptar;
  final double? tarifaMinimaTransportista; // NUEVO

  const FleteCardTransportista({
    super.key,
    required this.flete,
    required this.onTap,
    required this.onAceptar,
    this.tarifaMinimaTransportista,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== HEADER: CONTENEDOR Y TARIFA ==========
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconoPorTipoContenedor(flete.tipoContenedor),
                      color: Theme.of(context).colorScheme.primary,
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
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _buildBadge(
                              context,
                              flete.tipoContenedor,
                              _getColorPorTipoContenedor(flete.tipoContenedor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${NumberFormat('#,###', 'es_CL').format(flete.tarifa)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                      // Badge de compatibilidad con tarifa
                      if (tarifaMinimaTransportista != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: flete.tarifa >= tarifaMinimaTransportista!
                                ? Colors.green.withOpacity(0.2)
                                : Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                flete.tarifa >= tarifaMinimaTransportista!
                                    ? Icons.check_circle
                                    : Icons.warning,
                                size: 12,
                                color: flete.tarifa >= tarifaMinimaTransportista!
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                flete.tarifa >= tarifaMinimaTransportista!
                                    ? 'Compatible'
                                    : 'Bajo mínimo',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: flete.tarifa >= tarifaMinimaTransportista!
                                      ? Colors.green[700]
                                      : Colors.orange[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              
              // ========== RUTA ==========
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade50,
                      Colors.blue.shade100.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trip_origin, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Origen',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                flete.origen,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              if (flete.puertoOrigen != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  flete.puertoOrigen!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward, color: Colors.blue.shade600, size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Destino',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                flete.destino,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.blue.shade900,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.location_on, color: Colors.red.shade700, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // ========== INFO CHIPS ==========
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    context,
                    icon: Icons.scale,
                    label: _formatearPeso(),
                    color: Colors.orange,
                  ),
                  if (flete.fechaHoraCarga != null)
                    _buildInfoChip(
                      context,
                      icon: Icons.schedule,
                      label: DateFormat('dd/MM/yy HH:mm').format(flete.fechaHoraCarga!),
                      color: Colors.purple,
                    ),
                  _buildInfoChip(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Publicado ${_formatearFechaRelativa(flete.fechaPublicacion)}',
                    color: Colors.grey,
                  ),
                ],
              ),
              
              // ========== INFO ADICIONAL (SI EXISTE) ==========
              if (_tieneInfoAdicional()) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.amber.shade900),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _construirTextoInfoAdicional(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // ========== BOTÓN ACEPTAR ==========
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onAceptar,
                  icon: const Icon(Icons.check_circle_outline, size: 22),
                  label: const Text(
                    'Aceptar y Asignar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconoPorTipoContenedor(String tipo) {
    if (tipo.contains('reefer') || tipo.toLowerCase().contains('refriger')) {
      return Icons.ac_unit;
    } else if (tipo.contains('OT') || tipo.toLowerCase().contains('open')) {
      return Icons.inbox;
    } else if (tipo.contains('HC') || tipo.toLowerCase().contains('high')) {
      return Icons.height;
    }
    return Icons.inventory_2;
  }

  Color _getColorPorTipoContenedor(String tipo) {
    if (tipo.contains('reefer') || tipo.toLowerCase().contains('refriger')) {
      return Colors.cyan;
    } else if (tipo.contains('OT') || tipo.toLowerCase().contains('open')) {
      return Colors.orange;
    } else if (tipo.contains('HC') || tipo.toLowerCase().contains('high')) {
      return Colors.purple;
    }
    return Colors.blue;
  }

  Widget _buildBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _darkenColor(color, 0.3),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, {
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

  String _formatearPeso() {
    if (flete.pesoCargaNeta != null && flete.pesoTara != null) {
      return '${NumberFormat('#,###', 'es_CL').format(flete.peso)} kg';
    }
    return '${NumberFormat('#,###', 'es_CL').format(flete.peso)} kg';
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

  bool _tieneInfoAdicional() {
    return flete.requisitosEspeciales != null ||
           flete.serviciosAdicionales != null ||
           flete.devolucionCtnVacio != null;
  }

  String _construirTextoInfoAdicional() {
    final List<String> infos = [];
    
    if (flete.requisitosEspeciales != null && flete.requisitosEspeciales!.isNotEmpty) {
      infos.add('Requisitos especiales');
    }
    if (flete.serviciosAdicionales != null && flete.serviciosAdicionales!.isNotEmpty) {
      infos.add('Servicios adicionales');
    }
    if (flete.devolucionCtnVacio != null && flete.devolucionCtnVacio!.isNotEmpty) {
      infos.add('Devolución CTN');
    }
    
    if (infos.isEmpty) return '';
    
    return 'Incluye: ${infos.join(', ')}';
  }
}
