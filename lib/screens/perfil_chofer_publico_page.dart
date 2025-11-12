import 'package:flutter/material.dart';
import 'package:cargoclick/services/rating_service.dart';
import 'package:cargoclick/services/estadisticas_service.dart';
import 'package:cargoclick/widgets/rating_display.dart';
import 'package:cargoclick/widgets/estadisticas_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Perfil público del chofer visible para clientes y transportistas
class PerfilChoferPublicoPage extends StatefulWidget {
  final String choferId;
  final String nombre;

  const PerfilChoferPublicoPage({
    Key? key,
    required this.choferId,
    required this.nombre,
  }) : super(key: key);

  @override
  State<PerfilChoferPublicoPage> createState() =>
      _PerfilChoferPublicoPageState();
}

class _PerfilChoferPublicoPageState extends State<PerfilChoferPublicoPage> {
  final _ratingService = RatingService();
  final _estadisticasService = EstadisticasService();
  Map<String, dynamic>? _choferData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosChofer();
  }

  Future<void> _cargarDatosChofer() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.choferId)
          .get();

      if (doc.exists) {
        setState(() {
          _choferData = doc.data();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil del Chofer')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_choferData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil del Chofer')),
        body: const Center(child: Text('No se pudo cargar el perfil')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del Chofer'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header con foto y nombre
          _buildHeader(),
          const SizedBox(height: 24),

          // Información personal
          _buildSeccion(
            titulo: '📋 INFORMACIÓN PERSONAL',
            child: _buildInfoPersonal(),
          ),
          const SizedBox(height: 24),

          // Estadísticas
          _buildSeccion(
            titulo: '📊 ESTADÍSTICAS',
            child: FutureBuilder(
              future: _estadisticasService.getEstadisticasUsuario(
                widget.choferId,
                'chofer',
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    heightFactor: 3,
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData) {
                  return const Text('No hay estadísticas disponibles');
                }

                final stats = snapshot.data!;
                return Column(
                  children: [
                    EstadisticasCard(
                      serviciosCompletados: stats.serviciosCompletados,
                      tasaExito: stats.tasaExito,
                      fletesActivos: stats.serviciosActivos,
                      miembroDesde: stats.primerServicio,
                    ),
                    if (stats.primerServicio != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Experiencia: ${stats.experienciaTexto}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Calificaciones
          _buildSeccion(
            titulo: '⭐ CALIFICACIONES RECIBIDAS',
            child: FutureBuilder<Map<String, dynamic>>(
              future: _ratingService.getEstadisticasRatings(widget.choferId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    heightFactor: 3,
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData) {
                  return const Text('No hay calificaciones disponibles');
                }

                final stats = snapshot.data!;
                final promedio = stats['promedio'] as double;
                final total = stats['total'] as int;
                final porEstrellas = stats['por_estrellas'] as Map<int, int>;

                if (total == 0) {
                  return Column(
                    children: const [
                      Icon(Icons.star_outline, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Aún no tiene calificaciones',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    // Rating promedio
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            promedio.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RatingDisplay(
                                rating: promedio,
                                size: 24,
                                showNumber: false,
                              ),
                              Text(
                                '$total calificacion${total != 1 ? 'es' : ''}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Distribución
                    ...List.generate(5, (index) {
                      final estrellas = 5 - index;
                      final cantidad = porEstrellas[estrellas] ?? 0;
                      final porcentaje = total > 0 ? (cantidad / total) : 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Text(
                              '$estrellas',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: porcentaje,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.amber.shade700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '$cantidad',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Logros (si tiene 100% tasa de éxito o más de cierta cantidad de servicios)
          FutureBuilder(
            future: _estadisticasService.getEstadisticasUsuario(
              widget.choferId,
              'chofer',
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              
              final stats = snapshot.data!;
              final logros = <Map<String, dynamic>>[];

              if (stats.tasaExito == 100 && stats.serviciosCompletados > 0) {
                logros.add({
                  'icono': Icons.check_circle,
                  'titulo': '100% Tasa de Éxito',
                  'descripcion': 'Todos los servicios completados exitosamente',
                  'color': Colors.green,
                });
              }

              if (stats.serviciosCompletados >= 50) {
                logros.add({
                  'icono': Icons.emoji_events,
                  'titulo': 'Conductor Experimentado',
                  'descripcion': '${stats.serviciosCompletados}+ servicios completados',
                  'color': Colors.amber,
                });
              }

              if (logros.isEmpty) return const SizedBox.shrink();

              return Column(
                children: [
                  _buildSeccion(
                    titulo: '🏆 LOGROS Y RECONOCIMIENTOS',
                    child: Column(
                      children: logros.map((logro) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (logro['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: (logro['color'] as Color).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                logro['icono'] as IconData,
                                color: logro['color'] as Color,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      logro['titulo'] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      logro['descripcion'] as String,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.nombre,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            FutureBuilder<double>(
              future: _ratingService.getRatingPromedio(widget.choferId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                
                return FutureBuilder<Map<String, dynamic>>(
                  future: _ratingService.getEstadisticasRatings(widget.choferId),
                  builder: (context, statsSnapshot) {
                    final total = statsSnapshot.hasData 
                        ? statsSnapshot.data!['total'] as int 
                        : 0;
                    
                    return RatingDisplay(
                      rating: snapshot.data!,
                      totalRatings: total,
                      size: 22,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPersonal() {
    final empresa = _choferData!['empresa'] ?? '';
    final email = _choferData!['email'] ?? '';
    final telefono = _choferData!['phone_number'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (empresa.isNotEmpty) ...[
          _buildInfoRow(
            icon: Icons.business,
            label: 'Empresa',
            value: empresa,
          ),
          const SizedBox(height: 12),
        ],
        if (email.isNotEmpty) ...[
          _buildInfoRow(
            icon: Icons.email,
            label: 'Email',
            value: email,
          ),
          const SizedBox(height: 12),
        ],
        if (telefono.isNotEmpty) ...[
          _buildInfoRow(
            icon: Icons.phone,
            label: 'Teléfono',
            value: telefono,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
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
      ],
    );
  }

  Widget _buildSeccion({
    required String titulo,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ],
    );
  }
}
