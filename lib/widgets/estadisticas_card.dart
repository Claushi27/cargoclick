import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget para mostrar estadísticas de usuario
class EstadisticasCard extends StatelessWidget {
  final int serviciosCompletados;
  final double? tasaExito;
  final DateTime? miembroDesde;
  final int? fletesActivos;

  const EstadisticasCard({
    Key? key,
    required this.serviciosCompletados,
    this.tasaExito,
    this.miembroDesde,
    this.fletesActivos,
  }) : super(key: key);

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
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Estadísticas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Grid de estadísticas
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildEstadistica(
                  context,
                  icon: Icons.check_circle,
                  label: 'Servicios',
                  valor: serviciosCompletados.toString(),
                  color: Colors.green,
                ),
                if (tasaExito != null)
                  _buildEstadistica(
                    context,
                    icon: Icons.trending_up,
                    label: 'Tasa de éxito',
                    valor: '${tasaExito!.toStringAsFixed(0)}%',
                    color: Colors.blue,
                  ),
                if (fletesActivos != null)
                  _buildEstadistica(
                    context,
                    icon: Icons.local_shipping,
                    label: 'Activos',
                    valor: fletesActivos.toString(),
                    color: Colors.orange,
                  ),
                if (miembroDesde != null)
                  _buildEstadistica(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Miembro desde',
                    valor: DateFormat('MMM yyyy', 'es').format(miembroDesde!),
                    color: Colors.purple,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadistica(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String valor,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget simple para mostrar una métrica individual
class MetricaSimple extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;
  final Color? color;

  const MetricaSimple({
    Key? key,
    required this.icon,
    required this.label,
    required this.valor,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final metricColor = color ?? Theme.of(context).colorScheme.primary;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: metricColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: metricColor, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
