import 'package:flutter/material.dart';
import 'package:cargoclick/models/flete.dart';

class FleteCard extends StatelessWidget {
  final Flete flete;
  final bool isCliente;
  final VoidCallback? onAceptar;

  const FleteCard({
    super.key,
    required this.flete,
    required this.isCliente,
    this.onAceptar,
  });

  @override
  Widget build(BuildContext context) {
    final isDisponible = flete.estado == 'disponible';
    final isSolicitado = flete.estado == 'solicitado';
    final isAsignado = flete.estado == 'asignado';
    final isEnProceso = flete.estado == 'en_proceso';
    final isCompletado = flete.estado == 'completado';
    
    // Determinar color y texto del badge de estado
    Color estadoColor;
    IconData estadoIcon;
    String estadoTexto;
    
    if (isCompletado) {
      estadoColor = Colors.purple;
      estadoIcon = Icons.check_circle;
      estadoTexto = 'Completado';
    } else if (isEnProceso) {
      estadoColor = Colors.blue;
      estadoIcon = Icons.local_shipping;
      estadoTexto = 'En Proceso';
    } else if (isAsignado) {
      estadoColor = Colors.green;
      estadoIcon = Icons.assignment_turned_in;
      estadoTexto = 'Asignado';
    } else if (isSolicitado) {
      estadoColor = Colors.orange;
      estadoIcon = Icons.pending;
      estadoTexto = 'Pendiente';
    } else {
      estadoColor = Colors.blue;
      estadoIcon = Icons.fiber_new;
      estadoTexto = 'Disponible';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    flete.tipoContenedor,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: estadoColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(estadoIcon, color: estadoColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        estadoTexto,
                        style: TextStyle(
                          color: estadoColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              flete.numeroContenedor,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Origen',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        flete.origen,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Destino',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        flete.destino,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.scale_outlined, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                const SizedBox(width: 4),
                Text(
                  '${flete.peso} kg',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            
            // NUEVO: Dropdown con información completa (VISTA CLIENTE)
            const SizedBox(height: 12),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ver todos los detalles',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetalleCliente('📦 Contenedor', flete.numeroContenedor, context),
                        _buildDetalleCliente('📐 Tipo', flete.tipoContenedor, context),
                        _buildDetalleCliente('⚖️ Peso', '${flete.peso} kg', context),
                        if (flete.pesoCargaNeta != null)
                          _buildDetalleCliente('  Carga Neta', '${flete.pesoCargaNeta} kg', context),
                        if (flete.pesoTara != null)
                          _buildDetalleCliente('  Tara', '${flete.pesoTara} kg', context),
                        const Divider(height: 16),
                        _buildDetalleCliente('🏭 Origen', flete.origen, context, bold: true),
                        if (flete.puertoOrigen != null)
                          _buildDetalleCliente('  ⚓ Puerto', flete.puertoOrigen!, context),
                        if (flete.rutIngresoSti != null)
                          _buildDetalleCliente('  RUT STI', flete.rutIngresoSti!, context),
                        if (flete.rutIngresoPc != null)
                          _buildDetalleCliente('  RUT PC', flete.rutIngresoPc!, context),
                        const Divider(height: 16),
                        _buildDetalleCliente('🎯 Destino', flete.destino, context, bold: true),
                        if (flete.direccionDestino != null)
                          _buildDetalleCliente('  📍 Dirección', flete.direccionDestino!, context),
                        const Divider(height: 16),
                        if (flete.fechaHoraCarga != null) ...[
                          _buildDetalleCliente('📅 Fecha Carga', 
                            '${flete.fechaHoraCarga!.day}/${flete.fechaHoraCarga!.month}/${flete.fechaHoraCarga!.year} ${flete.fechaHoraCarga!.hour}:${flete.fechaHoraCarga!.minute.toString().padLeft(2, '0')}', 
                            context, bold: true),
                          const Divider(height: 16),
                        ],
                        if (flete.isFueraDePerimetro)
                          _buildDetalleCliente('📍 Fuera Perímetro', 'SÍ', context),
                        if (flete.tipoDeRampla != null)
                          _buildDetalleCliente('🚛 Tipo Rampla', flete.tipoDeRampla!, context),
                        if (flete.requisitosEspeciales != null) ...[
                          _buildDetalleCliente('⚠️ Requisitos', flete.requisitosEspeciales!, context, multiline: true),
                          const SizedBox(height: 8),
                        ],
                        if (flete.serviciosAdicionales != null) ...[
                          _buildDetalleCliente('➕ Servicios', flete.serviciosAdicionales!, context, multiline: true),
                          const SizedBox(height: 8),
                        ],
                        if (flete.devolucionCtnVacio != null) ...[
                          _buildDetalleCliente('↩️ Devolución', flete.devolucionCtnVacio!, context, multiline: true),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${flete.tarifa.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                if (!isCliente && isDisponible)
                  ElevatedButton(
                    onPressed: onAceptar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Aceptar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                if (!isCliente && isSolicitado)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange, width: 1.5),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.hourglass_empty, color: Colors.orange, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Pendiente de aprobación',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetalleCliente(String label, String value, BuildContext context, {bool bold = false, bool multiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
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
}
