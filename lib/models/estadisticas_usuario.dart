import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para estadísticas de usuario (cliente, transportista o chofer)
class EstadisticasUsuario {
  final String userId;
  final int serviciosCompletados;
  final int serviciosActivos;
  final double tasaExito;
  final DateTime? primerServicio;
  final DateTime? ultimoServicio;
  final double? ratingPromedio;
  final int? totalCalificaciones;

  EstadisticasUsuario({
    required this.userId,
    required this.serviciosCompletados,
    required this.serviciosActivos,
    required this.tasaExito,
    this.primerServicio,
    this.ultimoServicio,
    this.ratingPromedio,
    this.totalCalificaciones,
  });

  factory EstadisticasUsuario.fromJson(Map<String, dynamic> json) {
    return EstadisticasUsuario(
      userId: json['user_id'] as String,
      serviciosCompletados: json['servicios_completados'] as int? ?? 0,
      serviciosActivos: json['servicios_activos'] as int? ?? 0,
      tasaExito: (json['tasa_exito'] as num?)?.toDouble() ?? 0.0,
      primerServicio: json['primer_servicio'] != null
          ? (json['primer_servicio'] as Timestamp).toDate()
          : null,
      ultimoServicio: json['ultimo_servicio'] != null
          ? (json['ultimo_servicio'] as Timestamp).toDate()
          : null,
      ratingPromedio: (json['rating_promedio'] as num?)?.toDouble(),
      totalCalificaciones: json['total_calificaciones'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'user_id': userId,
      'servicios_completados': serviciosCompletados,
      'servicios_activos': serviciosActivos,
      'tasa_exito': tasaExito,
    };

    if (primerServicio != null) {
      json['primer_servicio'] = Timestamp.fromDate(primerServicio!);
    }
    if (ultimoServicio != null) {
      json['ultimo_servicio'] = Timestamp.fromDate(ultimoServicio!);
    }
    if (ratingPromedio != null) {
      json['rating_promedio'] = ratingPromedio;
    }
    if (totalCalificaciones != null) {
      json['total_calificaciones'] = totalCalificaciones;
    }

    return json;
  }

  /// Calcula años de experiencia desde el primer servicio
  int get anosExperiencia {
    if (primerServicio == null) return 0;
    final diferencia = DateTime.now().difference(primerServicio!);
    return (diferencia.inDays / 365).floor();
  }

  /// Retorna string formateado de años/meses de experiencia
  String get experienciaTexto {
    if (primerServicio == null) return 'Nuevo';
    
    final diferencia = DateTime.now().difference(primerServicio!);
    final anos = (diferencia.inDays / 365).floor();
    final meses = ((diferencia.inDays % 365) / 30).floor();
    
    if (anos > 0) {
      if (meses > 0) {
        return '$anos año${anos > 1 ? 's' : ''} y $meses mes${meses > 1 ? 'es' : ''}';
      }
      return '$anos año${anos > 1 ? 's' : ''}';
    } else if (meses > 0) {
      return '$meses mes${meses > 1 ? 'es' : ''}';
    } else {
      return 'Menos de 1 mes';
    }
  }

  EstadisticasUsuario copyWith({
    String? userId,
    int? serviciosCompletados,
    int? serviciosActivos,
    double? tasaExito,
    DateTime? primerServicio,
    DateTime? ultimoServicio,
    double? ratingPromedio,
    int? totalCalificaciones,
  }) {
    return EstadisticasUsuario(
      userId: userId ?? this.userId,
      serviciosCompletados: serviciosCompletados ?? this.serviciosCompletados,
      serviciosActivos: serviciosActivos ?? this.serviciosActivos,
      tasaExito: tasaExito ?? this.tasaExito,
      primerServicio: primerServicio ?? this.primerServicio,
      ultimoServicio: ultimoServicio ?? this.ultimoServicio,
      ratingPromedio: ratingPromedio ?? this.ratingPromedio,
      totalCalificaciones: totalCalificaciones ?? this.totalCalificaciones,
    );
  }
}
