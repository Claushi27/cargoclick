import 'package:flutter/material.dart';
import 'package:cargoclick/services/auth_service.dart';
import 'package:cargoclick/services/flete_service.dart';
import 'package:cargoclick/models/usuario.dart';
import 'package:cargoclick/models/transportista.dart';
import 'package:cargoclick/models/flete.dart';
import 'package:cargoclick/screens/login_page.dart';
import 'package:cargoclick/screens/publicar_flete_page.dart';
import 'package:cargoclick/screens/mis_recorridos_page.dart';
// import 'package:cargoclick/screens/solicitudes_page.dart'; // DEPRECATED: Ya no se usa (flujo directo por transportista)
import 'package:cargoclick/screens/fletes_cliente_detalle_page.dart';
import 'package:cargoclick/screens/perfil_transportista_page.dart';
import 'package:cargoclick/screens/gestion_flota_page.dart';
import 'package:cargoclick/screens/fletes_disponibles_transportista_page.dart';
import 'package:cargoclick/screens/fletes_asignados_transportista_page.dart';
import 'package:cargoclick/screens/lista_transportistas_choferes_page.dart';
import 'package:cargoclick/screens/validation_dashboard_page.dart'; // MÓDULO 1
import 'package:cargoclick/widgets/flete_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authService = AuthService();
  final _fleteService = FleteService();
  Usuario? _usuario;
  Transportista? _transportista;
  bool _isLoading = true;
  String? _tipoUsuario; // 'Cliente', 'Chofer', o 'Transportista'

  @override
  void initState() {
    super.initState();
    _loadUsuario();
  }

  Future<void> _loadUsuario() async {
    try {
      final currentUser = _authService.currentUser;
      print('🔄 [loadUsuario] Iniciando carga de usuario...');
      print('🔍 [loadUsuario] UID actual: ${currentUser?.uid}');
      print('🔍 [loadUsuario] Email actual: ${currentUser?.email}');
      
      // Primero intentar cargar como transportista (más específico)
      final transportista = await _authService.getCurrentTransportista();
      
      if (transportista != null) {
        print('✅ [loadUsuario] TRANSPORTISTA encontrado: ${transportista.razonSocial}');
        print('✅ [loadUsuario] UID: ${transportista.uid}');
        print('✅ [loadUsuario] Código: ${transportista.codigoInvitacion}');
        setState(() {
          _transportista = transportista;
          _tipoUsuario = 'Transportista';
          _usuario = null; // Asegurar que usuario es null
          _isLoading = false;
        });
        return;
      }

      print('⚠️ [loadUsuario] No es transportista, intentando usuario regular...');

      // Si no es transportista, intentar cargar como usuario (Cliente o Chofer)
      final usuario = await _authService.getCurrentUsuario();
      
      if (usuario != null) {
        print('✅ [loadUsuario] USUARIO encontrado: ${usuario.tipoUsuario} - ${usuario.displayName}');
        print('✅ [loadUsuario] UID: ${usuario.uid}');
        setState(() {
          _usuario = usuario;
          _tipoUsuario = usuario.tipoUsuario;
          _transportista = null; // Asegurar que transportista es null
          _isLoading = false;
        });
        return;
      }

      print('❌ [loadUsuario] No se encontró usuario ni transportista, redirigiendo al login...');

      // Si no es ni usuario ni transportista, redirigir al login
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      print('💥 [loadUsuario] Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<void> _aceptarFlete(String fleteId) async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _fleteService.aceptarFlete(fleteId, _usuario!.uid);
      if (mounted) {
        Navigator.pop(context); // Cerrar loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Flete aceptado exitosamente!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar loading
        
        // Mensaje más detallado del error
        String errorMsg = 'Error desconocido';
        if (e.toString().contains('permission')) {
          errorMsg = 'Error de permisos. Verifica las reglas de Firestore.';
        } else if (e.toString().contains('no está disponible')) {
          errorMsg = 'Este flete ya no está disponible';
        } else {
          errorMsg = e.toString();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // DEBUG: Ver qué tipo de usuario es
    print('🏗️ BUILD - _tipoUsuario: $_tipoUsuario');
    print('🏗️ BUILD - _usuario: ${_usuario?.tipoUsuario}');
    print('🏗️ BUILD - _transportista: ${_transportista?.razonSocial}');
    print('🏗️ BUILD - Mostrando vista: ${_tipoUsuario ?? "DESCONOCIDO"}');

    // Vista Transportista
    if (_tipoUsuario == 'Transportista' && _transportista != null) {
      print('✅ Renderizando vista TRANSPORTISTA');
      return _buildTransportistaHome();
    }

    // Vista Cliente
    if (_tipoUsuario == 'Cliente' && _usuario != null) {
      print('✅ Renderizando vista CLIENTE');
      return _buildClienteHome();
    }

    // Vista Chofer
    if (_tipoUsuario == 'Chofer' && _usuario != null) {
      print('✅ Renderizando vista CHOFER');
      return _buildChoferHome();
    }

    // Fallback - no debería llegar aquí
    print('⚠️ FALLBACK - Mostrando vista chofer por defecto');
    return _buildChoferHome();
  }

  // HOME DEL TRANSPORTISTA
  Widget _buildTransportistaHome() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, ${_transportista!.razonSocial}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PerfilTransportistaPage()),
              );
            },
            tooltip: 'Mi Perfil',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card de bienvenida
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.business,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transportista',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            Text(
                              _transportista!.razonSocial,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'RUT: ${_transportista!.rutEmpresa}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Opciones principales
          _buildMenuOption(
            context,
            icon: Icons.list_alt,
            title: 'Fletes Disponibles',
            subtitle: 'Ver y aceptar fletes publicados',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FletesDisponiblesTransportistaPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildMenuOption(
            context,
            icon: Icons.assignment,
            title: 'Mis Fletes Asignados',
            subtitle: 'Ver fletes que he aceptado',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FletesAsignadosTransportistaPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildMenuOption(
            context,
            icon: Icons.local_shipping,
            title: 'Gestión de Flota',
            subtitle: 'Administrar camiones y choferes',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GestionFlotaPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildMenuOption(
            context,
            icon: Icons.vpn_key,
            title: 'Mi Código de Invitación',
            subtitle: 'Ver y compartir con choferes',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PerfilTransportistaPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  // HOME DEL CHOFER
  Widget _buildChoferHome() {
    return DefaultTabController(
      length: 1, // Solo "Mis Recorridos" para choferes
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Recorridos'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Cerrar Sesión',
            ),
          ],
        ),
        body: MisRecorridosPage(choferId: _usuario!.uid),
      ),
    );
  }

  // HOME DEL CLIENTE (Original)
  Widget _buildClienteHome() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CargoClick'),
        actions: [
          // MÓDULO 1: Botón Validar Flota
          IconButton(
            tooltip: 'Validar Flota',
            icon: const Icon(Icons.verified_user),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ValidationDashboardPage(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Ver Transportistas y Choferes',
            icon: const Icon(Icons.people_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ListaTransportistasChoferesPage()),
              );
            },
          ),
          // DEPRECATED: Botón de solicitudes comentado (ya no se usa flujo de solicitudes)
          // IconButton(
          //   tooltip: 'Solicitudes',
          //   icon: const Icon(Icons.how_to_reg_outlined),
          //   onPressed: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(builder: (context) => SolicitudesPage(clienteId: _usuario!.uid)),
          //     );
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: StreamBuilder<List<Flete>>(
        stream: _fleteService.getFletesCliente(_usuario!.uid),
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
                  Icon(Icons.inventory_2_outlined, size: 80, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  const Text('No tienes fletes publicados'),
                  const SizedBox(height: 8),
                  Text(
                    'Toca el botón + para publicar uno',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: fletes.length,
            itemBuilder: (context, index) {
              final flete = fletes[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FletesClienteDetallePage(flete: flete),
                    ),
                  );
                },
                child: FleteCard(
                  flete: flete,
                  isCliente: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => PublicarFletePage(clienteId: _usuario!.uid)),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
