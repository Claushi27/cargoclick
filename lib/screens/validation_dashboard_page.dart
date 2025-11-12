import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transportista.dart';
import '../models/usuario.dart';
import '../models/camion.dart';
import '../services/validation_service.dart';
import 'package:intl/intl.dart';

class ValidationDashboardPage extends StatefulWidget {
  const ValidationDashboardPage({Key? key}) : super(key: key);

  @override
  _ValidationDashboardPageState createState() => _ValidationDashboardPageState();
}

class _ValidationDashboardPageState extends State<ValidationDashboardPage> with SingleTickerProviderStateMixin {
  final ValidationService _validationService = ValidationService();
  final String _clienteId = FirebaseAuth.instance.currentUser!.uid;
  late TabController _tabController;
  
  String _searchQuery = '';
  bool _showOnlyPending = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validación de Flota'),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.business), text: 'Transportistas'),
            Tab(icon: Icon(Icons.person), text: 'Choferes'),
            Tab(icon: Icon(Icons.local_shipping), text: 'Camiones'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_showOnlyPending ? Icons.pending_actions : Icons.check_circle),
            tooltip: _showOnlyPending ? 'Ver Validados' : 'Ver Pendientes',
            onPressed: () {
              setState(() {
                _showOnlyPending = !_showOnlyPending;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, RUT, patente...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          // Banner de filtro
          if (_showOnlyPending)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  Icon(Icons.pending_actions, color: Colors.orange.shade800),
                  const SizedBox(width: 8),
                  Text(
                    'Mostrando solo pendientes de validación',
                    style: TextStyle(color: Colors.orange.shade800),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.green.shade100,
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade800),
                  const SizedBox(width: 8),
                  Text(
                    'Mostrando entidades validadas',
                    style: TextStyle(color: Colors.green.shade800),
                  ),
                ],
              ),
            ),
          
          // Contenido de tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransportistasTab(),
                _buildChoferesTab(),
                _buildCamionesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: TRANSPORTISTAS
  Widget _buildTransportistasTab() {
    return StreamBuilder<List<Transportista>>(
      stream: _showOnlyPending
          ? _validationService.getTransportistasPendientes()
          : _validationService.getTransportistasValidados(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _showOnlyPending ? Icons.inbox_outlined : Icons.check_circle_outline,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _showOnlyPending
                      ? 'No hay transportistas pendientes'
                      : 'No hay transportistas validados',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final transportistas = snapshot.data!.where((t) {
          if (_searchQuery.isEmpty) return true;
          return t.razonSocial.toLowerCase().contains(_searchQuery) ||
              t.rutEmpresa.toLowerCase().contains(_searchQuery);
        }).toList();

        if (transportistas.isEmpty) {
          return const Center(
            child: Text('No se encontraron resultados'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transportistas.length,
          itemBuilder: (context, index) {
            final transportista = transportistas[index];
            return _buildTransportistaCard(transportista);
          },
        );
      },
    );
  }

  Widget _buildTransportistaCard(Transportista transportista) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con estado
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.business, color: Colors.blue.shade800),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transportista.razonSocial,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'RUT: ${transportista.rutEmpresa}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (transportista.isValidadoCliente)
                  Chip(
                    label: const Text('VALIDADO'),
                    backgroundColor: Colors.green,
                    labelStyle: const TextStyle(color: Colors.white),
                    avatar: const Icon(Icons.check_circle, color: Colors.white, size: 18),
                  )
                else
                  Chip(
                    label: const Text('PENDIENTE'),
                    backgroundColor: Colors.orange,
                    labelStyle: const TextStyle(color: Colors.white),
                    avatar: const Icon(Icons.pending, color: Colors.white, size: 18),
                  ),
              ],
            ),
            
            const Divider(height: 24),
            
            // Información
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.phone,
                    'Teléfono',
                    transportista.telefono,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.email,
                    'Email',
                    transportista.email,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.confirmation_number,
                    'Código Inv.',
                    transportista.codigoInvitacion,
                  ),
                ),
                if (transportista.tarifaMinima != null)
                  Expanded(
                    child: _buildInfoItem(
                      Icons.attach_money,
                      'Tarifa Mín.',
                      NumberFormat.currency(locale: 'es_CL', symbol: '\$', decimalDigits: 0)
                          .format(transportista.tarifaMinima),
                    ),
                  ),
              ],
            ),
            
            if (transportista.isValidadoCliente && transportista.fechaValidacion != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade800, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Validado el ${DateFormat('dd/MM/yyyy').format(transportista.fechaValidacion!)}',
                      style: TextStyle(fontSize: 12, color: Colors.green.shade800),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!transportista.isValidadoCliente)
                  ElevatedButton.icon(
                    onPressed: () => _validarTransportista(transportista),
                    icon: const Icon(Icons.check),
                    label: const Text('Aprobar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => _revocarValidacionTransportista(transportista),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Revocar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // TAB 2: CHOFERES
  Widget _buildChoferesTab() {
    return StreamBuilder<List<Usuario>>(
      stream: _showOnlyPending
          ? _validationService.getChoferesPendientes()
          : _validationService.getChoferesValidados(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _showOnlyPending ? Icons.inbox_outlined : Icons.check_circle_outline,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _showOnlyPending
                      ? 'No hay choferes pendientes'
                      : 'No hay choferes validados',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final choferes = snapshot.data!.where((c) {
          if (_searchQuery.isEmpty) return true;
          return c.displayName.toLowerCase().contains(_searchQuery) ||
              c.empresa.toLowerCase().contains(_searchQuery);
        }).toList();

        if (choferes.isEmpty) {
          return const Center(child: Text('No se encontraron resultados'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: choferes.length,
          itemBuilder: (context, index) {
            final chofer = choferes[index];
            return _buildChoferCard(chofer);
          },
        );
      },
    );
  }

  Widget _buildChoferCard(Usuario chofer) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.purple.shade100,
                  child: Icon(Icons.person, color: Colors.purple.shade800),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chofer.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        chofer.empresa,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (chofer.isValidadoCliente)
                  Chip(
                    label: const Text('VALIDADO'),
                    backgroundColor: Colors.green,
                    labelStyle: const TextStyle(color: Colors.white),
                    avatar: const Icon(Icons.check_circle, color: Colors.white, size: 18),
                  )
                else
                  Chip(
                    label: const Text('PENDIENTE'),
                    backgroundColor: Colors.orange,
                    labelStyle: const TextStyle(color: Colors.white),
                    avatar: const Icon(Icons.pending, color: Colors.white, size: 18),
                  ),
              ],
            ),
            
            const Divider(height: 24),
            
            // Información
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.phone,
                    'Teléfono',
                    chofer.phoneNumber,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.email,
                    'Email',
                    chofer.email,
                  ),
                ),
              ],
            ),
            
            if (chofer.isValidadoCliente && chofer.fechaValidacion != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade800, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Validado el ${DateFormat('dd/MM/yyyy').format(chofer.fechaValidacion!)}',
                      style: TextStyle(fontSize: 12, color: Colors.green.shade800),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!chofer.isValidadoCliente)
                  ElevatedButton.icon(
                    onPressed: () => _validarChofer(chofer),
                    icon: const Icon(Icons.check),
                    label: const Text('Aprobar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => _revocarValidacionChofer(chofer),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Revocar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // TAB 3: CAMIONES
  Widget _buildCamionesTab() {
    return StreamBuilder<List<Camion>>(
      stream: _showOnlyPending
          ? _validationService.getCamionesPendientes()
          : _validationService.getCamionesValidados(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _showOnlyPending ? Icons.inbox_outlined : Icons.check_circle_outline,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _showOnlyPending
                      ? 'No hay camiones pendientes'
                      : 'No hay camiones validados',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final camiones = snapshot.data!.where((c) {
          if (_searchQuery.isEmpty) return true;
          return c.patente.toLowerCase().contains(_searchQuery) ||
              c.tipo.toLowerCase().contains(_searchQuery);
        }).toList();

        if (camiones.isEmpty) {
          return const Center(child: Text('No se encontraron resultados'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: camiones.length,
          itemBuilder: (context, index) {
            final camion = camiones[index];
            return _buildCamionCard(camion);
          },
        );
      },
    );
  }

  Widget _buildCamionCard(Camion camion) {
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
      default:
        semaforoColor = Colors.red;
        semaforoIcon = Icons.error;
    }
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.indigo.shade100,
                  child: Icon(Icons.local_shipping, color: Colors.indigo.shade800),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patente: ${camion.patente}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tipo: ${camion.tipo}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (camion.isValidadoCliente)
                  Chip(
                    label: const Text('VALIDADO'),
                    backgroundColor: Colors.green,
                    labelStyle: const TextStyle(color: Colors.white),
                    avatar: const Icon(Icons.check_circle, color: Colors.white, size: 18),
                  )
                else
                  Chip(
                    label: const Text('PENDIENTE'),
                    backgroundColor: Colors.orange,
                    labelStyle: const TextStyle(color: Colors.white),
                    avatar: const Icon(Icons.pending, color: Colors.white, size: 18),
                  ),
              ],
            ),
            
            const Divider(height: 24),
            
            // Semáforo de documentación
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: semaforoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: semaforoColor),
              ),
              child: Row(
                children: [
                  Icon(semaforoIcon, color: semaforoColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estado Documentación',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Vence: ${DateFormat('dd/MM/yyyy').format(camion.docVencimiento)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Información de seguro
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield, color: Colors.blue.shade800, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Información de Seguro',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (camion.numeroPoliza.isNotEmpty) ...[
                    Text('Póliza: ${camion.numeroPoliza}', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                  ],
                  if (camion.companiaSeguro.isNotEmpty) ...[
                    Text('Compañía: ${camion.companiaSeguro}', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                  ],
                  if (camion.nombreSeguro.isNotEmpty)
                    Text('Seguro: ${camion.nombreSeguro}', style: const TextStyle(fontSize: 12)),
                  if (camion.numeroPoliza.isEmpty && camion.companiaSeguro.isEmpty && camion.nombreSeguro.isEmpty)
                    const Text(
                      'Sin información de seguro registrada',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.attach_money,
                    'Seguro Carga',
                    camion.seguroCarga,
                  ),
                ),
              ],
            ),
            
            if (camion.isValidadoCliente && camion.fechaValidacion != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade800, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Validado el ${DateFormat('dd/MM/yyyy').format(camion.fechaValidacion!)}',
                      style: TextStyle(fontSize: 12, color: Colors.green.shade800),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!camion.isValidadoCliente)
                  ElevatedButton.icon(
                    onPressed: () => _validarCamion(camion),
                    icon: const Icon(Icons.check),
                    label: const Text('Aprobar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => _revocarValidacionCamion(camion),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Revocar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper para info
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Métodos de validación
  Future<void> _validarTransportista(Transportista transportista) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Validación'),
        content: Text(
          '¿Está seguro de validar al transportista "${transportista.razonSocial}"?\n\nPodrá asignar fletes a sus choferes y camiones.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Validar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _validationService.validarTransportista(transportista.uid, _clienteId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Transportista validado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _revocarValidacionTransportista(Transportista transportista) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revocar Validación'),
        content: Text(
          '¿Está seguro de revocar la validación de "${transportista.razonSocial}"?\n\nNo podrá asignar fletes hasta que vuelva a validarlo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Revocar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _validationService.revocarValidacionTransportista(transportista.uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Validación revocada'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _validarChofer(Usuario chofer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Validación'),
        content: Text(
          '¿Está seguro de validar al chofer "${chofer.displayName}"?\n\nPodrá ser asignado a fletes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Validar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _validationService.validarChofer(chofer.uid, _clienteId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Chofer validado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _revocarValidacionChofer(Usuario chofer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revocar Validación'),
        content: Text(
          '¿Está seguro de revocar la validación de "${chofer.displayName}"?\n\nNo podrá ser asignado a fletes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Revocar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _validationService.revocarValidacionChofer(chofer.uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Validación revocada'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _validarCamion(Camion camion) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Validación'),
        content: Text(
          '¿Está seguro de validar el camión con patente "${camion.patente}"?\n\nPodrá ser asignado a fletes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Validar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _validationService.validarCamion(camion.id, _clienteId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Camión validado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _revocarValidacionCamion(Camion camion) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revocar Validación'),
        content: Text(
          '¿Está seguro de revocar la validación del camión "${camion.patente}"?\n\nNo podrá ser asignado a fletes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Revocar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _validationService.revocarValidacionCamion(camion.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Validación revocada'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
