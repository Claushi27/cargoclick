import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HojaCobroCard extends StatelessWidget {
  final double? tarifaBase;
  final double? valorAdicionalPerimetro;
  final double? valorAdicionalSobrepeso;
  final double? valorSobreestadia;
  final double? valorAdicionalExtra;
  final String? requisitosEspeciales;
  final double total;

  const HojaCobroCard({
    super.key,
    this.tarifaBase,
    this.valorAdicionalPerimetro,
    this.valorAdicionalSobrepeso,
    this.valorSobreestadia,
    this.valorAdicionalExtra,
    this.requisitosEspeciales,
    required this.total,
  });

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'es_CL',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  double _calcularSubtotal() {
    double subtotal = tarifaBase ?? total;
    
    if (valorAdicionalPerimetro != null) {
      subtotal += valorAdicionalPerimetro!;
    }
    if (valorAdicionalSobrepeso != null) {
      subtotal += valorAdicionalSobrepeso!;
    }
    if (valorSobreestadia != null) {
      subtotal += valorSobreestadia!;
    }
    if (valorAdicionalExtra != null) {
      subtotal += valorAdicionalExtra!;
    }
    
    return subtotal;
  }

  double _calcularIVA(double subtotal) {
    return subtotal * 0.19;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtotal = _calcularSubtotal();
    final iva = _calcularIVA(subtotal);
    final totalConIva = subtotal + iva;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              theme.colorScheme.secondaryContainer.withValues(alpha: 0.2),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HOJA DE DETALLE DE COBRO',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Desglose de Facturación',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),

              // Concepto Base
              _buildConceptoItem(
                context: context,
                titulo: 'CONCEPTO BASE',
                descripcion: 'Flete Origen → Destino',
                valor: tarifaBase ?? total,
                esBase: true,
              ),

              const SizedBox(height: 16),
              
              // Adicionales
              if (_tieneAdicionales()) ...[
                Text(
                  'ADICIONALES',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),

                if (valorAdicionalPerimetro != null && valorAdicionalPerimetro! > 0)
                  _buildConceptoItem(
                    context: context,
                    titulo: 'Recargo Fuera de Perímetro',
                    descripcion: 'Destino fuera del radio estándar',
                    valor: valorAdicionalPerimetro!,
                    icono: Icons.location_off,
                  ),

                if (valorAdicionalSobrepeso != null && valorAdicionalSobrepeso! > 0)
                  _buildConceptoItem(
                    context: context,
                    titulo: 'Recargo por Sobrepeso',
                    descripcion: 'Excede las 25 toneladas',
                    valor: valorAdicionalSobrepeso!,
                    icono: Icons.fitness_center,
                  ),

                if (valorSobreestadia != null && valorSobreestadia! > 0)
                  _buildConceptoItem(
                    context: context,
                    titulo: 'Sobrestadía',
                    descripcion: 'Tiempo adicional de espera',
                    valor: valorSobreestadia!,
                    icono: Icons.access_time,
                  ),

                if (valorAdicionalExtra != null && valorAdicionalExtra! > 0)
                  _buildConceptoItem(
                    context: context,
                    titulo: 'Requisitos Especiales',
                    descripcion: requisitosEspeciales ?? 'Servicios adicionales',
                    valor: valorAdicionalExtra!,
                    icono: Icons.build,
                  ),

                const SizedBox(height: 16),
              ],

              const Divider(thickness: 2),
              const SizedBox(height: 12),

              // Subtotal
              _buildTotalItem(
                titulo: 'Subtotal',
                valor: subtotal,
                esSubtotal: true,
              ),

              const SizedBox(height: 8),

              // IVA
              _buildTotalItem(
                titulo: 'IVA (19%)',
                valor: iva,
                esIva: true,
              ),

              const SizedBox(height: 12),
              const Divider(thickness: 2),
              const SizedBox(height: 12),

              // Total Final
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
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
                        Text(
                          'TOTAL A FACTURAR',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Incluye IVA',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatCurrency(totalConIva),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Nota informativa
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue[200]!,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta hoja de cobro incluye todos los conceptos facturables del flete. Conserve este documento para su registro.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue[900],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _tieneAdicionales() {
    return (valorAdicionalPerimetro != null && valorAdicionalPerimetro! > 0) ||
           (valorAdicionalSobrepeso != null && valorAdicionalSobrepeso! > 0) ||
           (valorSobreestadia != null && valorSobreestadia! > 0) ||
           (valorAdicionalExtra != null && valorAdicionalExtra! > 0);
  }

  Widget _buildConceptoItem({
    required BuildContext context,
    required String titulo,
    required String descripcion,
    required double valor,
    IconData? icono,
    bool esBase = false,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: esBase 
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: esBase 
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          if (icono != null || esBase)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: esBase
                    ? theme.colorScheme.primary.withValues(alpha: 0.2)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icono ?? Icons.local_shipping,
                size: 20,
                color: esBase
                    ? theme.colorScheme.primary
                    : Colors.grey[600],
              ),
            ),
          if (icono != null || esBase) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontWeight: esBase ? FontWeight.bold : FontWeight.w600,
                    fontSize: esBase ? 15 : 14,
                    color: esBase ? theme.colorScheme.primary : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  descripcion,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _formatCurrency(valor),
            style: TextStyle(
              fontWeight: esBase ? FontWeight.bold : FontWeight.w600,
              fontSize: esBase ? 18 : 16,
              color: esBase ? theme.colorScheme.primary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalItem({
    required String titulo,
    required double valor,
    bool esSubtotal = false,
    bool esIva = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontWeight: esSubtotal ? FontWeight.w600 : FontWeight.normal,
              fontSize: esSubtotal ? 16 : 14,
              color: esIva ? Colors.grey[600] : Colors.black87,
            ),
          ),
          Text(
            _formatCurrency(valor),
            style: TextStyle(
              fontWeight: esSubtotal ? FontWeight.w600 : FontWeight.normal,
              fontSize: esSubtotal ? 16 : 14,
              color: esIva ? Colors.grey[600] : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
