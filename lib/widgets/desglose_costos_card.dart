import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget reutilizable para mostrar desglose de costos de un flete
class DesgloseCostosCard extends StatelessWidget {
  final double tarifaBase;
  final Map<String, double>? costosAdicionales;
  final bool mostrarTotal;

  const DesgloseCostosCard({
    Key? key,
    required this.tarifaBase,
    this.costosAdicionales,
    this.mostrarTotal = true,
  }) : super(key: key);

  double get total {
    double suma = tarifaBase;
    if (costosAdicionales != null) {
      costosAdicionales!.forEach((key, value) {
        suma += value;
      });
    }
    return suma;
  }

  String _formatearMoneda(double monto) {
    return '\$ ${NumberFormat('#,###', 'es_CL').format(monto)}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Desglose de Costos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Tarifa base
            _buildLineaItem(
              context,
              'Tarifa base de transporte',
              tarifaBase,
              esBase: true,
            ),

            // Costos adicionales
            if (costosAdicionales != null && costosAdicionales!.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...costosAdicionales!.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _buildLineaItem(
                    context,
                    entry.key,
                    entry.value,
                  ),
                );
              }).toList(),
            ],

            // Total
            if (mostrarTotal) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    Text(
                      '${_formatearMoneda(total)} CLP',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Nota informativa
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Los costos adicionales pueden incluir peajes, servicios especiales o seguros.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineaItem(
    BuildContext context,
    String concepto,
    double monto, {
    bool esBase = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            concepto,
            style: TextStyle(
              fontSize: esBase ? 14 : 13,
              fontWeight: esBase ? FontWeight.w600 : FontWeight.normal,
              color: esBase ? Colors.black87 : Colors.black54,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '${_formatearMoneda(monto)} CLP',
          style: TextStyle(
            fontSize: esBase ? 15 : 14,
            fontWeight: esBase ? FontWeight.w600 : FontWeight.w500,
            color: esBase ? Colors.black87 : Colors.black54,
          ),
        ),
      ],
    );
  }
}

/// Widget compacto para mostrar solo el total
class ResumenCostosCompacto extends StatelessWidget {
  final double tarifaBase;
  final Map<String, double>? costosAdicionales;

  const ResumenCostosCompacto({
    Key? key,
    required this.tarifaBase,
    this.costosAdicionales,
  }) : super(key: key);

  double get total {
    double suma = tarifaBase;
    if (costosAdicionales != null) {
      costosAdicionales!.forEach((key, value) {
        suma += value;
      });
    }
    return suma;
  }

  String _formatearMoneda(double monto) {
    return '\$ ${NumberFormat('#,###', 'es_CL').format(monto)}';
  }

  @override
  Widget build(BuildContext context) {
    final tieneAdicionales = costosAdicionales != null && costosAdicionales!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Costo Total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${_formatearMoneda(total)} CLP',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          if (tieneAdicionales) ...[
            const SizedBox(height: 4),
            Text(
              'Base: ${_formatearMoneda(tarifaBase)} + Adicionales: ${_formatearMoneda(total - tarifaBase)}',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
