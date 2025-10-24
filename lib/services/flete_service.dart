import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cargoclick/models/flete.dart';
import 'package:cargoclick/services/notifications_service.dart';

class FleteService {
  bool get _isBackendReady => Firebase.apps.isNotEmpty;
  final _noti = NotificationsService();

  Stream<List<Flete>> getFletesCliente(String clienteId) {
    if (!_isBackendReady) {
      return Stream<List<Flete>>.error(
        'Firebase no está configurado. Abre el panel Firebase en Dreamflow y completa la configuración.',
      );
    }
    return FirebaseFirestore.instance
        .collection('fletes')
        .where('cliente_id', isEqualTo: clienteId)
        .orderBy('fecha_publicacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Flete.fromJson(doc.data(), docId: doc.id))
            .toList());
  }

  Stream<List<Flete>> getFletesDisponibles() {
    if (!_isBackendReady) {
      return Stream<List<Flete>>.error(
        'Firebase no está configurado. Abre el panel Firebase en Dreamflow y completa la configuración.',
      );
    }
    // Mostrar fletes disponibles Y solicitados (para que no desaparezcan al aceptar)
    return FirebaseFirestore.instance
        .collection('fletes')
        .where('estado', whereIn: ['disponible', 'solicitado'])
        .orderBy('fecha_publicacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Flete.fromJson(doc.data(), docId: doc.id))
            .toList());
  }

  Future<void> publicarFlete(Flete flete) async {
    if (!_isBackendReady) {
      throw StateError(
        'Firebase no está configurado. Abre el panel Firebase en Dreamflow y completa la configuración.',
      );
    }
    final now = DateTime.now();
    final fleteData = flete.copyWith(
      createdAt: now,
      updatedAt: now,
    );

    await FirebaseFirestore.instance.collection('fletes').add(fleteData.toJson());
  }

  Future<void> aceptarFlete(String fleteId, String transportistaId) async {
    print('🚀 [aceptarFlete] Iniciando - fleteId: $fleteId, choferId: $transportistaId');
    
    if (!_isBackendReady) {
      throw StateError(
        'Firebase no está configurado. Abre el panel Firebase en Dreamflow y completa la configuración.',
      );
    }
    
    final db = FirebaseFirestore.instance;
    final now = DateTime.now();
    
    try {
      // Primero obtener datos del flete
      print('📖 [aceptarFlete] Leyendo datos del flete...');
      final fleteDoc = await db.collection('fletes').doc(fleteId).get();
      if (!fleteDoc.exists) {
        print('❌ [aceptarFlete] Flete no encontrado');
        throw StateError('Flete no encontrado');
      }
      print('✅ [aceptarFlete] Flete encontrado');
      
      final data = fleteDoc.data()!;
      print('📊 [aceptarFlete] Estado actual del flete: ${data['estado']}');
      
      // Verificar que el flete esté disponible
      if (data['estado'] != 'disponible') {
        print('⚠️ [aceptarFlete] Flete no disponible, estado: ${data['estado']}');
        throw StateError('Este flete ya no está disponible');
      }
      
      final clienteId = data['cliente_id'] as String;
      print('👤 [aceptarFlete] Cliente ID: $clienteId');
      
      final choferResumen = {'uid': transportistaId};
      final fleteResumen = {
        'numero_contenedor': data['numero_contenedor'],
        'origen': data['origen'],
        'destino': data['destino'],
      };

      // Crear la solicitud primero
      print('📝 [aceptarFlete] Creando solicitud en Firestore...');
      await db
          .collection('solicitudes')
          .doc(fleteId)
          .collection('solicitantes')
          .doc(transportistaId)
          .set({
        'flete_id': fleteId,
        'chofer_id': transportistaId,
        'cliente_id': clienteId,
        'status': 'pending',
        'created_at': Timestamp.fromDate(now),
        'updated_at': Timestamp.fromDate(now),
        'flete_resumen': fleteResumen,
        'chofer_resumen': choferResumen,
      });
      print('✅ [aceptarFlete] Solicitud creada exitosamente');

      // Luego actualizar estado del flete
      print('🔄 [aceptarFlete] Actualizando estado del flete a "solicitado"...');
      try {
        await db.collection('fletes').doc(fleteId).update({
          'estado': 'solicitado',
          'updated_at': Timestamp.fromDate(now),
        });
        print('✅ [aceptarFlete] Estado del flete actualizado exitosamente');
      } catch (e) {
        print('❌ [aceptarFlete] Error al actualizar flete: $e');
        print('🗑️ [aceptarFlete] Eliminando solicitud creada...');
        // Si falla actualizar el flete, eliminar la solicitud creada
        await db
            .collection('solicitudes')
            .doc(fleteId)
            .collection('solicitantes')
            .doc(transportistaId)
            .delete();
        print('🗑️ [aceptarFlete] Solicitud eliminada (rollback)');
        rethrow;
      }

      // Notificación al cliente
      print('🔔 [aceptarFlete] Enviando notificación al cliente...');
      try {
        await _noti.sendNotification(
          toUserId: clienteId,
          title: 'Chofer aceptó un flete',
          body: 'Se creó una solicitud para el flete ${fleteResumen['numero_contenedor']}',
          data: {'flete_id': fleteId, 'chofer_id': transportistaId, 'type': 'solicitud_nueva'},
        );
        print('✅ [aceptarFlete] Notificación enviada');
      } catch (e) {
        // No fallar si la notificación falla, solo registrar
        print('⚠️ [aceptarFlete] Error enviando notificación: $e');
      }
      
      print('🎉 [aceptarFlete] Proceso completado exitosamente');
    } catch (e) {
      print('💥 [aceptarFlete] Error general: $e');
      print('💥 [aceptarFlete] Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Stream<List<Flete>> getFletesAsignadosChofer(String choferId) {
    if (!_isBackendReady) {
      return const Stream.empty();
    }
    // Query simplificada para evitar necesitar índice compuesto
    // Solo filtramos por chofer, ordenamos en memoria
    return FirebaseFirestore.instance
        .collection('fletes')
        .where('transportista_asignado', isEqualTo: choferId)
        .snapshots()
        .map((snapshot) {
          final fletes = snapshot.docs
              .map((doc) => Flete.fromJson(doc.data(), docId: doc.id))
              .toList();
          
          // Filtrar por estados activos y ordenar por fecha en memoria
          fletes.retainWhere((f) => 
            f.estado == 'asignado' || 
            f.estado == 'en_proceso' || 
            f.estado == 'completado'
          );
          
          fletes.sort((a, b) {
            final dateA = a.fechaAsignacion ?? a.createdAt;
            final dateB = b.fechaAsignacion ?? b.createdAt;
            return dateB.compareTo(dateA); // Descendente
          });
          
          return fletes;
        });
  }

  /// Asigna un flete a un chofer y camión específico (nuevo flujo con transportista)
  Future<void> asignarFlete({
    required String fleteId,
    required String transportistaId,
    required String choferId,
    required String camionId,
  }) async {
    print('🚀 [asignarFlete] Iniciando asignación');
    print('   FleteID: $fleteId');
    print('   TransportistaID: $transportistaId');
    print('   ChoferID: $choferId');
    print('   CamionID: $camionId');
    
    if (!_isBackendReady) {
      throw StateError('Firebase no está configurado.');
    }
    
    final db = FirebaseFirestore.instance;
    final now = DateTime.now();
    
    try {
      // Verificar que el flete existe y está disponible
      print('📖 [asignarFlete] Verificando flete...');
      final fleteDoc = await db.collection('fletes').doc(fleteId).get();
      if (!fleteDoc.exists) {
        throw StateError('Flete no encontrado');
      }
      
      final fleteData = fleteDoc.data()!;
      final estadoActual = fleteData['estado'] as String;
      print('   Estado actual: $estadoActual');
      
      if (estadoActual != 'disponible' && estadoActual != 'solicitado') {
        throw StateError('Este flete ya no está disponible para asignación');
      }
      
      // Actualizar flete con asignación completa
      print('✍️ [asignarFlete] Actualizando flete...');
      await db.collection('fletes').doc(fleteId).update({
        'estado': 'asignado',
        'transportista_id': transportistaId,
        'transportista_asignado': choferId, // Compatibilidad legacy
        'chofer_asignado': choferId,
        'camion_asignado': camionId,
        'fecha_asignacion': Timestamp.fromDate(now),
        'updated_at': Timestamp.fromDate(now),
      });
      print('✅ [asignarFlete] Flete actualizado exitosamente');
      
      // Intentar enviar notificación al chofer (no crítico)
      print('🔔 [asignarFlete] Enviando notificación al chofer...');
      try {
        await _noti.sendNotification(
          toUserId: choferId,
          title: 'Flete asignado',
          body: 'Te han asignado un nuevo flete: ${fleteData['numero_contenedor']}',
          data: {
            'flete_id': fleteId,
            'type': 'flete_asignado',
          },
        );
        print('✅ [asignarFlete] Notificación enviada');
      } catch (e) {
        print('⚠️ [asignarFlete] Error enviando notificación (no crítico): $e');
      }
      
      print('🎉 [asignarFlete] Asignación completada exitosamente');
    } catch (e) {
      print('💥 [asignarFlete] Error: $e');
      rethrow;
    }
  }

  /// Obtiene fletes disponibles para transportista (nuevo flujo)
  Stream<List<Flete>> getFletesDisponiblesTransportista() {
    if (!_isBackendReady) {
      return Stream<List<Flete>>.error('Firebase no está configurado.');
    }
    return FirebaseFirestore.instance
        .collection('fletes')
        .where('estado', isEqualTo: 'disponible')
        .orderBy('fecha_publicacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Flete.fromJson(doc.data(), docId: doc.id))
            .toList());
  }

  /// Obtiene fletes asignados a choferes del transportista
  Stream<List<Flete>> getFletesAsignadosTransportista(String transportistaId) {
    if (!_isBackendReady) {
      return Stream<List<Flete>>.error('Firebase no está configurado.');
    }
    return FirebaseFirestore.instance
        .collection('fletes')
        .where('transportista_id', isEqualTo: transportistaId)
        .orderBy('fecha_asignacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Flete.fromJson(doc.data(), docId: doc.id))
            .toList());
  }

  /// Obtiene fletes asignados a un chofer específico (nuevo query)
  Stream<List<Flete>> getFletesChoferAsignado(String choferId) {
    if (!_isBackendReady) {
      return Stream<List<Flete>>.error('Firebase no está configurado.');
    }
    return FirebaseFirestore.instance
        .collection('fletes')
        .where('chofer_asignado', isEqualTo: choferId)
        .snapshots()
        .map((snapshot) {
          final fletes = snapshot.docs
              .map((doc) => Flete.fromJson(doc.data(), docId: doc.id))
              .toList();
          
          // Filtrar por estados relevantes
          fletes.retainWhere((f) => 
            f.estado == 'asignado' || 
            f.estado == 'en_proceso' || 
            f.estado == 'completado'
          );
          
          // Ordenar por fecha de asignación
          fletes.sort((a, b) {
            final dateA = a.fechaAsignacion ?? a.createdAt;
            final dateB = b.fechaAsignacion ?? b.createdAt;
            return dateB.compareTo(dateA);
          });
          
          return fletes;
        });
  }
}
