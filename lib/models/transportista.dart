import 'package:cloud_firestore/cloud_firestore.dart';

class Transportista {
  final String uid;
  final String email;
  final String razonSocial;
  final String rutEmpresa;
  final String telefono;
  final String codigoInvitacion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? tarifaMinima; // Tarifa mínima aceptable
  final String? puertoPreferido; // 'Valparaiso', 'San Antonio', o null (ambos)
  
  // MÓDULO 1: Validación por Cliente
  final bool isValidadoCliente; // Estado de validación
  final String? clienteValidadorId; // ID del cliente que validó
  final DateTime? fechaValidacion; // Fecha de validación

  Transportista({
    required this.uid,
    required this.email,
    required this.razonSocial,
    required this.rutEmpresa,
    required this.telefono,
    required this.codigoInvitacion,
    required this.createdAt,
    required this.updatedAt,
    this.tarifaMinima,
    this.puertoPreferido,
    this.isValidadoCliente = false,
    this.clienteValidadorId,
    this.fechaValidacion,
  });

  factory Transportista.fromJson(Map<String, dynamic> json) => Transportista(
    uid: json['uid'] as String,
    email: json['email'] as String,
    razonSocial: json['razon_social'] as String,
    rutEmpresa: json['rut_empresa'] as String,
    telefono: json['telefono'] as String,
    codigoInvitacion: json['codigo_invitacion'] as String,
    createdAt: (json['created_at'] as Timestamp).toDate(),
    updatedAt: (json['updated_at'] as Timestamp).toDate(),
    tarifaMinima: json['tarifa_minima'] != null 
        ? (json['tarifa_minima'] as num).toDouble() 
        : null,
    puertoPreferido: json['puerto_preferido'] as String?,
    isValidadoCliente: json['is_validado_cliente'] as bool? ?? false,
    clienteValidadorId: json['cliente_validador_id'] as String?,
    fechaValidacion: json['fecha_validacion'] != null
        ? (json['fecha_validacion'] as Timestamp).toDate()
        : null,
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'razon_social': razonSocial,
    'rut_empresa': rutEmpresa,
    'telefono': telefono,
    'codigo_invitacion': codigoInvitacion,
    'created_at': Timestamp.fromDate(createdAt),
    'updated_at': Timestamp.fromDate(updatedAt),
    if (tarifaMinima != null) 'tarifa_minima': tarifaMinima,
    if (puertoPreferido != null) 'puerto_preferido': puertoPreferido,
    'is_validado_cliente': isValidadoCliente,
    if (clienteValidadorId != null) 'cliente_validador_id': clienteValidadorId,
    if (fechaValidacion != null) 'fecha_validacion': Timestamp.fromDate(fechaValidacion!),
  };

  Transportista copyWith({
    String? uid,
    String? email,
    String? razonSocial,
    String? rutEmpresa,
    String? telefono,
    String? codigoInvitacion,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? tarifaMinima,
    String? puertoPreferido,
    bool? isValidadoCliente,
    String? clienteValidadorId,
    DateTime? fechaValidacion,
  }) => Transportista(
    uid: uid ?? this.uid,
    email: email ?? this.email,
    razonSocial: razonSocial ?? this.razonSocial,
    rutEmpresa: rutEmpresa ?? this.rutEmpresa,
    telefono: telefono ?? this.telefono,
    codigoInvitacion: codigoInvitacion ?? this.codigoInvitacion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    tarifaMinima: tarifaMinima ?? this.tarifaMinima,
    puertoPreferido: puertoPreferido ?? this.puertoPreferido,
    isValidadoCliente: isValidadoCliente ?? this.isValidadoCliente,
    clienteValidadorId: clienteValidadorId ?? this.clienteValidadorId,
    fechaValidacion: fechaValidacion ?? this.fechaValidacion,
  );
}
