import 'package:flutter/material.dart';

/// Widget de línea de tiempo para mostrar progreso de estados
class ProgressTimeline extends StatelessWidget {
  final List<String> estados;
  final String estadoActual;
  final double size;

  const ProgressTimeline({
    Key? key,
    required this.estados,
    required this.estadoActual,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final indexActual = estados.indexOf(estadoActual);
    
    return Row(
      children: List.generate(estados.length * 2 - 1, (index) {
        if (index.isEven) {
          // Es un círculo de estado
          final estadoIndex = index ~/ 2;
          final esCompletado = estadoIndex <= indexActual;
          final esActual = estadoIndex == indexActual;
          
          return _buildEstadoCircle(
            estados[estadoIndex],
            esCompletado,
            esActual,
          );
        } else {
          // Es una línea conectora
          final lineaIndex = index ~/ 2;
          final esCompletada = lineaIndex < indexActual;
          
          return _buildConnector(esCompletada);
        }
      }),
    );
  }

  Widget _buildEstadoCircle(String estado, bool completado, bool actual) {
    Color color;
    IconData icon;
    
    if (actual) {
      color = Colors.orange;
      icon = Icons.radio_button_checked;
    } else if (completado) {
      color = Colors.green;
      icon = Icons.check_circle;
    } else {
      color = Colors.grey.shade300;
      icon = Icons.radio_button_unchecked;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: actual ? color.withOpacity(0.2) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: size,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getNombreEstado(estado),
          style: TextStyle(
            fontSize: 10,
            fontWeight: actual ? FontWeight.bold : FontWeight.normal,
            color: completado ? color : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(bool completada) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: completada ? Colors.green : Colors.grey.shade300,
      ),
    );
  }

  String _getNombreEstado(String estado) {
    switch (estado) {
      case 'asignado':
        return 'Asignado';
      case 'en_proceso':
        return 'En Proceso';
      case 'completado':
        return 'Completado';
      case 'pendiente':
        return 'Pendiente';
      default:
        return estado;
    }
  }
}
