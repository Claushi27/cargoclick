import 'package:flutter/material.dart';
import 'package:cargoclick/services/auth_service.dart';
import 'package:cargoclick/services/flete_service.dart';
import 'package:cargoclick/models/usuario.dart';
import 'package:cargoclick/models/flete.dart';
import 'package:cargoclick/screens/login_page.dart';
import 'package:cargoclick/screens/publicar_flete_page.dart';
import 'package:cargoclick/screens/mis_recorridos_page.dart';
import 'package:cargoclick/screens/solicitudes_page.dart';
import 'package:cargoclick/screens/galeria_fletes_page.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsuario();
  }

  Future<void> _loadUsuario() async {
    try {
      final usuario = await _authService.getCurrentUsuario();
      if (usuario == null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        return;
      }
      setState(() {
        _usuario = usuario;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
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
    try {
      await _fleteService.aceptarFlete(fleteId, _usuario!.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Flete aceptado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
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

    final isCliente = _usuario?.tipoUsuario == 'Cliente';

    if (!isCliente) {
      // Vista Chofer: Tabs Disponibles / Mis Recorridos
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Fletes'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Disponibles', icon: Icon(Icons.list_alt)),
                Tab(text: 'Mis Recorridos', icon: Icon(Icons.route_outlined)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logout,
                tooltip: 'Cerrar Sesión',
              ),
            ],
          ),
          body: TabBarView(
            children: [
              // Disponibles
              StreamBuilder<List<Flete>>(
                stream: _fleteService.getFletesDisponibles(),
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
                          const Text('No hay fletes disponibles'),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: fletes.length,
                    itemBuilder: (context, index) {
                      final flete = fletes[index];
                      return FleteCard(
                        flete: flete,
                        isCliente: false,
                        onAceptar: () => _aceptarFlete(flete.id!),
                      );
                    },
                  );
                },
              ),
              // Mis Recorridos
              MisRecorridosPage(choferId: _usuario!.uid),
            ],
          ),
        ),
      );
    }

    // Vista Cliente (único): Mis fletes + accesos a Solicitudes y Galería
    return Scaffold(
      appBar: AppBar(
        title: const Text('CargoClick'),
        actions: [
          IconButton(
            tooltip: 'Solicitudes',
            icon: const Icon(Icons.how_to_reg_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SolicitudesPage(clienteId: _usuario!.uid)),
              );
            },
          ),
          IconButton(
            tooltip: 'Galería de Fletes',
            icon: const Icon(Icons.photo_library_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => GaleriaFletesPage(clienteId: _usuario!.uid)),
              );
            },
          ),
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
              return FleteCard(
                flete: flete,
                isCliente: true,
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
