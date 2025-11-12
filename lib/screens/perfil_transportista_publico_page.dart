import 'package:flutter/material.dart';
import 'package:cargoclick/models/transportista.dart';
import 'package:cargoclick/services/rating_service.dart';
import 'package:cargoclick/services/estadisticas_service.dart';
import 'package:cargoclick/widgets/rating_display.dart';
import 'package:cargoclick/widgets/estadisticas_card.dart';
import 'package:cargoclick/screens/perfil_chofer_publico_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

/// Perfil público del transportista visible para clientes
class PerfilTransportistaPublicoPage extends StatefulWidget {
  final Transportista transportista;

  const PerfilTransportistaPublicoPage({
    Key? key,
    required this.transportista,
  }) : super(key: key);

  @override
  State<PerfilTransportistaPublicoPage> createState() =>
      _PerfilTransportistaPublicoPageState();
}

class _PerfilTransportistaPublicoPageState
    extends State<PerfilTransportistaPublicoPage> {
  final _ratingService = RatingService();
  final _estadisticasService = EstadisticasService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del Transportista'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _compartirPerfil,
            tooltip: 'Compartir perfil',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header con nombre y rating
          _buildHeader(),
          const SizedBox(height: 24),

          // Información de la empresa
          _buildSeccion(
            titulo: '📋 INFORMACIÓN DE LA EMPRESA',
            child: _buildInfoEmpresa(),
          ),
          const SizedBox(height: 24),

          // Estadísticas
          _buildSeccion(
            titulo: '📊 ESTADÍSTICAS',
            child: FutureBuilder(
              future: _estadisticasService.getEstadisticasUsuario(
                widget.transportista.uid,
                'transportista',
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
                return EstadisticasCard(
                  serviciosCompletados: stats.serviciosCompletados,
                  tasaExito: stats.tasaExito,
                  fletesActivos: stats.serviciosActivos,
                  miembroDesde: stats.primerServicio ?? widget.transportista.createdAt,
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Calificaciones
          _buildSeccion(
            titulo: '⭐ CALIFICACIONES',
            child: FutureBuilder<Map<String, dynamic>>(
              future: _ratingService.getEstadisticasRatings(widget.transportista.uid),
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
                    // Rating promedio grande
                    Row(
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
                        const SizedBox(width: 8),
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
                    const SizedBox(height: 24),

                    // Distribución por estrellas
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

          // Choferes bajo su mando
          _buildSeccion(
            titulo: '🚛 CHOFERES BAJO SU MANDO',
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _estadisticasService.getChoferesConEstadisticas(
                widget.transportista.uid,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    heightFactor: 3,
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No hay choferes registrados');
                }

                final choferes = snapshot.data!;

                return Column(
                  children: [
                    Text(
                      '${choferes.length} chofer${choferes.length != 1 ? 'es' : ''} disponible${choferes.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...choferes.take(5).map((chofer) => _buildChoferCard(chofer)).toList(),
                    if (choferes.length > 5) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          // Mostrar todos los choferes en un modal
                          _mostrarTodosChoferes(choferes);
                        },
                        child: Text('Ver todos los choferes (${choferes.length})'),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Flota de vehículos
          _buildSeccion(
            titulo: '🚚 FLOTA DE VEHÍCULOS',
            child: FutureBuilder<Map<String, int>>(
              future: _estadisticasService.getDistribucionCamiones(
                widget.transportista.uid,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    heightFactor: 3,
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No hay vehículos registrados');
                }

                final distribucion = snapshot.data!;
                final total = distribucion.values.fold<int>(0, (sum, val) => sum + val);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total de vehículos: $total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...distribucion.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_shipping,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${entry.value}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Tarifa mínima
          if (widget.transportista.tarifaMinima != null) ...[
            _buildSeccion(
              titulo: '💰 TARIFA MÍNIMA',
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_money, color: Colors.green.shade700, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${NumberFormat('#,###', 'es_CL').format(widget.transportista.tarifaMinima)} CLP',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Text(
                            'Tarifa mínima por servicio',
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
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Botón de contacto
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _contactarTransportista(),
              icon: const Icon(Icons.phone, size: 24),
              label: const Text(
                'Contactar Transportista',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
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
                Icons.business,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.transportista.razonSocial,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            FutureBuilder<double>(
              future: _ratingService.getRatingPromedio(widget.transportista.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                
                return FutureBuilder<Map<String, dynamic>>(
                  future: _ratingService.getEstadisticasRatings(widget.transportista.uid),
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

  Widget _buildInfoEmpresa() {
    return Column(
      children: [
        _buildInfoRow(
          icon: Icons.badge,
          label: 'RUT',
          value: widget.transportista.rutEmpresa,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.email,
          label: 'Email',
          value: widget.transportista.email,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.phone,
          label: 'Teléfono',
          value: widget.transportista.telefono,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.vpn_key,
          label: 'Código',
          value: widget.transportista.codigoInvitacion,
          copiable: true,
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool copiable = false,
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
        if (copiable)
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Código copiado'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
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

  Widget _buildChoferCard(Map<String, dynamic> choferData) {
    final nombre = choferData['nombre'] as String;
    final id = choferData['id'] as String;
    final estadisticas = choferData['estadisticas'];
    final servicios = estadisticas.serviciosCompletados;
    final rating = estadisticas.ratingPromedio ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PerfilChoferPublicoPage(
                choferId: id,
                nombre: nombre,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(Icons.person, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (rating > 0) ...[
                          RatingDisplay(
                            rating: rating,
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          '$servicios servicio${servicios != 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarTodosChoferes(List<Map<String, dynamic>> choferes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Todos los Choferes (${choferes.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: choferes.length,
                  itemBuilder: (context, index) {
                    return _buildChoferCard(choferes[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _contactarTransportista() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contactar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Teléfono: ${widget.transportista.telefono}'),
            const SizedBox(height: 8),
            Text('Email: ${widget.transportista.email}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _compartirPerfil() {
    Clipboard.setData(
      ClipboardData(
        text: 'Transportista: ${widget.transportista.razonSocial}\n'
            'Código: ${widget.transportista.codigoInvitacion}',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Información copiada al portapapeles'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
