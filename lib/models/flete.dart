import 'package:cloud_firestore/cloud_firestore.dart';

class Flete {
  final String? id;
  final String clienteId;
  
  // Detalles del contenedor
  final String tipoContenedor;  // "CTN Std 20", "CTN Std 40", "HC", "OT", "reefer"
  final String numeroContenedor;
  final double? pesoCargaNeta;  // kg
  final double? pesoTara;       // kg
  final double peso;            // kg - Total (mantener para compatibilidad)
  
  // Ruta y logística
  final String origen;
  final String? puertoOrigen;
  final String destino;
  final String? direccionDestino;
  final double? destinoLat;
  final double? destinoLng;
  
  // Fechas y horarios
  final DateTime fechaPublicacion;
  final DateTime? fechaHoraCarga;
  
  // Información adicional
  final String? devolucionCtnVacio;
  final String? requisitosEspeciales;
  final String? serviciosAdicionales;
  
  // MÓDULO 2: Campos nuevos
  final bool isFueraDePerimetro;           // Checkbox perímetro
  final double? valorAdicionalPerimetro;    // Valor si está fuera
  final double? valorAdicionalSobrepeso;    // Valor si excede 25 ton
  final String? rutIngresoSti;              // RUT ingreso STI
  final String? rutIngresoPc;               // RUT ingreso PC
  final String? tipoDeRampla;               // Tipo de rampla
  
  // Tarifa
  final double tarifa;
  
  // Estado y asignación
  final String estado;
  final String? transportistaId;
  final String? transportistaAsignado;  // LEGACY
  final String? choferAsignado;
  final String? camionAsignado;
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
    // MÓDULO 2
    this.isFueraDePerimetro = false,
    this.valorAdicionalPerimetro,
    this.valorAdicionalSobrepeso,
    this.rutIngresoSti,
    this.rutIngresoPc,
    this.tipoDeRampla,
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
      // MÓDULO 2
      isFueraDePerimetro: json['is_fuera_de_perimetro'] as bool? ?? false,
      valorAdicionalPerimetro: json['valor_adicional_perimetro'] != null 
          ? (json['valor_adicional_perimetro'] as num).toDouble() 
          : null,
      valorAdicionalSobrepeso: json['valor_adicional_sobrepeso'] != null 
          ? (json['valor_adicional_sobrepeso'] as num).toDouble() 
          : null,
      rutIngresoSti: json['rut_ingreso_sti'] as String?,
      rutIngresoPc: json['rut_ingreso_pc'] as String?,
      tipoDeRampla: json['tipo_de_rampla'] as String?,
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
      // MÓDULO 2
      'is_fuera_de_perimetro': isFueraDePerimetro,
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
    // MÓDULO 2
    if (valorAdicionalPerimetro != null) json['valor_adicional_perimetro'] = valorAdicionalPerimetro;
    if (valorAdicionalSobrepeso != null) json['valor_adicional_sobrepeso'] = valorAdicionalSobrepeso;
    if (rutIngresoSti != null) json['rut_ingreso_sti'] = rutIngresoSti;
    if (rutIngresoPc != null) json['rut_ingreso_pc'] = rutIngresoPc;
    if (tipoDeRampla != null) json['tipo_de_rampla'] = tipoDeRampla;
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
