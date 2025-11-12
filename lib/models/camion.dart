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
  
  // MÓDULO 1: Campos adicionales de seguro
  final String numeroPoliza;
  final String companiaSeguro;
  final String nombreSeguro;
  
  // MÓDULO 1: Validación por Cliente
  final bool isValidadoCliente;
  final String? clienteValidadorId;
  final DateTime? fechaValidacion;

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
    required this.numeroPoliza,
    required this.companiaSeguro,
    required this.nombreSeguro,
    this.isValidadoCliente = false,
    this.clienteValidadorId,
    this.fechaValidacion,
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
    numeroPoliza: json['numero_poliza'] as String? ?? '',
    companiaSeguro: json['compania_seguro'] as String? ?? '',
    nombreSeguro: json['nombre_seguro'] as String? ?? '',
    isValidadoCliente: json['is_validado_cliente'] as bool? ?? false,
    clienteValidadorId: json['cliente_validador_id'] as String?,
    fechaValidacion: json['fecha_validacion'] != null
        ? (json['fecha_validacion'] as Timestamp).toDate()
        : null,
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
    'numero_poliza': numeroPoliza,
    'compania_seguro': companiaSeguro,
    'nombre_seguro': nombreSeguro,
    'is_validado_cliente': isValidadoCliente,
    if (clienteValidadorId != null) 'cliente_validador_id': clienteValidadorId,
    if (fechaValidacion != null) 'fecha_validacion': Timestamp.fromDate(fechaValidacion!),
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
    String? numeroPoliza,
    String? companiaSeguro,
    String? nombreSeguro,
    bool? isValidadoCliente,
    String? clienteValidadorId,
    DateTime? fechaValidacion,
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
    numeroPoliza: numeroPoliza ?? this.numeroPoliza,
    companiaSeguro: companiaSeguro ?? this.companiaSeguro,
    nombreSeguro: nombreSeguro ?? this.nombreSeguro,
    isValidadoCliente: isValidadoCliente ?? this.isValidadoCliente,
    clienteValidadorId: clienteValidadorId ?? this.clienteValidadorId,
    fechaValidacion: fechaValidacion ?? this.fechaValidacion,
  );
}
