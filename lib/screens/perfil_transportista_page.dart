import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cargoclick/services/auth_service.dart';
import 'package:cargoclick/models/transportista.dart';

class PerfilTransportistaPage extends StatefulWidget {
  const PerfilTransportistaPage({super.key});

  @override
  State<PerfilTransportistaPage> createState() => _PerfilTransportistaPageState();
}

class _PerfilTransportistaPageState extends State<PerfilTransportistaPage> {
  final _authService = AuthService();
  Transportista? _transportista;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarTransportista();
  }

  Future<void> _cargarTransportista() async {
    try {
      final transportista = await _authService.getCurrentTransportista();
      if (mounted) {
        setState(() {
          _transportista = transportista;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar perfil: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copiarCodigo() {
    if (_transportista != null) {
      Clipboard.setData(ClipboardData(text: _transportista!.codigoInvitacion));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código copiado al portapapeles'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transportista == null
              ? const Center(child: Text('No se pudo cargar el perfil'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con ícono
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.business,
                                size: 50,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _transportista!.razonSocial,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'RUT: ${_transportista!.rutEmpresa}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Código de Invitación (destacado)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'CÓDIGO DE INVITACIÓN',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _transportista!.codigoInvitacion,
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _copiarCodigo,
                              icon: const Icon(Icons.copy, size: 18),
                              label: const Text('Copiar Código'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Instrucciones
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Comparte este código con tus choferes para que puedan registrarse y vincularse a tu empresa',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Información de la empresa
                      Text(
                        'INFORMACIÓN DE LA EMPRESA',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        context,
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: _transportista!.email,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        context,
                        icon: Icons.phone_outlined,
                        label: 'Teléfono',
                        value: _transportista!.telefono,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        context,
                        icon: Icons.calendar_today_outlined,
                        label: 'Fecha de Registro',
                        value: '${_transportista!.createdAt.day}/${_transportista!.createdAt.month}/${_transportista!.createdAt.year}',
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
