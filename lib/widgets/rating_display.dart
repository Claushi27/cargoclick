import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar rating con estrellas
class RatingDisplay extends StatelessWidget {
  final double rating;
  final int? totalRatings;
  final double size;
  final bool showNumber;

  const RatingDisplay({
    Key? key,
    required this.rating,
    this.totalRatings,
    this.size = 20,
    this.showNumber = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final estrella = index + 1;
          return Icon(
            estrella <= rating.floor()
                ? Icons.star
                : (estrella - 0.5 <= rating ? Icons.star_half : Icons.star_border),
            color: Colors.amber,
            size: size,
          );
        }),
        if (showNumber) ...[
          const SizedBox(width: 4),
          Text(
            rating > 0 ? rating.toStringAsFixed(1) : 'Sin calificar',
            style: TextStyle(
              fontSize: size * 0.7,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
        if (totalRatings != null && totalRatings! > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($totalRatings)',
            style: TextStyle(
              fontSize: size * 0.6,
              color: Colors.black54,
            ),
          ),
        ],
      ],
    );
  }
}

/// Widget para mostrar estadísticas detalladas de ratings
class RatingEstadisticas extends StatelessWidget {
  final Map<String, dynamic> estadisticas;

  const RatingEstadisticas({
    Key? key,
    required this.estadisticas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = estadisticas['total'] as int;
    final promedio = estadisticas['promedio'] as double;
    final porEstrellas = estadisticas['por_estrellas'] as Map<int, int>;

    if (total == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: const [
              Icon(Icons.star_outline, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Sin calificaciones aún',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

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
                const Icon(Icons.star, color: Colors.amber, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Calificaciones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Promedio grande
            Row(
              children: [
                Text(
                  promedio.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RatingDisplay(rating: promedio, showNumber: false),
                    const SizedBox(height: 4),
                    Text(
                      '$total ${total == 1 ? 'calificación' : 'calificaciones'}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
            
            const Divider(height: 24),
            
            // Distribución por estrellas
            ...List.generate(5, (index) {
              final estrellas = 5 - index;
              final cantidad = porEstrellas[estrellas] ?? 0;
              final porcentaje = total > 0 ? (cantidad / total) : 0.0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text('$estrellas', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: porcentaje,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 30,
                      child: Text(
                        '$cantidad',
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
