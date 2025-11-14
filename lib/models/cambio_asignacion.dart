import 'package:cloud_firestore/cloud_firestore.dart';

class CambioAsignacion {
  final String? id;
  final String fleteId;
  final String transportistaId;
  final String razon;
  
  // Datos anteriores
  final String choferAnteriorId;
  final String choferAnteriorNombre;
  final String camionAnteriorId;
  final String camionAnteriorPatente;
  
  // Datos nuevos
  final String choferNuevoId;
  final String choferNuevoNombre;
  final String camionNuevoId;
  final String camionNuevoPatente;
  
  // Control
  final DateTime fechaCambio;
  final String estado; // 'activo', 'rechazado_cliente'
  final DateTime? fechaRechazo;
  final String? motivoRechazo;
  
  // Ventana de rechazo (24 horas por defecto)
  final DateTime fechaLimiteRechazo;

  CambioAsignacion({
    this.id,
    required this.fleteId,
    required this.transportistaId,
    required this.razon,
    required this.choferAnteriorId,
    required this.choferAnteriorNombre,
    required this.camionAnteriorId,
    required this.camionAnteriorPatente,
    required this.choferNuevoId,
    required this.choferNuevoNombre,
    required this.camionNuevoId,
    required this.camionNuevoPatente,
    required this.fechaCambio,
    required this.estado,
    this.fechaRechazo,
    this.motivoRechazo,
    required this.fechaLimiteRechazo,
  });

  factory CambioAsignacion.fromJson(Map<String, dynamic> json, {String? docId}) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return CambioAsignacion(
      id: docId ?? json['id'] as String?,
      fleteId: json['flete_id'] as String,
      transportistaId: json['transportista_id'] as String,
      razon: json['razon'] as String,
      choferAnteriorId: json['chofer_anterior_id'] as String,
      choferAnteriorNombre: json['chofer_anterior_nombre'] as String,
      camionAnteriorId: json['camion_anterior_id'] as String,
      camionAnteriorPatente: json['camion_anterior_patente'] as String,
      choferNuevoId: json['chofer_nuevo_id'] as String,
      choferNuevoNombre: json['chofer_nuevo_nombre'] as String,
      camionNuevoId: json['camion_nuevo_id'] as String,
      camionNuevoPatente: json['camion_nuevo_patente'] as String,
      fechaCambio: parseDate(json['fecha_cambio']),
      estado: json['estado'] as String,
      fechaRechazo: json['fecha_rechazo'] != null ? parseDate(json['fecha_rechazo']) : null,
      motivoRechazo: json['motivo_rechazo'] as String?,
      fechaLimiteRechazo: parseDate(json['fecha_limite_rechazo']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'flete_id': fleteId,
      'transportista_id': transportistaId,
      'razon': razon,
      'chofer_anterior_id': choferAnteriorId,
      'chofer_anterior_nombre': choferAnteriorNombre,
      'camion_anterior_id': camionAnteriorId,
      'camion_anterior_patente': camionAnteriorPatente,
      'chofer_nuevo_id': choferNuevoId,
      'chofer_nuevo_nombre': choferNuevoNombre,
      'camion_nuevo_id': camionNuevoId,
      'camion_nuevo_patente': camionNuevoPatente,
      'fecha_cambio': Timestamp.fromDate(fechaCambio),
      'estado': estado,
      'fecha_limite_rechazo': Timestamp.fromDate(fechaLimiteRechazo),
    };

    if (id != null) json['id'] = id;
    if (fechaRechazo != null) json['fecha_rechazo'] = Timestamp.fromDate(fechaRechazo!);
    if (motivoRechazo != null) json['motivo_rechazo'] = motivoRechazo;

    return json;
  }

  bool get puedeSerRechazado {
    return estado == 'activo' && DateTime.now().isBefore(fechaLimiteRechazo);
  }

  String get tiempoRestanteParaRechazar {
    if (!puedeSerRechazado) return 'Expirado';
    
    final diferencia = fechaLimiteRechazo.difference(DateTime.now());
    
    if (diferencia.inHours > 0) {
      return '${diferencia.inHours}h restantes';
    } else if (diferencia.inMinutes > 0) {
      return '${diferencia.inMinutes}min restantes';
    } else {
      return 'Expirando...';
    }
  }
}
