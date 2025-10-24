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

  Transportista({
    required this.uid,
    required this.email,
    required this.razonSocial,
    required this.rutEmpresa,
    required this.telefono,
    required this.codigoInvitacion,
    required this.createdAt,
    required this.updatedAt,
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
  }) => Transportista(
    uid: uid ?? this.uid,
    email: email ?? this.email,
    razonSocial: razonSocial ?? this.razonSocial,
    rutEmpresa: rutEmpresa ?? this.rutEmpresa,
    telefono: telefono ?? this.telefono,
    codigoInvitacion: codigoInvitacion ?? this.codigoInvitacion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
