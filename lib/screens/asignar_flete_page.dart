import 'package:flutter/material.dart';
import 'package:cargoclick/models/flete.dart';
import 'package:cargoclick/models/usuario.dart';
import 'package:cargoclick/models/camion.dart';
import 'package:cargoclick/services/flota_service.dart';
import 'package:cargoclick/services/flete_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AsignarFletePage extends StatefulWidget {
  final Flete flete;
  final String transportistaId;

  const AsignarFletePage({
    super.key,
    required this.flete,
    required this.transportistaId,
  });

  @override
  State<AsignarFletePage> createState() => _AsignarFletePageState();
}

class _AsignarFletePageState extends State<AsignarFletePage> {
  final _floteService = FlotaService();
  final _fleteService = FleteService();
  
  Usuario? _choferSeleccionado;
  Camion? _camionSeleccionado;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar Flete'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info del flete
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Flete a Asignar',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.inventory_2, 'CTN', widget.flete.numeroContenedor),
                    _buildInfoRow(Icons.category, 'Tipo', widget.flete.tipoContenedor),
                    _buildInfoRow(Icons.scale, 'Peso', '${widget.flete.peso.toStringAsFixed(0)} kg'),
                    _buildInfoRow(Icons.location_on, 'Ruta', '${widget.flete.origen} → ${widget.flete.destino}'),
                    _buildInfoRow(Icons.attach_money, 'Tarifa', '\$${widget.flete.tarifa.toStringAsFixed(0)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Selección de chofer
            Text(
              'Seleccionar Chofer',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // MÓDULO 1: Banner informativo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade800, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Solo se muestran choferes validados por el cliente',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // MÓDULO 1: Usar FutureBuilder con choferes validados
            FutureBuilder<List<Usuario>>(
              future: _floteService.getChoferesValidados(widget.transportistaId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final choferes = snapshot.data ?? [];

                if (choferes.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No tienes choferes validados. El cliente debe aprobar a tus choferes desde el Dashboard de Validación.',
                            style: TextStyle(color: Colors.orange.shade900),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: choferes.map((chofer) {
                    final isSelected = _choferSeleccionado?.uid == chofer.uid;

                    return Card(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      child: ListTile(
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.primaryContainer,
                              child: Icon(
                                Icons.person,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            // Badge validado
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                chofer.displayName,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : null,
                                ),
                              ),
                            ),
                            // Badge VALIDADO
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.shade300),
                              ),
                              child: Text(
                                'VALIDADO',
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(chofer.email),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                            : null,
                        onTap: () => setState(() => _choferSeleccionado = chofer),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            // Selección de camión
            Text(
              'Seleccionar Camión',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // MÓDULO 1: Banner informativo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade800, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Solo se muestran camiones validados por el cliente',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // MÓDULO 1: Usar FutureBuilder con camiones validados
            FutureBuilder<List<Camion>>(
              future: _floteService.getCamionesValidados(widget.transportistaId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final camiones = snapshot.data ?? [];

                if (camiones.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No tienes camiones validados. El cliente debe aprobar tus camiones desde el Dashboard de Validación.',
                            style: TextStyle(color: Colors.orange.shade900),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: camiones.map((camion) {
                    final isSelected = _camionSeleccionado?.id == camion.id;
                    Color semaforoColor;
                    IconData semaforoIcon;

                    switch (camion.estadoDocumentacion) {
                      case 'ok':
                        semaforoColor = Colors.green;
                        semaforoIcon = Icons.check_circle;
                        break;
                      case 'proximo_vencer':
                        semaforoColor = Colors.orange;
                        semaforoIcon = Icons.warning;
                        break;
                      case 'vencido':
                        semaforoColor = Colors.red;
                        semaforoIcon = Icons.error;
                        break;
                      default:
                        semaforoColor = Colors.grey;
                        semaforoIcon = Icons.help;
                    }

                    return Card(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      child: ListTile(
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.primaryContainer,
                              child: Icon(
                                Icons.local_shipping,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            // Badge validado
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Row(
                          children: [
                            Text(
                              camion.patente,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Badge VALIDADO
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.shade300),
                              ),
                              child: Text(
                                'VALIDADO',
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text('${camion.tipo} - Seguro: \$${camion.seguroCarga}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(semaforoIcon, color: semaforoColor, size: 24),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                            ],
                          ],
                        ),
                        onTap: () => setState(() => _camionSeleccionado = camion),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 32),

            // Botón de confirmar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _choferSeleccionado != null && _camionSeleccionado != null && !_isLoading
                    ? _confirmarAsignacion
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Confirmar Asignación',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarAsignacion() async {
    if (_choferSeleccionado == null || _camionSeleccionado == null) return;

    // Confirmar si camión tiene documentos vencidos
    if (_camionSeleccionado!.estadoDocumentacion == 'vencido') {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('⚠️ Advertencia'),
          content: Text(
            'El camión ${_camionSeleccionado!.patente} tiene documentación vencida. ¿Deseas continuar de todas formas?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Continuar'),
            ),
          ],
        ),
      );

      if (confirmar != true) return;
    }

    setState(() => _isLoading = true);

    try {
      await _fleteService.asignarFlete(
        fleteId: widget.flete.id!,
        transportistaId: widget.transportistaId,
        choferId: _choferSeleccionado!.uid,
        camionId: _camionSeleccionado!.id,
      );

      if (mounted) {
        // Mostrar éxito y volver
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Flete asignado a ${_choferSeleccionado!.displayName}',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Volver a la lista de fletes
        Navigator.pop(context); // Salir de AsignarFletePage
        Navigator.pop(context); // Salir de FletesDisponibles
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        
        // Extraer mensaje más limpio
        String mensaje = e.toString();
        IconData icono = Icons.error_outline;
        
        if (mensaje.contains('ya tiene un flete activo')) {
          // Extraer el número de contenedor si existe
          final match = RegExp(r'\(([^)]+)\)').firstMatch(mensaje);
          final contenedor = match?.group(1) ?? 'sin número';
          
          if (mensaje.contains('chofer')) {
            mensaje = 'Chofer ocupado en contenedor $contenedor';
            icono = Icons.person_off;
          } else {
            mensaje = 'Camión ocupado en contenedor $contenedor';
            icono = Icons.local_shipping_outlined;
          }
        } else if (mensaje.contains('StateError:')) {
          mensaje = mensaje.replaceAll('StateError:', '').trim();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(icono, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mensaje,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
