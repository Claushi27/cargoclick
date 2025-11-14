import 'package:cloud_firestore/cloud_firestore.dart';

class Notificacion {
  final String id;
  final String userId;
  final String tipo; // 'asignacion', 'completado', 'nuevo_flete'
  final String titulo;
  final String mensaje;
  final String? fleteId;
  final DateTime createdAt;
  final bool leida;

  Notificacion({
    required this.id,
    required this.userId,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    this.fleteId,
    required this.createdAt,
    this.leida = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'tipo': tipo,
      'titulo': titulo,
      'mensaje': mensaje,
      'flete_id': fleteId,
      'created_at': Timestamp.fromDate(createdAt),
      'leida': leida,
    };
  }

  factory Notificacion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Notificacion(
      id: doc.id,
      userId: data['user_id'] ?? '',
      tipo: data['tipo'] ?? '',
      titulo: data['titulo'] ?? '',
      mensaje: data['mensaje'] ?? '',
      fleteId: data['flete_id'],
      createdAt: (data['created_at'] as Timestamp).toDate(),
      leida: data['leida'] ?? false,
    );
  }
}
