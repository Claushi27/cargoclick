import 'package:cloud_firestore/cloud_firestore.dart';

class Checkpoint {
  final String id;
  final String tipo;
  final String choferId;
  final DateTime timestamp;
  final Map<String, double>? ubicacion;
  final List<FotoCheckpoint> fotos;
  final String? notas;
  final bool completado;
  final DateTime createdAt;

  Checkpoint({
    required this.id,
    required this.tipo,
    required this.choferId,
    required this.timestamp,
    this.ubicacion,
    required this.fotos,
    this.notas,
    required this.completado,
    required this.createdAt,
  });

  factory Checkpoint.fromJson(Map<String, dynamic> json, {String? docId}) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return Checkpoint(
      id: docId ?? json['id'] as String? ?? '',
      tipo: json['tipo'] as String,
      choferId: json['chofer_id'] as String,
      timestamp: parseDate(json['timestamp']),
      ubicacion: json['ubicacion'] != null
          ? Map<String, double>.from(json['ubicacion'] as Map)
          : null,
      fotos: (json['fotos'] as List<dynamic>?)
              ?.map((f) => FotoCheckpoint.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
      notas: json['notas'] as String?,
      completado: json['completado'] as bool? ?? false,
      createdAt: parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'tipo': tipo,
        'chofer_id': choferId,
        'timestamp': Timestamp.fromDate(timestamp),
        'ubicacion': ubicacion,
        'fotos': fotos.map((f) => f.toJson()).toList(),
        'notas': notas,
        'completado': completado,
        'created_at': Timestamp.fromDate(createdAt),
      };
}

class FotoCheckpoint {
  final String url;
  final String storagePath;
  final String nombre;
  final DateTime createdAt;

  FotoCheckpoint({
    required this.url,
    required this.storagePath,
    required this.nombre,
    required this.createdAt,
  });

  factory FotoCheckpoint.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return FotoCheckpoint(
      url: json['url'] as String,
      storagePath: json['storage_path'] as String,
      nombre: json['nombre'] as String,
      createdAt: parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'storage_path': storagePath,
        'nombre': nombre,
        'created_at': Timestamp.fromDate(createdAt),
      };
}
