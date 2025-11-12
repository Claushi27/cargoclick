import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cargoclick/models/usuario.dart';
import 'package:cargoclick/models/transportista.dart';
import 'package:cargoclick/services/rating_service.dart';
import 'package:cargoclick/services/estadisticas_service.dart';
import 'package:cargoclick/widgets/rating_display.dart';
import 'package:cargoclick/screens/perfil_transportista_publico_page.dart';
import 'package:cargoclick/screens/perfil_chofer_publico_page.dart';

class ListaTransportistasChoferesPage extends StatelessWidget {
  const ListaTransportistasChoferesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transportistas y Choferes'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.business), text: 'Transportistas'),
              Tab(icon: Icon(Icons.person), text: 'Choferes'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ListaTransportistas(),
            _ListaChoferes(),
          ],
        ),
      ),
    );
  }
}

class _ListaTransportistas extends StatelessWidget {
  const _ListaTransportistas();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transportistas')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 8),
                  Text(
                    'Verifica los permisos de Firestore',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        var transportistas = snapshot.data?.docs ?? [];
        
        // Ordenar en memoria por razón social
        transportistas.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data() as Map<String, dynamic>;
          final razonA = (dataA['razon_social'] ?? '') as String;
          final razonB = (dataB['razon_social'] ?? '') as String;
          return razonA.toLowerCase().compareTo(razonB.toLowerCase());
        });

        if (transportistas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No hay transportistas registrados',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transportistas.length,
          itemBuilder: (context, index) {
            final data = transportistas[index].data() as Map<String, dynamic>;
            final transportista = Transportista.fromJson(data);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  // Navegar al perfil público del transportista
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PerfilTransportistaPublicoPage(
                        transportista: transportista,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.business,
                          color: Theme.of(context).colorScheme.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Información
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transportista.razonSocial,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            
                            // Rating
                            FutureBuilder<double>(
                              future: RatingService().getRatingPromedio(transportista.uid),
                              builder: (context, ratingSnapshot) {
                                if (ratingSnapshot.connectionState == ConnectionState.waiting) {
                                  return const SizedBox(
                                    height: 20,
                                    width: 120,
                                    child: Center(
                                      child: SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                  );
                                }
                                final rating = ratingSnapshot.data ?? 0.0;
                                
                                return FutureBuilder<Map<String, dynamic>>(
                                  future: RatingService().getEstadisticasRatings(transportista.uid),
                                  builder: (context, statsSnapshot) {
                                    final total = statsSnapshot.hasData 
                                        ? statsSnapshot.data!['total'] as int 
                                        : 0;
                                    
                                    return RatingDisplay(
                                      rating: rating,
                                      totalRatings: total,
                                      size: 16,
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            
                            // Info adicional
                            Row(
                              children: [
                                Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  transportista.telefono,
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
                      
                      // Indicador de tap
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ListaChoferes extends StatelessWidget {
  const _ListaChoferes();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 8),
                  Text(
                    'Verifica los permisos de Firestore',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        var allUsers = snapshot.data?.docs ?? [];
        
        // Filtrar solo choferes en memoria
        var choferes = allUsers.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final tipo = data['tipoUsuario'] ?? data['tipo_usuario'] ?? '';
          return tipo.toString().toLowerCase() == 'chofer';
        }).toList();
        
        // Ordenar en memoria por nombre
        choferes.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data() as Map<String, dynamic>;
          final nombreA = (dataA['display_name'] ?? '') as String;
          final nombreB = (dataB['display_name'] ?? '') as String;
          return nombreA.toLowerCase().compareTo(nombreB.toLowerCase());
        });

        if (choferes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No hay choferes registrados',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: choferes.length,
          itemBuilder: (context, index) {
            final data = choferes[index].data() as Map<String, dynamic>;
            final chofer = Usuario.fromJson(data);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  // Navegar al perfil público del chofer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PerfilChoferPublicoPage(
                        choferId: chofer.uid,
                        nombre: chofer.displayName,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Información
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chofer.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            
                            if (chofer.empresa.isNotEmpty)
                              Row(
                                children: [
                                  Icon(Icons.business, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      chofer.empresa,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            
                            if (chofer.transportistaId != null) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, size: 12, color: Colors.green[700]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Activo',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      // Indicador de tap
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
