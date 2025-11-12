import 'package:flutter/material.dart';
import '../services/rating_service.dart';

class RatingDialog extends StatefulWidget {
  final String fleteId;
  final String clienteId;
  final String transportistaId;
  final VoidCallback onRatingSubmitted;

  const RatingDialog({
    Key? key,
    required this.fleteId,
    required this.clienteId,
    required this.transportistaId,
    required this.onRatingSubmitted,
  }) : super(key: key);

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  final RatingService _ratingService = RatingService();
  final TextEditingController _comentarioController = TextEditingController();
  int _estrellas = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _enviarRating() async {
    if (_estrellas == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una calificación'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _ratingService.crearRating(
        fleteId: widget.fleteId,
        clienteId: widget.clienteId,
        transportistaId: widget.transportistaId,
        estrellas: _estrellas,
        comentario: _comentarioController.text.trim().isEmpty 
            ? null 
            : _comentarioController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onRatingSubmitted();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Gracias por tu calificación!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar calificación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.star, color: Colors.amber, size: 28),
          SizedBox(width: 8),
          Text('Calificar Servicio'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Cómo fue tu experiencia con este servicio?',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            
            // Estrellas
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final estrella = index + 1;
                  return IconButton(
                    iconSize: 40,
                    icon: Icon(
                      estrella <= _estrellas ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: _isLoading 
                        ? null 
                        : () => setState(() => _estrellas = estrella),
                  );
                }),
              ),
            ),
            
            if (_estrellas > 0)
              Center(
                child: Text(
                  _getTextoCalificacion(_estrellas),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Comentario opcional
            TextField(
              controller: _comentarioController,
              maxLines: 3,
              maxLength: 500,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Comentario (opcional)',
                hintText: 'Cuéntanos más sobre tu experiencia...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.comment),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _enviarRating,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.send),
          label: Text(_isLoading ? 'Enviando...' : 'Enviar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  String _getTextoCalificacion(int estrellas) {
    switch (estrellas) {
      case 1:
        return 'Muy malo';
      case 2:
        return 'Malo';
      case 3:
        return 'Regular';
      case 4:
        return 'Bueno';
      case 5:
        return 'Excelente';
      default:
        return '';
    }
  }
}
