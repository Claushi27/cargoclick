import 'package:flutter/material.dart';
import 'package:cargoclick/services/flete_service.dart';
import 'package:cargoclick/services/auth_service.dart';
import 'package:cargoclick/models/flete.dart';
import 'package:cargoclick/screens/asignar_flete_page.dart';

class FletesDisponiblesTransportistaPage extends StatefulWidget {
  const FletesDisponiblesTransportistaPage({super.key});

  @override
  State<FletesDisponiblesTransportistaPage> createState() => _FletesDisponiblesTransportistaPageState();
}

class _FletesDisponiblesTransportistaPageState extends State<FletesDisponiblesTransportistaPage> {
  final _fleteService = FleteService();
  final _authService = AuthService();
  String? _transportistaId;

  @override
  void initState() {
    super.initState();
    _cargarTransportistaId();
  }

  Future<void> _cargarTransportistaId() async {
    final transportista = await _authService.getCurrentTransportista();
    if (mounted) {
      setState(() => _transportistaId = transportista?.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fletes Disponibles'),
      ),
      body: StreamBuilder<List<Flete>>(
        stream: _fleteService.getFletesDisponiblesTransportista(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final fletes = snapshot.data ?? [];

          if (fletes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay fletes disponibles',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los fletes aparecerán aquí cuando los clientes los publiquen',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: fletes.length,
            itemBuilder: (context, index) => _buildFleteCard(fletes[index]),
          );
        },
      ),
    );
  }

  Widget _buildFleteCard(Flete flete) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => _mostrarDetallesFlete(flete),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con contenedor
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.inventory_2,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CTN ${flete.numeroContenedor}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          flete.tipoContenedor,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${flete.tarifa.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Tarifa',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Ruta
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        flete.origen,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        flete.destino,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Info adicional
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      context,
                      icon: Icons.scale,
                      label: '${flete.peso.toStringAsFixed(0)} kg',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      context,
                      icon: Icons.calendar_today,
                      label: _formatearFecha(flete.fechaPublicacion),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Botón de acción
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _aceptarFlete(flete),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Aceptar y Asignar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, {required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  void _mostrarDetallesFlete(Flete flete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('CTN ${flete.numeroContenedor}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetalleRow('Tipo', flete.tipoContenedor),
              _buildDetalleRow('Peso', '${flete.peso.toStringAsFixed(0)} kg'),
              _buildDetalleRow('Origen', flete.origen),
              _buildDetalleRow('Destino', flete.destino),
              _buildDetalleRow('Tarifa', '\$${flete.tarifa.toStringAsFixed(0)}'),
              _buildDetalleRow('Publicado', _formatearFecha(flete.fechaPublicacion)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _aceptarFlete(flete);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Aceptar Flete'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _aceptarFlete(Flete flete) {
    if (_transportistaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo identificar el transportista'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navegar a la pantalla de asignación
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AsignarFletePage(
          flete: flete,
          transportistaId: _transportistaId!,
        ),
      ),
    );
  }
}
