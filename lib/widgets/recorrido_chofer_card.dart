import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cargoclick/models/flete.dart';
import 'package:cargoclick/widgets/progress_timeline.dart';
import 'package:cargoclick/widgets/instrucciones_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Widget optimizado para choferes - Card de recorrido actual
class RecorridoChoferCard extends StatelessWidget {
  final Flete flete;
  final VoidCallback? onVerDetalles;

  const RecorridoChoferCard({
    Key? key,
    required this.flete,
    this.onVerDetalles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header destacado
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getColorPorEstado(flete.estado),
                  _getColorPorEstado(flete.estado).withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_shipping, color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🚛 TU FLETE ACTUAL',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'CTN ${flete.numeroContenedor}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${flete.tipoContenedor} - ${NumberFormat('#,###', 'es_CL').format(flete.peso)} kg',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline de estados
                ProgressTimeline(
                  estados: ['asignado', 'en_proceso', 'completado'],
                  estadoActual: flete.estado,
                  size: 28,
                ),
                
                const SizedBox(height: 24),
                
                // MÓDULO 4: Sección SECUENCIA DE ENTREGA
                if (flete.fechaHoraCarga != null || flete.puertoOrigen != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade300, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.schedule, color: Colors.amber.shade900, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              '📋 SECUENCIA DE ENTREGA',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        if (flete.fechaHoraCarga != null) ...[
                          _buildInfoRow(
                            icon: Icons.access_time,
                            label: 'Hora de Retiro',
                            value: DateFormat('HH:mm').format(flete.fechaHoraCarga!) + ' hs',
                            color: Colors.amber.shade800,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.calendar_today,
                            label: 'Fecha de Carga',
                            value: DateFormat('EEEE d \'de\' MMMM', 'es_ES').format(flete.fechaHoraCarga!),
                            color: Colors.amber.shade800,
                          ),
                        ],
                        
                        if (flete.puertoOrigen != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.anchor,
                            label: 'Puerto de Retiro',
                            value: flete.puertoOrigen!,
                            color: Colors.amber.shade800,
                          ),
                        ],
                        
                        // Badge de urgencia si está próximo (<2 horas)
                        if (flete.fechaHoraCarga != null &&
                            flete.fechaHoraCarga!.difference(DateTime.now()).inHours < 2 &&
                            flete.fechaHoraCarga!.isAfter(DateTime.now())) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade400, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.red.shade800, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '¡URGENTE! Retiro en menos de 2 horas',
                                    style: TextStyle(
                                      color: Colors.red.shade900,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
                
                // Destino destacado
                _buildSeccionDestacada(
                  context,
                  icon: Icons.location_on,
                  titulo: '📍 DESTINO',
                  contenido: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flete.destino,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (flete.direccionDestino != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          flete.direccionDestino!,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Contacto del cliente
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(flete.clienteId)
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(
                        height: 60,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final clienteData = snapshot.data!.data() as Map<String, dynamic>?;
                    if (clienteData == null) return const SizedBox.shrink();

                    final nombre = clienteData['display_name'] ?? 'Cliente';
                    final empresa = clienteData['empresa'] ?? '';
                    final telefono = clienteData['phone_number'] ?? '';

                    return _buildSeccionDestacada(
                      context,
                      icon: Icons.person,
                      titulo: '📞 CONTACTO CLIENTE',
                      contenido: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (empresa.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              empresa,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                          if (telefono.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _llamar(telefono),
                                icon: const Icon(Icons.phone, size: 24),
                                label: Text(
                                  telefono,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Instrucciones importantes
                if (flete.requisitosEspeciales != null ||
                    flete.serviciosAdicionales != null ||
                    flete.fechaHoraCarga != null) ...[
                  InstruccionesCard(
                    instrucciones: [
                      if (flete.fechaHoraCarga != null)
                        'Cargue: ${DateFormat('dd/MM/yyyy HH:mm').format(flete.fechaHoraCarga!)}',
                      if (flete.requisitosEspeciales != null)
                        flete.requisitosEspeciales!,
                      if (flete.serviciosAdicionales != null)
                        'Servicios: ${flete.serviciosAdicionales!}',
                      if (flete.devolucionCtnVacio != null)
                        'Devolución: ${flete.devolucionCtnVacio!}',
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
                
                // NUEVO: Dropdown con TODA la información del flete
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 16),
                    leading: Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    title: Text(
                      '📋 Ver Información Completa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    subtitle: const Text(
                      'Toca para expandir todos los detalles',
                      style: TextStyle(fontSize: 13),
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetalleRow('📦 Número Contenedor', flete.numeroContenedor, bold: true),
                            const Divider(height: 24),
                            _buildDetalleRow('📐 Tipo Contenedor', flete.tipoContenedor),
                            _buildDetalleRow('⚖️ Peso Total', '${NumberFormat('#,###', 'es_CL').format(flete.peso)} kg'),
                            if (flete.pesoCargaNeta != null)
                              _buildDetalleRow('  📦 Carga Neta', '${NumberFormat('#,###', 'es_CL').format(flete.pesoCargaNeta)} kg'),
                            if (flete.pesoTara != null)
                              _buildDetalleRow('  ⚖️ Tara', '${NumberFormat('#,###', 'es_CL').format(flete.pesoTara)} kg'),
                            const Divider(height: 24),
                            _buildDetalleRow('🏭 Origen', flete.origen, bold: true),
                            if (flete.puertoOrigen != null)
                              _buildDetalleRow('  ⚓ Puerto Origen', flete.puertoOrigen!),
                            if (flete.rutIngresoSti != null)
                              _buildDetalleRow('  🆔 RUT STI', flete.rutIngresoSti!),
                            if (flete.rutIngresoPc != null)
                              _buildDetalleRow('  🆔 RUT PC', flete.rutIngresoPc!),
                            const Divider(height: 24),
                            _buildDetalleRow('🎯 Destino', flete.destino, bold: true),
                            if (flete.direccionDestino != null)
                              _buildDetalleRow('  📍 Dirección Destino', flete.direccionDestino!),
                            const Divider(height: 24),
                            if (flete.fechaHoraCarga != null)
                              _buildDetalleRow('📅 Fecha y Hora Carga', 
                                DateFormat('dd/MM/yyyy HH:mm').format(flete.fechaHoraCarga!), 
                                bold: true),
                            _buildDetalleRow('💰 Tarifa', '\$${NumberFormat('#,###', 'es_CL').format(flete.tarifa)}', bold: true),
                            if (flete.tarifaBase != null)
                              _buildDetalleRow('💵 Tarifa Base', '\$${NumberFormat('#,###', 'es_CL').format(flete.tarifaBase)}'),
                            if (flete.isFueraDePerimetro)
                              _buildDetalleRow('📍 Fuera de Perímetro', 'SÍ', bold: true),
                            if (flete.valorAdicionalPerimetro != null)
                              _buildDetalleRow('💰 Valor Perímetro', '\$${NumberFormat('#,###', 'es_CL').format(flete.valorAdicionalPerimetro)}'),
                            if (flete.valorAdicionalSobrepeso != null)
                              _buildDetalleRow('⚠️ Valor Sobrepeso', '\$${NumberFormat('#,###', 'es_CL').format(flete.valorAdicionalSobrepeso)}'),
                            if (flete.tipoDeRampla != null)
                              _buildDetalleRow('🚛 Tipo Rampla', flete.tipoDeRampla!),
                            const Divider(height: 24),
                            if (flete.requisitosEspeciales != null) ...[
                              _buildDetalleRow('⚠️ Requisitos Especiales', flete.requisitosEspeciales!, multiline: true),
                              const SizedBox(height: 12),
                            ],
                            if (flete.serviciosAdicionales != null) ...[
                              _buildDetalleRow('➕ Servicios Adicionales', flete.serviciosAdicionales!, multiline: true),
                              const SizedBox(height: 12),
                            ],
                            if (flete.devolucionCtnVacio != null) ...[
                              _buildDetalleRow('↩️ Devolución Contenedor', flete.devolucionCtnVacio!, multiline: true),
                              const SizedBox(height: 12),
                            ],
                            const Divider(height: 24),
                            _buildDetalleRow('📊 Estado', _getNombreEstado(flete.estado), bold: true),
                            if (flete.fechaAsignacion != null)
                              _buildDetalleRow('📆 Fecha Asignación', 
                                DateFormat('dd/MM/yyyy HH:mm').format(flete.fechaAsignacion!)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Botones de acción
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onVerDetalles,
                        icon: const Icon(Icons.info_outline, size: 24),
                        label: const Text(
                          'Ver Instrucciones Completas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (flete.direccionDestino != null)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _abrirMapa(flete.direccionDestino!),
                          icon: const Icon(Icons.map, size: 24),
                          label: const Text(
                            'Abrir en Google Maps',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionDestacada(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required Widget contenido,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          contenido,
        ],
      ),
    );
  }

  Color _getColorPorEstado(String estado) {
    switch (estado) {
      case 'asignado':
        return Colors.blue.shade600;
      case 'en_proceso':
        return Colors.orange.shade600;
      case 'completado':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  // MÓDULO 4: Helper para mostrar info row en horarios
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _llamar(String telefono) async {
    final uri = Uri.parse('tel:$telefono');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _abrirMapa(String direccion) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(direccion)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // NUEVO: Helper para mostrar detalles en el dropdown
  Widget _buildDetalleRow(String label, String value, {bool bold = false, bool multiline = false}) {
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

  String _getNombreEstado(String estado) {
    switch (estado) {
      case 'asignado':
        return '🔵 Asignado';
      case 'en_proceso':
        return '🟠 En Proceso';
      case 'completado':
        return '🟢 Completado';
      default:
        return estado;
    }
  }
}
