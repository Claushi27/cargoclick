import 'package:flutter/material.dart';

/// Widget para mostrar instrucciones importantes destacadas
class InstruccionesCard extends StatelessWidget {
  final String? titulo;
  final List<String> instrucciones;
  final Color? color;
  final IconData? icon;

  const InstruccionesCard({
    Key? key,
    this.titulo,
    required this.instrucciones,
    this.color,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? Colors.orange.shade100;
    final iconColor = color ?? Colors.orange.shade700;
    final borderColor = color ?? Colors.orange.shade300;

    if (instrucciones.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  icon ?? Icons.warning_amber_rounded,
                  color: iconColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titulo ?? '⚠️ INSTRUCCIONES IMPORTANTES',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Lista de instrucciones
            ...instrucciones.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(
                  top: entry.key > 0 ? 8 : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: iconColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.grey[900],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

/// Widget simplificado para mostrar una sola instrucción o nota
class InstruccionSimple extends StatelessWidget {
  final String texto;
  final IconData icon;
  final Color? color;

  const InstruccionSimple({
    Key? key,
    required this.texto,
    this.icon = Icons.info_outline,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? Colors.blue.shade50;
    final iconColor = color ?? Colors.blue.shade700;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[900],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
