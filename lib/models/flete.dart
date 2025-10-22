import 'package:cloud_firestore/cloud_firestore.dart';

class Flete {
  final String? id;
  final String clienteId;
  final String tipoContenedor;
  final String numeroContenedor;
  final double peso;
  final String origen;
  final String destino;
  final double tarifa;
  final String estado;
  final DateTime fechaPublicacion;
  final String? transportistaAsignado;
  final DateTime? fechaAsignacion;
  final DateTime createdAt;
  final DateTime updatedAt;

  Flete({
    this.id,
    required this.clienteId,
    required this.tipoContenedor,
    required this.numeroContenedor,
    required this.peso,
    required this.origen,
    required this.destino,
    required this.tarifa,
    required this.estado,
    required this.fechaPublicacion,
    this.transportistaAsignado,
    this.fechaAsignacion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Flete.fromJson(Map<String, dynamic> json, {String? docId}) => Flete(
    id: docId ?? json['id'] as String?,
    clienteId: json['cliente_id'] as String,
    tipoContenedor: json['tipo_contenedor'] as String,
    numeroContenedor: json['numero_contenedor'] as String,
    peso: (json['peso'] as num).toDouble(),
    origen: json['origen'] as String,
    destino: json['destino'] as String,
    tarifa: (json['tarifa'] as num).toDouble(),
    estado: json['estado'] as String,
    fechaPublicacion: (json['fecha_publicacion'] as Timestamp).toDate(),
    transportistaAsignado: json['transportista_asignado'] as String?,
    fechaAsignacion: json['fecha_asignacion'] != null 
        ? (json['fecha_asignacion'] as Timestamp).toDate() 
        : null,
    createdAt: (json['created_at'] as Timestamp).toDate(),
    updatedAt: (json['updated_at'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'cliente_id': clienteId,
    'tipo_contenedor': tipoContenedor,
    'numero_contenedor': numeroContenedor,
    'peso': peso,
    'origen': origen,
    'destino': destino,
    'tarifa': tarifa,
    'estado': estado,
    'fecha_publicacion': Timestamp.fromDate(fechaPublicacion),
    'transportista_asignado': transportistaAsignado,
    'fecha_asignacion': fechaAsignacion != null 
        ? Timestamp.fromDate(fechaAsignacion!) 
        : null,
    'created_at': Timestamp.fromDate(createdAt),
    'updated_at': Timestamp.fromDate(updatedAt),
  };

  Flete copyWith({
    String? id,
    String? clienteId,
    String? tipoContenedor,
    String? numeroContenedor,
    double? peso,
    String? origen,
    String? destino,
    double? tarifa,
    String? estado,
    DateTime? fechaPublicacion,
    String? transportistaAsignado,
    DateTime? fechaAsignacion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Flete(
    id: id ?? this.id,
    clienteId: clienteId ?? this.clienteId,
    tipoContenedor: tipoContenedor ?? this.tipoContenedor,
    numeroContenedor: numeroContenedor ?? this.numeroContenedor,
    peso: peso ?? this.peso,
    origen: origen ?? this.origen,
    destino: destino ?? this.destino,
    tarifa: tarifa ?? this.tarifa,
    estado: estado ?? this.estado,
    fechaPublicacion: fechaPublicacion ?? this.fechaPublicacion,
    transportistaAsignado: transportistaAsignado ?? this.transportistaAsignado,
    fechaAsignacion: fechaAsignacion ?? this.fechaAsignacion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
