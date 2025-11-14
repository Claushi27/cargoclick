import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cargoclick/models/flete.dart';
import 'package:intl/intl.dart';

/// MÓDULO 4: Vista de Detalle de Cobro Final
/// 
/// Muestra el desglose completo de la tarifa cuando el flete está completado:
/// - Tarifa base
/// - Valor adicional por perímetro (si aplica)
/// - Valor adicional por sobrepeso (si aplica)
/// - Total final
class DetalleCobroPage extends StatelessWidget {
  final Flete flete;

  const DetalleCobroPage({
    Key? key,
    required this.flete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = _calcularTotal();
    final hasAdicionales = flete.valorAdicionalPerimetro != null || 
                          flete.valorAdicionalSobrepeso != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Cobro'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información del flete
            _buildHeader(context),
            
            const SizedBox(height: 32),
            
            // Card principal de desglose
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Título del desglose
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.receipt_long, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'DESGLOSE DE TARIFA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Contenido del desglose
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Tarifa Base
                        _buildItemTarifa(
                          label: 'Tarifa Base',
                          valor: flete.tarifa,
                          isBase: true,
                        ),
                        
                        // Adicionales
                        if (hasAdicionales) ...[
                          const SizedBox(height: 20),
                          const Divider(thickness: 1),
                          const SizedBox(height: 16),
                          
                          Text(
                            'ADICIONALES:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Adicional por Perímetro
                          if (flete.valorAdicionalPerimetro != null) ...[
                            _buildItemTarifa(
                              label: 'Fuera de Perímetro',
                              valor: flete.valorAdicionalPerimetro!,
                              icon: Icons.add_location_alt,
                              isAdicional: true,
                            ),
                            const SizedBox(height: 12),
                          ],
                          
                          // Adicional por Sobrepeso
                          if (flete.valorAdicionalSobrepeso != null) ...[
                            _buildItemTarifa(
                              label: 'Sobrepeso (>25 ton)',
                              valor: flete.valorAdicionalSobrepeso!,
                              icon: Icons.scale,
                              isAdicional: true,
                            ),
                          ],
                        ],
                        
                        // Línea divisoria antes del total
                        const SizedBox(height: 24),
                        const Divider(thickness: 2),
                        const SizedBox(height: 24),
                        
                        // Total destacado
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade600,
                                Colors.green.shade700,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.shade300.withOpacity(0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TOTAL A COBRAR',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatearMoneda(total),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.attach_money,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Información adicional
            _buildInfoAdicional(context),
            
            const SizedBox(height: 24),
            
            // Botones de acción
            _buildBotonesAccion(context, total),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_shipping,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FLETE COMPLETADO',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CTN ${flete.numeroContenedor}',
                    style: const TextStyle(
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700, size: 18),
              const SizedBox(width: 8),
              Text(
                'Completado el ${DateFormat('dd/MM/yyyy').format(flete.updatedAt)}',
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemTarifa({
    required String label,
    required double valor,
    IconData? icon,
    bool isBase = false,
    bool isAdicional = false,
  }) {
    return Row(
      children: [
        if (isAdicional) ...[
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 20),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isBase ? 18 : 16,
              fontWeight: isBase ? FontWeight.bold : FontWeight.w600,
              color: isBase ? Colors.black : Colors.grey[700],
            ),
          ),
        ),
        Text(
          _formatearMoneda(valor),
          style: TextStyle(
            fontSize: isBase ? 22 : 18,
            fontWeight: FontWeight.bold,
            color: isBase ? Colors.black : Colors.blue.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoAdicional(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Información del Flete',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Tipo', flete.tipoContenedor),
          const SizedBox(height: 8),
          _buildInfoRow('Peso', '${NumberFormat('#,###', 'es_CL').format(flete.peso)} kg'),
          const SizedBox(height: 8),
          _buildInfoRow('Origen', flete.origen),
          const SizedBox(height: 8),
          _buildInfoRow('Destino', flete.destino),
          if (flete.puertoOrigen != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Puerto', flete.puertoOrigen!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBotonesAccion(BuildContext context, double total) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _copiarDesglose(context, total),
            icon: const Icon(Icons.content_copy, size: 24),
            label: const Text(
              'Copiar Desglose',
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
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 24),
            label: const Text(
              'Cerrar',
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
    );
  }

  double _calcularTotal() {
    double total = flete.tarifa;
    
    if (flete.valorAdicionalPerimetro != null) {
      total += flete.valorAdicionalPerimetro!;
    }
    
    if (flete.valorAdicionalSobrepeso != null) {
      total += flete.valorAdicionalSobrepeso!;
    }
    
    return total;
  }

  String _formatearMoneda(double valor) {
    final formatter = NumberFormat.currency(
      locale: 'es_CL',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(valor);
  }

  void _copiarDesglose(BuildContext context, double total) {
    final texto = '''
DETALLE DE COBRO - FLETE ${flete.numeroContenedor}

Tarifa Base: ${_formatearMoneda(flete.tarifa)}
${flete.valorAdicionalPerimetro != null ? '+ Perímetro: ${_formatearMoneda(flete.valorAdicionalPerimetro!)}\n' : ''}${flete.valorAdicionalSobrepeso != null ? '+ Sobrepeso: ${_formatearMoneda(flete.valorAdicionalSobrepeso!)}\n' : ''}
TOTAL: ${_formatearMoneda(total)}

Completado: ${DateFormat('dd/MM/yyyy').format(flete.updatedAt)}
''';

    Clipboard.setData(ClipboardData(text: texto));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Desglose copiado al portapapeles'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
