import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/estadisticas_usuario.dart';

class EstadisticasService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtener estadísticas completas de un usuario (cliente, transportista o chofer)
  Future<EstadisticasUsuario> getEstadisticasUsuario(
    String userId,
    String tipoUsuario,
  ) async {
    try {
      int serviciosCompletados = 0;
      int serviciosActivos = 0;
      DateTime? primerServicio;
      DateTime? ultimoServicio;

      if (tipoUsuario == 'cliente') {
        // Contar fletes del cliente
        final fletesSnapshot = await _firestore
            .collection('fletes')
            .where('cliente_id', isEqualTo: userId)
            .get();

        serviciosCompletados = fletesSnapshot.docs
            .where((doc) => doc.data()['estado'] == 'completado')
            .length;
        
        serviciosActivos = fletesSnapshot.docs
            .where((doc) => 
                doc.data()['estado'] == 'asignado' || 
                doc.data()['estado'] == 'en_proceso')
            .length;

        // Obtener fechas
        if (fletesSnapshot.docs.isNotEmpty) {
          final fletes = fletesSnapshot.docs.map((doc) {
            final data = doc.data();
            return data['created_at'] as Timestamp?;
          }).where((t) => t != null).toList();

          if (fletes.isNotEmpty) {
            fletes.sort((a, b) => a!.compareTo(b!));
            primerServicio = fletes.first?.toDate();
            ultimoServicio = fletes.last?.toDate();
          }
        }
      } else if (tipoUsuario == 'transportista') {
        // Contar fletes asignados al transportista
        final fletesSnapshot = await _firestore
            .collection('fletes')
            .where('transportista_id', isEqualTo: userId)
            .get();

        serviciosCompletados = fletesSnapshot.docs
            .where((doc) => doc.data()['estado'] == 'completado')
            .length;
        
        serviciosActivos = fletesSnapshot.docs
            .where((doc) => 
                doc.data()['estado'] == 'asignado' || 
                doc.data()['estado'] == 'en_proceso')
            .length;

        // Obtener fechas
        if (fletesSnapshot.docs.isNotEmpty) {
          final fletes = fletesSnapshot.docs.map((doc) {
            final data = doc.data();
            return data['fecha_asignacion'] as Timestamp?;
          }).where((t) => t != null).toList();

          if (fletes.isNotEmpty) {
            fletes.sort((a, b) => a!.compareTo(b!));
            primerServicio = fletes.first?.toDate();
            ultimoServicio = fletes.last?.toDate();
          }
        }
      } else if (tipoUsuario == 'chofer') {
        // Contar fletes asignados al chofer
        final fletesSnapshot = await _firestore
            .collection('fletes')
            .where('chofer_asignado', isEqualTo: userId)
            .get();

        serviciosCompletados = fletesSnapshot.docs
            .where((doc) => doc.data()['estado'] == 'completado')
            .length;
        
        serviciosActivos = fletesSnapshot.docs
            .where((doc) => 
                doc.data()['estado'] == 'asignado' || 
                doc.data()['estado'] == 'en_proceso')
            .length;

        // Obtener fechas
        if (fletesSnapshot.docs.isNotEmpty) {
          final fletes = fletesSnapshot.docs.map((doc) {
            final data = doc.data();
            return data['fecha_asignacion'] as Timestamp?;
          }).where((t) => t != null).toList();

          if (fletes.isNotEmpty) {
            fletes.sort((a, b) => a!.compareTo(b!));
            primerServicio = fletes.first?.toDate();
            ultimoServicio = fletes.last?.toDate();
          }
        }
      }

      // Calcular tasa de éxito
      final totalServicios = serviciosCompletados + serviciosActivos;
      final tasaExito = totalServicios > 0 
          ? (serviciosCompletados / totalServicios) * 100 
          : 0.0;

      // Obtener rating si es transportista o chofer
      double? ratingPromedio;
      int? totalCalificaciones;

      if (tipoUsuario == 'transportista' || tipoUsuario == 'chofer') {
        final ratingsSnapshot = await _firestore
            .collection('ratings')
            .where('transportista_id', isEqualTo: userId)
            .get();

        if (ratingsSnapshot.docs.isNotEmpty) {
          totalCalificaciones = ratingsSnapshot.docs.length;
          final suma = ratingsSnapshot.docs.fold<int>(
            0,
            (sum, doc) => sum + (doc.data()['estrellas'] as int),
          );
          ratingPromedio = suma / totalCalificaciones;
        }
      }

      return EstadisticasUsuario(
        userId: userId,
        serviciosCompletados: serviciosCompletados,
        serviciosActivos: serviciosActivos,
        tasaExito: tasaExito,
        primerServicio: primerServicio,
        ultimoServicio: ultimoServicio,
        ratingPromedio: ratingPromedio,
        totalCalificaciones: totalCalificaciones,
      );
    } catch (e) {
      print('❌ Error al obtener estadísticas: $e');
      // Retornar estadísticas vacías en caso de error
      return EstadisticasUsuario(
        userId: userId,
        serviciosCompletados: 0,
        serviciosActivos: 0,
        tasaExito: 0.0,
      );
    }
  }

  /// Obtener lista de choferes bajo un transportista con sus estadísticas
  Future<List<Map<String, dynamic>>> getChoferesConEstadisticas(
    String transportistaId,
  ) async {
    try {
      // Obtener todos los usuarios que son choferes de este transportista
      final choferesSnapshot = await _firestore
          .collection('users')
          .where('transportista_id', isEqualTo: transportistaId)
          .where('tipo_usuario', isEqualTo: 'chofer')
          .get();

      final choferes = <Map<String, dynamic>>[];

      for (var doc in choferesSnapshot.docs) {
        final choferData = doc.data();
        final estadisticas = await getEstadisticasUsuario(doc.id, 'chofer');

        choferes.add({
          'id': doc.id,
          'nombre': choferData['display_name'] ?? 'Sin nombre',
          'email': choferData['email'] ?? '',
          'telefono': choferData['phone_number'] ?? '',
          'empresa': choferData['empresa'] ?? '',
          'estadisticas': estadisticas,
        });
      }

      return choferes;
    } catch (e) {
      print('❌ Error al obtener choferes: $e');
      return [];
    }
  }

  /// Obtener total de camiones de un transportista
  Future<int> getTotalCamiones(String transportistaId) async {
    try {
      final camionesSnapshot = await _firestore
          .collection('camiones')
          .where('transportista_id', isEqualTo: transportistaId)
          .get();

      return camionesSnapshot.docs.length;
    } catch (e) {
      print('❌ Error al contar camiones: $e');
      return 0;
    }
  }

  /// Obtener distribución de tipos de camiones
  Future<Map<String, int>> getDistribucionCamiones(String transportistaId) async {
    try {
      final camionesSnapshot = await _firestore
          .collection('camiones')
          .where('transportista_id', isEqualTo: transportistaId)
          .get();

      final distribucion = <String, int>{};

      for (var doc in camionesSnapshot.docs) {
        final tipo = doc.data()['tipo'] as String? ?? 'Sin tipo';
        distribucion[tipo] = (distribucion[tipo] ?? 0) + 1;
      }

      return distribucion;
    } catch (e) {
      print('❌ Error al obtener distribución: $e');
      return {};
    }
  }
}
