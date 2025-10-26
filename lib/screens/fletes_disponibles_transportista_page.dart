import 'package:flutter/material.dart';
import 'package:cargoclick/services/flete_service.dart';
import 'package:cargoclick/services/auth_service.dart';
import 'package:cargoclick/models/flete.dart';
import 'package:cargoclick/screens/asignar_flete_page.dart';
import 'package:cargoclick/widgets/flete_card_transportista.dart';
import 'package:intl/intl.dart';

class FletesDisponiblesTransportistaPage extends StatefulWidget {
  const FletesDisponiblesTransportistaPage({super.key});

  @override
  State<FletesDisponiblesTransportistaPage> createState() => _FletesDisponiblesTransportistaPageState();
}

class _FletesDisponiblesTransportistaPageState extends State<FletesDisponiblesTransportistaPage> {
  final _fleteService = FleteService();
  final _authService = AuthService();
  String? _transportistaId;
  
  // Filtros
  String? _filtroTipoContenedor;
  double _tarifaMinima = 0;
  double _tarifaMaxima = 10000000;
  bool _mostrarFiltros = false;

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
        actions: [
          IconButton(
            icon: Icon(_mostrarFiltros ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () => setState(() => _mostrarFiltros = !_mostrarFiltros),
            tooltip: 'Filtros',
          ),
        ],
      ),
      body: Column(
        children: [
          // Panel de filtros
          if (_mostrarFiltros) _buildFiltrosPanel(),
          
          // Lista de fletes
          Expanded(
            child: StreamBuilder<List<Flete>>(
              stream: _fleteService.getFletesDisponiblesTransportista(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                final fletesSinFiltrar = snapshot.data ?? [];
                final fletes = _aplicarFiltros(fletesSinFiltrar);

                if (fletes.isEmpty && fletesSinFiltrar.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No hay fletes que coincidan con los filtros',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _limpiarFiltros,
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Limpiar filtros'),
                        ),
                      ],
                    ),
                  );
                }

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
                  itemBuilder: (context, index) {
                    return FleteCardTransportista(
                      flete: fletes[index],
                      onTap: () => _mostrarDetallesFlete(fletes[index]),
                      onAceptar: () => _aceptarFlete(fletes[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltrosPanel() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Filtros',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _limpiarFiltros,
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Limpiar'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Filtro por tipo de contenedor
          Text(
            'Tipo de Contenedor',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFiltroChip('Todos', null),
              _buildFiltroChip('Std 20\'', 'CTN Std 20'),
              _buildFiltroChip('Std 40\'', 'CTN Std 40'),
              _buildFiltroChip('HC', 'HC'),
              _buildFiltroChip('OT', 'OT'),
              _buildFiltroChip('Reefer', 'reefer'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Filtro por rango de tarifa
          Text(
            'Rango de Tarifa: \$${NumberFormat('#,###', 'es_CL').format(_tarifaMinima)} - \$${NumberFormat('#,###', 'es_CL').format(_tarifaMaxima)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: RangeValues(_tarifaMinima, _tarifaMaxima),
            min: 0,
            max: 10000000,
            divisions: 100,
            labels: RangeLabels(
              '\$${NumberFormat.compact(locale: 'es_CL').format(_tarifaMinima)}',
              '\$${NumberFormat.compact(locale: 'es_CL').format(_tarifaMaxima)}',
            ),
            onChanged: (values) {
              setState(() {
                _tarifaMinima = values.start;
                _tarifaMaxima = values.end;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroChip(String label, String? valor) {
    final seleccionado = _filtroTipoContenedor == valor;
    
    return FilterChip(
      label: Text(label),
      selected: seleccionado,
      onSelected: (selected) {
        setState(() => _filtroTipoContenedor = valor);
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  List<Flete> _aplicarFiltros(List<Flete> fletes) {
    return fletes.where((flete) {
      // Filtro por tipo de contenedor
      if (_filtroTipoContenedor != null && 
          !flete.tipoContenedor.contains(_filtroTipoContenedor!)) {
        return false;
      }
      
      // Filtro por rango de tarifa
      if (flete.tarifa < _tarifaMinima || flete.tarifa > _tarifaMaxima) {
        return false;
      }
      
      return true;
    }).toList();
  }

  void _limpiarFiltros() {
    setState(() {
      _filtroTipoContenedor = null;
      _tarifaMinima = 0;
      _tarifaMaxima = 10000000;
    });
  }

  void _mostrarDetallesFlete(Flete flete) {
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
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Contenido
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Título
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.inventory_2, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CTN ${flete.numeroContenedor}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                flete.tipoContenedor,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    // Detalles organizados
                    _buildSeccionDetalle(context, 'Información General', [
                      if (flete.pesoCargaNeta != null)
                        _buildDetalleRow('Carga Neta', '${NumberFormat('#,###', 'es_CL').format(flete.pesoCargaNeta)} kg'),
                      if (flete.pesoTara != null)
                        _buildDetalleRow('Tara', '${NumberFormat('#,###', 'es_CL').format(flete.pesoTara)} kg'),
                      _buildDetalleRow('Peso Total', '${NumberFormat('#,###', 'es_CL').format(flete.peso)} kg'),
                      _buildDetalleRow('Tarifa', '\$${NumberFormat('#,###', 'es_CL').format(flete.tarifa)}'),
                    ]),
                    
                    const SizedBox(height: 16),
                    
                    _buildSeccionDetalle(context, 'Origen', [
                      _buildDetalleRow('Ciudad/Puerto', flete.origen),
                      if (flete.puertoOrigen != null)
                        _buildDetalleRow('Puerto Específico', flete.puertoOrigen!),
                      if (flete.fechaHoraCarga != null)
                        _buildDetalleRow('Fecha/Hora Carga', 
                          DateFormat('dd/MM/yyyy - HH:mm').format(flete.fechaHoraCarga!)),
                    ]),
                    
                    const SizedBox(height: 16),
                    
                    _buildSeccionDetalle(context, 'Destino', [
                      _buildDetalleRow('Ciudad/Región', flete.destino),
                      if (flete.direccionDestino != null)
                        _buildDetalleRow('Dirección Completa', flete.direccionDestino!),
                    ]),
                    
                    if (flete.devolucionCtnVacio != null || 
                        flete.requisitosEspeciales != null || 
                        flete.serviciosAdicionales != null) ...[
                      const SizedBox(height: 16),
                      
                      _buildSeccionDetalle(context, 'Información Adicional', [
                        if (flete.devolucionCtnVacio != null)
                          _buildDetalleRow('Devolución CTN Vacío', flete.devolucionCtnVacio!),
                        if (flete.requisitosEspeciales != null)
                          _buildDetalleRow('Requisitos Especiales', flete.requisitosEspeciales!),
                        if (flete.serviciosAdicionales != null)
                          _buildDetalleRow('Servicios Adicionales', flete.serviciosAdicionales!),
                      ]),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    _buildSeccionDetalle(context, 'Fecha de Publicación', [
                      _buildDetalleRow('Publicado', DateFormat('dd/MM/yyyy HH:mm').format(flete.fechaPublicacion)),
                    ]),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              
              // Botones de acción
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cerrar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _aceptarFlete(flete);
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Aceptar Flete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeccionDetalle(BuildContext context, String titulo, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
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
