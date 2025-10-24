import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String uid;
  final String email;
  final String displayName;
  final String tipoUsuario;
  final String empresa;
  final String phoneNumber;
  final String? transportistaId;      // ID del transportista (null si es cliente)
  final String? codigoInvitacion;    // Código usado para registro (null si es cliente)
  final DateTime createdAt;
  final DateTime updatedAt;

  Usuario({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.tipoUsuario,
    required this.empresa,
    required this.phoneNumber,
    this.transportistaId,
    this.codigoInvitacion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    uid: json['uid'] as String,
    email: json['email'] as String,
    displayName: json['display_name'] as String,
    tipoUsuario: json['tipo_usuario'] as String,
    empresa: json['empresa'] as String,
    phoneNumber: json['phone_number'] as String,
    transportistaId: json['transportista_id'] as String?,
    codigoInvitacion: json['codigo_invitacion'] as String?,
    createdAt: (json['created_at'] as Timestamp).toDate(),
    updatedAt: (json['updated_at'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'uid': uid,
      'email': email,
      'display_name': displayName,
      'tipo_usuario': tipoUsuario,
      'empresa': empresa,
      'phone_number': phoneNumber,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
    
    if (transportistaId != null) json['transportista_id'] = transportistaId;
    if (codigoInvitacion != null) json['codigo_invitacion'] = codigoInvitacion;
    
    return json;
  }

  Usuario copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? tipoUsuario,
    String? empresa,
    String? phoneNumber,
    String? transportistaId,
    String? codigoInvitacion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Usuario(
    uid: uid ?? this.uid,
    email: email ?? this.email,
    displayName: displayName ?? this.displayName,
    tipoUsuario: tipoUsuario ?? this.tipoUsuario,
    empresa: empresa ?? this.empresa,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    transportistaId: transportistaId ?? this.transportistaId,
    codigoInvitacion: codigoInvitacion ?? this.codigoInvitacion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
