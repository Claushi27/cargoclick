import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final String? id;
  final String fleteId;
  final String clienteId;
  final String transportistaId;
  final int estrellas; // 1-5
  final String? comentario;
  final DateTime createdAt;

  Rating({
    this.id,
    required this.fleteId,
    required this.clienteId,
    required this.transportistaId,
    required this.estrellas,
    this.comentario,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json, {String? docId}) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return Rating(
      id: docId ?? json['id'] as String?,
      fleteId: json['flete_id'] as String,
      clienteId: json['cliente_id'] as String,
      transportistaId: json['transportista_id'] as String,
      estrellas: json['estrellas'] as int,
      comentario: json['comentario'] as String?,
      createdAt: parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'flete_id': fleteId,
    'cliente_id': clienteId,
    'transportista_id': transportistaId,
    'estrellas': estrellas,
    if (comentario != null) 'comentario': comentario,
    'created_at': Timestamp.fromDate(createdAt),
  };
}
