import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cargoclick/services/auth_service.dart';
import 'package:cargoclick/services/rating_service.dart';
import 'package:cargoclick/models/transportista.dart';
import 'package:cargoclick/widgets/rating_display.dart';

class PerfilTransportistaPage extends StatefulWidget {
  const PerfilTransportistaPage({super.key});

  @override
  State<PerfilTransportistaPage> createState() => _PerfilTransportistaPageState();
}

class _PerfilTransportistaPageState extends State<PerfilTransportistaPage> {
  final _authService = AuthService();
  final _ratingService = RatingService();
  final _tarifaMinimaController = TextEditingController();
  Transportista? _transportista;
  bool _isLoading = true;
  bool _editandoTarifa = false;
  bool _editandoPuerto = false;
  String? _puertoSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarTransportista();
  }

  @override
  void dispose() {
    _tarifaMinimaController.dispose();
    super.dispose();
  }

  Future<void> _cargarTransportista() async {
    try {
      final transportista = await _authService.getCurrentTransportista();
      if (mounted) {
        setState(() {
          _transportista = transportista;
          _isLoading = false;
          if (transportista?.tarifaMinima != null) {
            _tarifaMinimaController.text = transportista!.tarifaMinima!.toStringAsFixed(0);
          }
          _puertoSeleccionado = transportista?.puertoPreferido;
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

  Future<void> _guardarTarifaMinima() async {
    final tarifaText = _tarifaMinimaController.text.trim();
    
    if (tarifaText.isEmpty) {
      // Eliminar tarifa mínima
      await _authService.actualizarTarifaMinima(_transportista!.uid, null);
      setState(() {
        _transportista = _transportista!.copyWith(tarifaMinima: null);
        _editandoTarifa = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarifa mínima eliminada'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return;
    }

    final tarifa = double.tryParse(tarifaText);
    if (tarifa == null || tarifa < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa una tarifa válida'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await _authService.actualizarTarifaMinima(_transportista!.uid, tarifa);
      setState(() {
        _transportista = _transportista!.copyWith(tarifaMinima: tarifa);
        _editandoTarifa = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarifa mínima actualizada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _guardarPuertoPreferido() async {
    try {
      await _authService.actualizarPuertoPreferido(_transportista!.uid, _puertoSeleccionado);
      setState(() {
        _transportista = _transportista!.copyWith(puertoPreferido: _puertoSeleccionado);
        _editandoPuerto = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _puertoSeleccionado == null 
                ? 'Verás fletes de ambos puertos'
                : 'Puerto preferido: $_puertoSeleccionado',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

                      // Configuración de Tarifa Mínima
                      Text(
                        'CONFIGURACIÓN DE FLETES',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.attach_money,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Tarifa Base Flete',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Solo verás fletes con tarifas iguales o superiores a este valor',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_editandoTarifa) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _tarifaMinimaController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Tarifa base (CLP)',
                                        hintText: 'Ej: 150000',
                                        prefixText: '\$ ',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        helperText: 'Deja vacío para ver todos los fletes',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _editandoTarifa = false;
                                        if (_transportista?.tarifaMinima != null) {
                                          _tarifaMinimaController.text = 
                                              _transportista!.tarifaMinima!.toStringAsFixed(0);
                                        } else {
                                          _tarifaMinimaController.clear();
                                        }
                                      });
                                    },
                                    child: const Text('Cancelar'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: _guardarTarifaMinima,
                                    icon: const Icon(Icons.save, size: 18),
                                    label: const Text('Guardar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _transportista?.tarifaMinima != null
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _transportista?.tarifaMinima != null
                                        ? Colors.green.withOpacity(0.3)
                                        : Colors.grey.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _transportista?.tarifaMinima != null
                                              ? 'Tarifa mínima configurada'
                                              : 'Sin tarifa mínima',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _transportista?.tarifaMinima != null
                                              ? '\$ ${_transportista!.tarifaMinima!.toStringAsFixed(0)} CLP'
                                              : 'Verás todos los fletes',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: _transportista?.tarifaMinima != null
                                                ? Colors.green[700]
                                                : Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => setState(() => _editandoTarifa = true),
                                      tooltip: 'Editar',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                       // Puerto Preferido
     const SizedBox(height: 20),
     Card(
       child: Padding(
         padding: const EdgeInsets.all(16),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Row(
               children: [
                 Icon(
                   Icons.location_on,
                   color: Theme.of(context).colorScheme.primary,
                 ),
                 const SizedBox(width: 12),
                 Text(
                   'Puerto Preferido',
                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
                     fontWeight: FontWeight.w600,
                   ),
                 ),
               ],
             ),
             const SizedBox(height: 16),
             if (_editandoPuerto) ...[
               DropdownButtonFormField<String>(
                 value: _puertoSeleccionado,
                 decoration: InputDecoration(
                   labelText: 'Selecciona puerto',
                   border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(8),
                   ),
                 ),
                 items: const [
                   DropdownMenuItem(value: null, child: Text('Ambos puertos')),
                   DropdownMenuItem(value: 'Valparaiso', child: Text('Valparaíso')),
                   DropdownMenuItem(value: 'San Antonio', child: Text('San Antonio')),
                 ],
                 onChanged: (value) {
                   setState(() {
                     _puertoSeleccionado = value;
                   });
                 },
               ),
               const SizedBox(height: 12),
               Row(
                 mainAxisAlignment: MainAxisAlignment.end,
                 children: [
                   TextButton(
                     onPressed: () {
                       setState(() {
                         _editandoPuerto = false;
                         _puertoSeleccionado = _transportista?.puertoPreferido;
                       });
                     },
                     child: const Text('Cancelar'),
                   ),
                   const SizedBox(width: 8),
                   ElevatedButton(
                     onPressed: _guardarPuertoPreferido,
                     child: const Text('Guardar'),
                   ),
                 ],
               ),
             ] else ...[
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: _transportista?.puertoPreferido != null
                       ? Colors.blue.shade50
                       : Colors.grey.shade100,
                   borderRadius: BorderRadius.circular(8),
                 ),
                 child: Row(
                   children: [
                     Icon(
                       Icons.directions_boat,
                       color: _transportista?.puertoPreferido != null
                           ? Colors.blue
                           : Colors.grey,
                     ),
                     const SizedBox(width: 12),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             _transportista?.puertoPreferido != null
                                 ? 'Filtro activo'
                                 : 'Ver todos los puertos',
                             style: TextStyle(
                               fontSize: 12,
                               color: Colors.grey.shade600,
                             ),
                           ),
                           Text(
                             _transportista?.puertoPreferido ?? 'Ambos puertos',
                             style: TextStyle(
                               fontSize: 16,
                               fontWeight: FontWeight.bold,
                               color: _transportista?.puertoPreferido != null
                                   ? Colors.blue.shade700
                                   : Colors.grey.shade700,
                             ),
                           ),
                         ],
                       ),
                     ),
                     IconButton(
                       icon: const Icon(Icons.edit),
                       onPressed: () => setState(() => _editandoPuerto = true),
                     ),
                   ],
                 ),
               ),
             ],
           ],
         ),
       ),
     ),

                      // Estadísticas de Rating
                      Text(
                        'CALIFICACIONES',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<Map<String, dynamic>>(
                        future: _ratingService.getEstadisticasRatings(_transportista!.uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text('Error: ${snapshot.error}'),
                              ),
                            );
                          }

                          final estadisticas = snapshot.data!;
                          return RatingEstadisticas(estadisticas: estadisticas);
                        },
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
