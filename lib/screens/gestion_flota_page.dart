import 'package:flutter/material.dart';
import 'package:cargoclick/services/auth_service.dart';
import 'package:cargoclick/services/flota_service.dart';
import 'package:cargoclick/models/camion.dart';
import 'package:cargoclick/models/usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GestionFlotaPage extends StatefulWidget {
  const GestionFlotaPage({super.key});

  @override
  State<GestionFlotaPage> createState() => _GestionFlotaPageState();
}

class _GestionFlotaPageState extends State<GestionFlotaPage> with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _flotaService = FlotaService();
  late TabController _tabController;
  String? _transportistaId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarTransportistaId();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarTransportistaId() async {
    try {
      final transportista = await _authService.getCurrentTransportista();
      if (mounted) {
        setState(() {
          _transportistaId = transportista?.uid;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Flota'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.local_shipping), text: 'Camiones'),
            Tab(icon: Icon(Icons.person), text: 'Choferes'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transportistaId == null
              ? const Center(child: Text('No se pudo cargar la información'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCamionesTab(),
                    _buildChoferesTab(),
                  ],
                ),
      floatingActionButton: _transportistaId != null && _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => _mostrarDialogoAgregarCamion(context),
              icon: const Icon(Icons.add),
              label: const Text('Agregar Camión'),
            )
          : null,
    );
  }

  Widget _buildCamionesTab() {
    return StreamBuilder<List<Camion>>(
      stream: _flotaService.obtenerCamionesTransportista(_transportistaId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final camiones = snapshot.data ?? [];

        if (camiones.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No hay camiones registrados',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Agrega tu primer camión con el botón +',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: camiones.length,
          itemBuilder: (context, index) => _buildCamionCard(camiones[index]),
        );
      },
    );
  }

  Widget _buildCamionCard(Camion camion) {
    Color semaforoColor;
    IconData semaforoIcon;
    String semaforoTexto;

    switch (camion.estadoDocumentacion) {
      case 'ok':
        semaforoColor = Colors.green;
        semaforoIcon = Icons.check_circle;
        semaforoTexto = 'Documentos OK';
        break;
      case 'proximo_vencer':
        semaforoColor = Colors.orange;
        semaforoIcon = Icons.warning;
        semaforoTexto = 'Próximo a vencer';
        break;
      case 'vencido':
        semaforoColor = Colors.red;
        semaforoIcon = Icons.error;
        semaforoTexto = 'Documentos vencidos';
        break;
      default:
        semaforoColor = Colors.grey;
        semaforoIcon = Icons.help;
        semaforoTexto = 'Desconocido';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _mostrarDialogoEditarCamion(context, camion),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_shipping,
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
                          camion.patente,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          camion.tipo,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    semaforoIcon,
                    color: semaforoColor,
                    size: 32,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      context,
                      icon: Icons.security,
                      label: 'Seguro: \$${camion.seguroCarga}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      context,
                      icon: Icons.calendar_today,
                      label: 'Vence: ${_formatearFecha(camion.docVencimiento)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: semaforoColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: semaforoColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(semaforoIcon, color: semaforoColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      semaforoTexto,
                      style: TextStyle(
                        color: semaforoColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
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

  Widget _buildChoferesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('transportista_id', isEqualTo: _transportistaId)
          .where('tipo_usuario', isEqualTo: 'Chofer')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final choferes = snapshot.data?.docs ?? [];

        if (choferes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No hay choferes registrados',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Los choferes deben registrarse con tu código',
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
          itemCount: choferes.length,
          itemBuilder: (context, index) {
            final choferData = choferes[index].data() as Map<String, dynamic>;
            final chofer = Usuario.fromJson(choferData);
            return _buildChoferCard(chofer);
          },
        );
      },
    );
  }

  Widget _buildChoferCard(Usuario chofer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
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
                    chofer.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chofer.email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  if (chofer.phoneNumber.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          chofer.phoneNumber,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'Activo',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  // Continúa en el siguiente bloque...
  void _mostrarDialogoAgregarCamion(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final patenteController = TextEditingController();
    final seguroController = TextEditingController();
    final numeroPolizaController = TextEditingController();
    final companiaSeguroController = TextEditingController();
    final nombreSeguroController = TextEditingController();
    DateTime? fechaVencimiento;
    String tipoSeleccionado = 'Plana';

    final tiposCamion = [
      'CTN Std 20',
      'CTN Std 40',
      'HC',
      'OT',
      'reefer',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar Camión'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: patenteController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Patente',
                      prefixIcon: Icon(Icons.confirmation_number),
                      hintText: 'ABCD12',
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingresa la patente' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: tipoSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Contenedor',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: tiposCamion
                        .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                        .toList(),
                    onChanged: (valor) {
                      if (valor != null) {
                        setDialogState(() => tipoSeleccionado = valor);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: seguroController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Monto del Seguro',
                      prefixIcon: Icon(Icons.security),
                      prefixText: '\$ ',
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingresa el monto' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // MÓDULO 1: Campos adicionales de seguro
                  const Divider(),
                  const Text(
                    'Información de Póliza',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: numeroPolizaController,
                    decoration: const InputDecoration(
                      labelText: 'Número de Póliza *',
                      prefixIcon: Icon(Icons.policy),
                      hintText: 'Ej: 123456789',
                      helperText: 'Número identificador de la póliza',
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingresa el número de póliza' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: companiaSeguroController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Compañía de Seguro *',
                      prefixIcon: Icon(Icons.business),
                      hintText: 'Ej: Chilena Consolidada',
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingresa la compañía' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nombreSeguroController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Seguro *',
                      prefixIcon: Icon(Icons.shield),
                      hintText: 'Ej: Seguro Todo Riesgo',
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingresa el nombre del seguro' : null,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      fechaVencimiento == null
                          ? 'Fecha de Vencimiento'
                          : 'Vence: ${_formatearFecha(fechaVencimiento!)}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final fecha = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 365)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (fecha != null) {
                        setDialogState(() => fechaVencimiento = fecha);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate() && fechaVencimiento != null) {
                  try {
                    await _flotaService.crearCamion(
                      transportistaId: _transportistaId!,
                      patente: patenteController.text.toUpperCase(),
                      tipo: tipoSeleccionado,
                      seguroCarga: seguroController.text,
                      docVencimiento: fechaVencimiento!,
                      numeroPoliza: numeroPolizaController.text,
                      companiaSeguro: companiaSeguroController.text,
                      nombreSeguro: nombreSeguroController.text,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Camión agregado exitosamente')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } else if (fechaVencimiento == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Selecciona la fecha de vencimiento')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoEditarCamion(BuildContext context, Camion camion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Camión ${camion.patente}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                _mostrarDialogoEditarCamionForm(context, camion);
              },
            ),
            ListTile(
              leading: Icon(
                camion.disponible ? Icons.block : Icons.check_circle,
                color: camion.disponible ? Colors.orange : Colors.green,
              ),
              title: Text(camion.disponible ? 'Marcar como No Disponible' : 'Marcar como Disponible'),
              onTap: () async {
                try {
                  await _flotaService.actualizarCamion(
                    camionId: camion.id,
                    disponible: !camion.disponible,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Estado actualizado')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmarEliminarCamion(context, camion);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoEditarCamionForm(BuildContext context, Camion camion) {
    final formKey = GlobalKey<FormState>();
    final patenteController = TextEditingController(text: camion.patente);
    final seguroController = TextEditingController(text: camion.seguroCarga);
    DateTime? fechaVencimiento = camion.docVencimiento;
    String tipoSeleccionado = camion.tipo;

    final tiposCamion = [
      'Plana',
      'Chasis',
      'Multiproposito',
      'Furgón',
      'Reefer',
      'Equipo Especial',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Camión'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: patenteController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Patente',
                      prefixIcon: Icon(Icons.confirmation_number),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingresa la patente' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: tipoSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Rampla',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: tiposCamion
                        .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                        .toList(),
                    onChanged: (valor) {
                      if (valor != null) {
                        setDialogState(() => tipoSeleccionado = valor);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: seguroController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Monto del Seguro',
                      prefixIcon: Icon(Icons.security),
                      prefixText: '\$ ',
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingresa el monto' : null,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text('Vence: ${_formatearFecha(fechaVencimiento!)}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final fecha = await showDatePicker(
                        context: context,
                        initialDate: fechaVencimiento,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (fecha != null) {
                        setDialogState(() => fechaVencimiento = fecha);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await _flotaService.actualizarCamion(
                      camionId: camion.id,
                      patente: patenteController.text.toUpperCase(),
                      tipo: tipoSeleccionado,
                      seguroCarga: seguroController.text,
                      docVencimiento: fechaVencimiento,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Camión actualizado')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminarCamion(BuildContext context, Camion camion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de eliminar el camión ${camion.patente}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _flotaService.eliminarCamion(camion.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Camión eliminado')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
