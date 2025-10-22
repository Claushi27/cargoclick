import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GaleriaFletesPage extends StatefulWidget {
  final String clienteId;
  const GaleriaFletesPage({super.key, required this.clienteId});

  @override
  State<GaleriaFletesPage> createState() => _GaleriaFletesPageState();
}

class _GaleriaFletesPageState extends State<GaleriaFletesPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galería de Fletes'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Filtrar por flete, chofer o fecha (texto)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('fotos')
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final docs = snapshot.data?.docs ?? [];
                final filtered = docs.where((d) {
                  final data = d.data();
                  final url = data['url'] as String? ?? '';
                  final choferId = data['chofer_id'] as String? ?? '';
                  final createdAt = (data['created_at'] as Timestamp?)?.toDate().toString() ?? '';
                  final parentPath = d.reference.parent.parent?.id ?? '';// fleteId
                  final text = '$url $choferId $createdAt $parentPath'.toLowerCase();
                  if (_query.isEmpty) return true;
                  return text.contains(_query);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('Sin fotos para mostrar'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final d = filtered[index];
                    final data = d.data();
                    final url = data['url'] as String? ?? '';
                    final fleteId = d.reference.parent.parent?.id ?? '';
                    final choferId = data['chofer_id'] as String? ?? '';
                    final fecha = (data['created_at'] as Timestamp?)?.toDate();
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: Image.network(url, fit: BoxFit.cover),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Flete: $fleteId'),
                                      Text('Chofer: $choferId'),
                                      if (fecha != null) Text('Fecha: $fecha'),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(url, fit: BoxFit.cover),
                      ),
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
}
