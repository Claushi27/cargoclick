import 'package:cloud_firestore/cloud_firestore.dart';

class Camion {
  final String id;
  final String transportistaId;
  final String patente;
  final String tipo; // "CTN Std 20", "CTN Std 40", "HC", "OT", "reefer"
  final String seguroCarga;
  final DateTime docVencimiento;
  final String estadoDocumentacion; // "ok", "proximo_vencer", "vencido"
  final bool disponible;
  final DateTime createdAt;
  final DateTime updatedAt;

  Camion({
    required this.id,
    required this.transportistaId,
    required this.patente,
    required this.tipo,
    required this.seguroCarga,
    required this.docVencimiento,
    required this.estadoDocumentacion,
    required this.disponible,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Camion.fromJson(Map<String, dynamic> json, String id) => Camion(
    id: id,
    transportistaId: json['transportista_id'] as String,
    patente: json['patente'] as String,
    tipo: json['tipo'] as String,
    seguroCarga: json['seguro_carga'] as String,
    docVencimiento: (json['doc_vencimiento'] as Timestamp).toDate(),
    estadoDocumentacion: json['estado_documentacion'] as String,
    disponible: json['disponible'] as bool? ?? true,
    createdAt: (json['created_at'] as Timestamp).toDate(),
    updatedAt: (json['updated_at'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toJson() => {
    'transportista_id': transportistaId,
    'patente': patente,
    'tipo': tipo,
    'seguro_carga': seguroCarga,
    'doc_vencimiento': Timestamp.fromDate(docVencimiento),
    'estado_documentacion': estadoDocumentacion,
    'disponible': disponible,
    'created_at': Timestamp.fromDate(createdAt),
    'updated_at': Timestamp.fromDate(updatedAt),
  };

  /// Calcula el estado de documentación basado en la fecha de vencimiento
  static String calcularEstadoDocumentacion(DateTime fechaVencimiento) {
    final ahora = DateTime.now();
    final diferencia = fechaVencimiento.difference(ahora).inDays;

    if (diferencia < 0) return 'vencido';
    if (diferencia <= 7) return 'vencido';
    if (diferencia <= 30) return 'proximo_vencer';
    return 'ok';
  }

  Camion copyWith({
    String? id,
    String? transportistaId,
    String? patente,
    String? tipo,
    String? seguroCarga,
    DateTime? docVencimiento,
    String? estadoDocumentacion,
    bool? disponible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Camion(
    id: id ?? this.id,
    transportistaId: transportistaId ?? this.transportistaId,
    patente: patente ?? this.patente,
    tipo: tipo ?? this.tipo,
    seguroCarga: seguroCarga ?? this.seguroCarga,
    docVencimiento: docVencimiento ?? this.docVencimiento,
    estadoDocumentacion: estadoDocumentacion ?? this.estadoDocumentacion,
    disponible: disponible ?? this.disponible,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
