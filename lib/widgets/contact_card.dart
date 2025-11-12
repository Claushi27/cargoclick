import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cargoclick/widgets/rating_display.dart';

/// Widget de card de contacto con información y botones de acción
class ContactCard extends StatelessWidget {
  final String nombre;
  final String? empresa;
  final String? telefono;
  final String? email;
  final double? rating;
  final int? totalCalificaciones;
  final bool showActions;

  const ContactCard({
    Key? key,
    required this.nombre,
    this.empresa,
    this.telefono,
    this.email,
    this.rating,
    this.totalCalificaciones,
    this.showActions = true,
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
            // Header con nombre y rating
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (empresa != null)
                        Text(
                          empresa!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Rating si está disponible
            if (rating != null && rating! > 0) ...[
              const SizedBox(height: 12),
              RatingDisplay(
                rating: rating!,
                totalRatings: totalCalificaciones,
                size: 18,
              ),
            ],
            
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            
            // Información de contacto
            if (telefono != null)
              _buildInfoRow(
                icon: Icons.phone,
                label: 'Teléfono',
                value: telefono!,
                onTap: showActions ? () => _llamar(telefono!) : null,
              ),
            
            if (email != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.email,
                label: 'Email',
                value: email!,
                onTap: showActions ? () => _copiarEmail(context, email!) : null,
              ),
            ],
            
            // Botones de acción
            if (showActions && (telefono != null || email != null)) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (telefono != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _llamar(telefono!),
                        icon: const Icon(Icons.phone, size: 20),
                        label: const Text('Llamar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  if (telefono != null && email != null)
                    const SizedBox(width: 12),
                  if (email != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _enviarEmail(email!),
                        icon: const Icon(Icons.email, size: 20),
                        label: const Text('Email'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
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
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Future<void> _llamar(String telefono) async {
    final uri = Uri.parse('tel:$telefono');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _enviarEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _copiarEmail(BuildContext context, String email) {
    Clipboard.setData(ClipboardData(text: email));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email copiado al portapapeles'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
