import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cargoclick/services/flete_service.dart';
import 'package:cargoclick/services/flota_service.dart';

class ReasignarDialog extends StatefulWidget {
  final String fleteId;
  final String transportistaId;
  final String choferActualId;
  final String camionActualId;

  const ReasignarDialog({
    super.key,
    required this.fleteId,
    required this.transportistaId,
    required this.choferActualId,
    required this.camionActualId,
  });

  @override
  State<ReasignarDialog> createState() => _ReasignarDialogState();
}

class _ReasignarDialogState extends State<ReasignarDialog> {
  final _formKey = GlobalKey<FormState>();
  final _razonController = TextEditingController();
  final _flotaService = FlotaService();
  
  String? _choferSeleccionado;
  String? _camionSeleccionado;
  bool _isLoading = false;

  List<Map<String, dynamic>> _choferes = [];
  List<Map<String, dynamic>> _camiones = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      // Usar FlotaService para cargar choferes validados
      final choferes = await _flotaService.getChoferesValidados(widget.transportistaId);
      
      // Usar FlotaService para cargar camiones validados
      final camiones = await _flotaService.getCamionesValidados(widget.transportistaId);

      setState(() {
        // Convertir a Map para mantener compatibilidad
        _choferes = choferes.map((chofer) => {
          'id': chofer.uid,
          'display_name': chofer.displayName ?? 'Sin nombre',
        }).toList();

        _camiones = camiones.map((camion) => {
          'id': camion.id ?? '',
          'patente': camion.patente ?? 'Sin patente',
          'tipo': camion.tipo ?? '',
        }).toList();
        
        // Filtrar camiones sin ID
        _camiones = _camiones.where((c) => c['id'] != '').toList();
        
        // Pre-seleccionar los actuales por defecto
        _choferSeleccionado = widget.choferActualId;
        _camionSeleccionado = widget.camionActualId;
      });

      print('🚗 Choferes cargados: ${_choferes.length}');
      print('🚚 Camiones cargados: ${_camiones.length}');
      
      if (_choferes.isNotEmpty) {
        print('   Ejemplo chofer: ${_choferes.first}');
      }
      if (_camiones.isNotEmpty) {
        print('   Ejemplo camión: ${_camiones.first}');
      }
    } catch (e) {
      print('❌ Error cargando datos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmarReasignacion() async {
    if (!_formKey.currentState!.validate()) return;

    if (_choferSeleccionado == null || _camionSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un chofer y un camión'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Verificar que al menos uno sea diferente
    if (_choferSeleccionado == widget.choferActualId && 
        _camionSeleccionado == widget.camionActualId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe cambiar al menos el chofer o el camión'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Confirmación adicional
    String mensaje = '¿Está seguro de realizar este cambio?\n\n';
    
    if (_choferSeleccionado != widget.choferActualId && 
        _camionSeleccionado != widget.camionActualId) {
      mensaje += 'Se cambiará tanto el chofer como el camión.\n\n';
    } else if (_choferSeleccionado != widget.choferActualId) {
      mensaje += 'Se cambiará solo el chofer (el camión permanecerá igual).\n\n';
    } else {
      mensaje += 'Se cambiará solo el camión (el chofer permanecerá igual).\n\n';
    }
    
    mensaje += 'El cliente recibirá un email de notificación y tendrá 24 horas para rechazar este cambio.';

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Reasignación'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Confirmar Cambio'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _isLoading = true);

    try {
      final fleteService = FleteService();
      
      await fleteService.reasignarChoferCamion(
        fleteId: widget.fleteId,
        transportistaId: widget.transportistaId,
        nuevoChoferId: _choferSeleccionado!,
        nuevoCamionId: _camionSeleccionado!,
        razon: _razonController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Reasignación completada. El cliente ha sido notificado.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.swap_horiz,
                        color: Colors.orange.shade700,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cambiar Asignación',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Reasignar chofer y camión',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Alerta
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'El cliente recibirá un email y tendrá 24 horas para rechazar el cambio.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Dropdown Chofer
                const Text(
                  'Chofer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                if (_choferes.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'No hay choferes disponibles para seleccionar',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: _choferSeleccionado,
                    isExpanded: true,
                    decoration: InputDecoration(
                      hintText: 'Seleccionar chofer',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: _choferSeleccionado == widget.choferActualId 
                          ? '✓ Chofer actual (sin cambio)' 
                          : null,
                      helperStyle: const TextStyle(color: Colors.green),
                    ),
                    items: _choferes.map((chofer) {
                      final esActual = chofer['id'] == widget.choferActualId;
                      final nombre = chofer['display_name']?.toString() ?? 'Sin nombre';
                      
                      return DropdownMenuItem<String>(
                        value: chofer['id']?.toString(),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                nombre,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (esActual) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Actual',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _choferSeleccionado = value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Debe seleccionar un chofer';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),

                // Dropdown Camión
                const Text(
                  'Camión',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _camionSeleccionado,
                  decoration: InputDecoration(
                    hintText: 'Seleccionar camión',
                    prefixIcon: const Icon(Icons.local_shipping),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    helperText: _camionSeleccionado == widget.camionActualId 
                        ? '✓ Camión actual (sin cambio)' 
                        : null,
                    helperStyle: const TextStyle(color: Colors.green),
                  ),
                  items: _camiones.map((camion) {
                    final esActual = camion['id'] == widget.camionActualId;
                    return DropdownMenuItem<String>(
                      value: camion['id'],
                      child: Row(
                        children: [
                          Text(
                            camion['patente'] ?? 'Sin patente',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '- ${camion['tipo'] ?? ''}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          if (esActual) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Actual',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _camionSeleccionado = value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Debe seleccionar un camión';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // TextField Razón
                const Text(
                  'Motivo del Cambio',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _razonController,
                  decoration: InputDecoration(
                    hintText: 'Ej: Camión tuvo falla mecánica',
                    prefixIcon: const Icon(Icons.edit_note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Debe indicar el motivo del cambio';
                    }
                    if (value.trim().length < 10) {
                      return 'El motivo debe tener al menos 10 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _confirmarReasignacion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Confirmar Cambio',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _razonController.dispose();
    super.dispose();
  }
}
