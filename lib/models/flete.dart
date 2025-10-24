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
  final String? transportistaId;        // NUEVO: ID del transportista que aceptó
  final String? transportistaAsignado;  // LEGACY: mantener para compatibilidad (será = choferAsignado)
  final String? choferAsignado;         // NUEVO: ID del chofer asignado
  final String? camionAsignado;         // NUEVO: ID del camión asignado
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
    this.transportistaId,
    this.transportistaAsignado,
    this.choferAsignado,
    this.camionAsignado,
    this.fechaAsignacion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Flete.fromJson(Map<String, dynamic> json, {String? docId}) {
    // Helper para convertir fechas que pueden venir como String o Timestamp
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return Flete(
      id: docId ?? json['id'] as String?,
      clienteId: json['cliente_id'] as String,
      tipoContenedor: json['tipo_contenedor'] as String,
      numeroContenedor: json['numero_contenedor'] as String,
      peso: (json['peso'] as num).toDouble(),
      origen: json['origen'] as String,
      destino: json['destino'] as String,
      tarifa: (json['tarifa'] as num).toDouble(),
      estado: json['estado'] as String,
      fechaPublicacion: parseDate(json['fecha_publicacion']),
      transportistaId: json['transportista_id'] as String?,
      transportistaAsignado: json['transportista_asignado'] as String?,
      choferAsignado: json['chofer_asignado'] as String?,
      camionAsignado: json['camion_asignado'] as String?,
      fechaAsignacion: json['fecha_asignacion'] != null 
          ? parseDate(json['fecha_asignacion'])
          : null,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'cliente_id': clienteId,
      'tipo_contenedor': tipoContenedor,
      'numero_contenedor': numeroContenedor,
      'peso': peso,
      'origen': origen,
      'destino': destino,
      'tarifa': tarifa,
      'estado': estado,
      'fecha_publicacion': Timestamp.fromDate(fechaPublicacion),
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
    
    if (id != null) json['id'] = id;
    if (transportistaId != null) json['transportista_id'] = transportistaId;
    if (transportistaAsignado != null) json['transportista_asignado'] = transportistaAsignado;
    if (choferAsignado != null) json['chofer_asignado'] = choferAsignado;
    if (camionAsignado != null) json['camion_asignado'] = camionAsignado;
    if (fechaAsignacion != null) json['fecha_asignacion'] = Timestamp.fromDate(fechaAsignacion!);
    
    return json;
  }

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
    String? transportistaId,
    String? transportistaAsignado,
    String? choferAsignado,
    String? camionAsignado,
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
    transportistaId: transportistaId ?? this.transportistaId,
    transportistaAsignado: transportistaAsignado ?? this.transportistaAsignado,
    choferAsignado: choferAsignado ?? this.choferAsignado,
    camionAsignado: camionAsignado ?? this.camionAsignado,
    fechaAsignacion: fechaAsignacion ?? this.fechaAsignacion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
