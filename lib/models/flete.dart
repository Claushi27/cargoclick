import 'package:cloud_firestore/cloud_firestore.dart';

class Flete {
  final String? id;
  final String clienteId;
  
  // Detalles del contenedor
  final String tipoContenedor;  // "CTN Std 20", "CTN Std 40", "HC", "OT", "reefer"
  final String numeroContenedor;
  final double? pesoCargaNeta;  // kg - NUEVO
  final double? pesoTara;       // kg - NUEVO
  final double peso;            // kg - Total (mantener para compatibilidad)
  
  // Ruta y logística
  final String origen;
  final String? puertoOrigen;   // NUEVO
  final String destino;
  final String? direccionDestino;  // NUEVO - Dirección completa
  final double? destinoLat;     // NUEVO - Coordenadas para mapa
  final double? destinoLng;     // NUEVO
  
  // Fechas y horarios
  final DateTime fechaPublicacion;
  final DateTime? fechaHoraCarga;  // NUEVO - Fecha/hora de carga
  
  // Información adicional
  final String? devolucionCtnVacio;     // NUEVO - Dirección/instrucciones
  final String? requisitosEspeciales;   // NUEVO
  final String? serviciosAdicionales;   // NUEVO
  
  // Tarifa
  final double tarifa;
  
  // Estado y asignación
  final String estado;
  final String? transportistaId;        // ID del transportista que aceptó
  final String? transportistaAsignado;  // LEGACY: mantener para compatibilidad
  final String? choferAsignado;         // ID del chofer asignado
  final String? camionAsignado;         // ID del camión asignado
  final DateTime? fechaAsignacion;
  
  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  Flete({
    this.id,
    required this.clienteId,
    required this.tipoContenedor,
    required this.numeroContenedor,
    this.pesoCargaNeta,
    this.pesoTara,
    required this.peso,
    required this.origen,
    this.puertoOrigen,
    required this.destino,
    this.direccionDestino,
    this.destinoLat,
    this.destinoLng,
    required this.fechaPublicacion,
    this.fechaHoraCarga,
    this.devolucionCtnVacio,
    this.requisitosEspeciales,
    this.serviciosAdicionales,
    required this.tarifa,
    required this.estado,
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
      pesoCargaNeta: json['peso_carga_neta'] != null ? (json['peso_carga_neta'] as num).toDouble() : null,
      pesoTara: json['peso_tara'] != null ? (json['peso_tara'] as num).toDouble() : null,
      peso: (json['peso'] as num).toDouble(),
      origen: json['origen'] as String,
      puertoOrigen: json['puerto_origen'] as String?,
      destino: json['destino'] as String,
      direccionDestino: json['direccion_destino'] as String?,
      destinoLat: json['destino_lat'] != null ? (json['destino_lat'] as num).toDouble() : null,
      destinoLng: json['destino_lng'] != null ? (json['destino_lng'] as num).toDouble() : null,
      fechaPublicacion: parseDate(json['fecha_publicacion']),
      fechaHoraCarga: json['fecha_hora_carga'] != null ? parseDate(json['fecha_hora_carga']) : null,
      devolucionCtnVacio: json['devolucion_ctn_vacio'] as String?,
      requisitosEspeciales: json['requisitos_especiales'] as String?,
      serviciosAdicionales: json['servicios_adicionales'] as String?,
      tarifa: (json['tarifa'] as num).toDouble(),
      estado: json['estado'] as String,
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
    
    // Campos opcionales
    if (id != null) json['id'] = id;
    if (pesoCargaNeta != null) json['peso_carga_neta'] = pesoCargaNeta;
    if (pesoTara != null) json['peso_tara'] = pesoTara;
    if (puertoOrigen != null) json['puerto_origen'] = puertoOrigen;
    if (direccionDestino != null) json['direccion_destino'] = direccionDestino;
    if (destinoLat != null) json['destino_lat'] = destinoLat;
    if (destinoLng != null) json['destino_lng'] = destinoLng;
    if (fechaHoraCarga != null) json['fecha_hora_carga'] = Timestamp.fromDate(fechaHoraCarga!);
    if (devolucionCtnVacio != null) json['devolucion_ctn_vacio'] = devolucionCtnVacio;
    if (requisitosEspeciales != null) json['requisitos_especiales'] = requisitosEspeciales;
    if (serviciosAdicionales != null) json['servicios_adicionales'] = serviciosAdicionales;
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
    double? pesoCargaNeta,
    double? pesoTara,
    double? peso,
    String? origen,
    String? puertoOrigen,
    String? destino,
    String? direccionDestino,
    double? destinoLat,
    double? destinoLng,
    DateTime? fechaPublicacion,
    DateTime? fechaHoraCarga,
    String? devolucionCtnVacio,
    String? requisitosEspeciales,
    String? serviciosAdicionales,
    double? tarifa,
    String? estado,
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
    pesoCargaNeta: pesoCargaNeta ?? this.pesoCargaNeta,
    pesoTara: pesoTara ?? this.pesoTara,
    peso: peso ?? this.peso,
    origen: origen ?? this.origen,
    puertoOrigen: puertoOrigen ?? this.puertoOrigen,
    destino: destino ?? this.destino,
    direccionDestino: direccionDestino ?? this.direccionDestino,
    destinoLat: destinoLat ?? this.destinoLat,
    destinoLng: destinoLng ?? this.destinoLng,
    fechaPublicacion: fechaPublicacion ?? this.fechaPublicacion,
    fechaHoraCarga: fechaHoraCarga ?? this.fechaHoraCarga,
    devolucionCtnVacio: devolucionCtnVacio ?? this.devolucionCtnVacio,
    requisitosEspeciales: requisitosEspeciales ?? this.requisitosEspeciales,
    serviciosAdicionales: serviciosAdicionales ?? this.serviciosAdicionales,
    tarifa: tarifa ?? this.tarifa,
    estado: estado ?? this.estado,
    transportistaId: transportistaId ?? this.transportistaId,
    transportistaAsignado: transportistaAsignado ?? this.transportistaAsignado,
    choferAsignado: choferAsignado ?? this.choferAsignado,
    camionAsignado: camionAsignado ?? this.camionAsignado,
    fechaAsignacion: fechaAsignacion ?? this.fechaAsignacion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
