import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cargoclick/models/flete.dart';
import 'package:cargoclick/services/notifications_service.dart';
import 'package:cargoclick/services/notification_service.dart';
import 'package:cargoclick/services/firebase_error_handler.dart';

class FleteService {
  bool get _isBackendReady => Firebase.apps.isNotEmpty;
  final _noti = NotificationsService();
  final _notificationService = NotificationService();

  Stream<List<Flete>> getFletesCliente(String clienteId) {
    if (!_isBackendReady) {
      return Stream<List<Flete>>.error(
        'Firebase no está configurado. Abre el panel Firebase en Dreamflow y completa la configuración.',
      );
    }
    return FirebaseErrorHandler.handleStream(
      FirebaseFirestore.instance
          .collection('fletes')
          .where('cliente_id', isEqualTo: clienteId)
          .orderBy('fecha_publicacion', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Flete.fromJson(doc.data(), docId: doc.id))
              .toList()),
    );
  }

  Stream<List<Flete>> getFletesDisponibles() {
    if (!_isBackendReady) {
      return Stream<List<Flete>>.error(
        'Firebase no está configurado. Abre el panel Firebase en Dreamflow y completa la configuración.',
      );
    }
    // Mostrar fletes disponibles Y solicitados (para que no desaparezcan al aceptar)
    return FirebaseErrorHandler.handleStream(
      FirebaseFirestore.instance
          .collection('fletes')
          .where('estado', whereIn: ['disponible', 'solicitado'])
          .orderBy('fecha_publicacion', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Flete.fromJson(doc.data(), docId: doc.id))
              .toList()),
    );
  }

  Future<void> publicarFlete(Flete flete) async {
    if (!_isBackendReady) {
      throw StateError(
        'Firebase no está configurado. Abre el panel Firebase en Dreamflow y completa la configuración.',
      );
    }
    
    return FirebaseErrorHandler.handle(() async {
      final now = DateTime.now();
      final fleteData = flete.copyWith(
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await FirebaseFirestore.instance.collection('fletes').add(fleteData.toJson());
      final fleteId = docRef.id;
    
    // NOTIFICAR A TODOS LOS TRANSPORTISTAS
    print('🔔 [publicarFlete] Notificando a transportistas...');
    try {
      // Obtener todos los transportistas
      final transportistasSnapshot = await FirebaseFirestore.instance
          .collection('transportistas')
          .get();
      
      print('📋 [publicarFlete] Encontrados ${transportistasSnapshot.docs.length} transportistas');
      
      // Enviar notificación a cada transportista
      for (var doc in transportistasSnapshot.docs) {
        try {
          final transportistaId = doc.id;
          final tarifaMinima = doc.data()['tarifa_minima'] as double?;
          
          // Filtro opcional: solo notificar si tarifa del flete >= tarifa mínima del transportista
          if (tarifaMinima != null && flete.tarifa < tarifaMinima) {
            print('⏭️ [publicarFlete] Saltando transportista $transportistaId (tarifa baja)');
            continue;
          }
          
          await _notificationService.enviarNotificacion(
            userId: transportistaId,
            tipo: 'nuevo_flete',
            titulo: '🚛 Nuevo Flete Disponible',
            mensaje: '${flete.numeroContenedor} - ${flete.origen} → ${flete.destino} - \$${flete.tarifa.toStringAsFixed(0)}',
            fleteId: fleteId,
          );
          
          print('✅ [publicarFlete] Notificación enviada a transportista $transportistaId');
        } catch (e) {
          print('⚠️ [publicarFlete] Error notificando transportista: $e');
          // Continuar con los demás
        }
      }
      
      print('🎉 [publicarFlete] Notificaciones enviadas a ${transportistasSnapshot.docs.length} transportistas');
    } catch (e) {
      print('❌ [publicarFlete] Error general notificando transportistas: $e');
      // No fallar la publicación si las notificaciones fallan
    }
    });
  }

  Future<void> aceptarFlete(String fleteId, String transportistaId) async {
    print('🚀 [aceptarFlete] Iniciando - fleteId: $fleteId, choferId: $transportistaId');
    
    if (!_isBackendReady) {
      throw StateError(
        'Firebase no está configurado. Abre el panel Firebase en Dreamflow y completa la configuración.',
      );
    }
    
    return FirebaseErrorHandler.handle(() async {
      final db = FirebaseFirestore.instance;
      final now = DateTime.now();
    
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
    });
  }

  Stream<List<Flete>> getFletesAsignadosChofer(String choferId) {
    if (!_isBackendReady) {
      return const Stream.empty();
    }
    
    // CORREGIDO: Usar 'chofer_asignado' en lugar de 'transportista_asignado'
    // para evitar duplicados
    return FirebaseErrorHandler.handleStream(
      FirebaseFirestore.instance
          .collection('fletes')
          .where('chofer_asignado', isEqualTo: choferId)
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
            
            // Ordenar por fecha de asignación (más reciente primero)
            fletes.sort((a, b) {
              final dateA = a.fechaAsignacion ?? a.createdAt;
              final dateB = b.fechaAsignacion ?? b.createdAt;
              return dateB.compareTo(dateA);
            });
            
            return fletes;
          }),
    );
  }

  /// Verifica si un chofer está disponible (no tiene fletes activos)
  Future<bool> isChoferDisponible(String choferId) async {
    if (!_isBackendReady) return false;
    
    final db = FirebaseFirestore.instance;
    final fletesActivos = await db
        .collection('fletes')
        .where('chofer_asignado', isEqualTo: choferId)
        .where('estado', whereIn: ['asignado', 'en_proceso'])
        .limit(1)
        .get();
    
    return fletesActivos.docs.isEmpty;
  }

  /// Verifica si un camión está disponible (no tiene fletes activos)
  Future<bool> isCamionDisponible(String camionId) async {
    if (!_isBackendReady) return false;
    
    final db = FirebaseFirestore.instance;
    final fletesActivos = await db
        .collection('fletes')
        .where('camion_asignado', isEqualTo: camionId)
        .where('estado', whereIn: ['asignado', 'en_proceso'])
        .limit(1)
        .get();
    
    return fletesActivos.docs.isEmpty;
  }

  /// Obtiene el flete activo de un chofer (si existe)
  Future<Map<String, dynamic>?> getFleteActivoChofer(String choferId) async {
    if (!_isBackendReady) return null;
    
    final db = FirebaseFirestore.instance;
    final fletesActivos = await db
        .collection('fletes')
        .where('chofer_asignado', isEqualTo: choferId)
        .where('estado', whereIn: ['asignado', 'en_proceso'])
        .limit(1)
        .get();
    
    if (fletesActivos.docs.isEmpty) return null;
    
    final doc = fletesActivos.docs.first;
    return {
      'id': doc.id,
      'numero_contenedor': doc.data()['numero_contenedor'],
      'estado': doc.data()['estado'],
    };
  }

  /// Obtiene el flete activo de un camión (si existe)
  Future<Map<String, dynamic>?> getFleteActivoCamion(String camionId) async {
    if (!_isBackendReady) return null;
    
    final db = FirebaseFirestore.instance;
    final fletesActivos = await db
        .collection('fletes')
        .where('camion_asignado', isEqualTo: camionId)
        .where('estado', whereIn: ['asignado', 'en_proceso'])
        .limit(1)
        .get();
    
    if (fletesActivos.docs.isEmpty) return null;
    
    final doc = fletesActivos.docs.first;
    return {
      'id': doc.id,
      'numero_contenedor': doc.data()['numero_contenedor'],
      'estado': doc.data()['estado'],
    };
  }

  /// Asigna un flete a un chofer y camión específico (nuevo flujo con transportista)
  Future<void> asignarFlete({
    required String fleteId,
    required String transportistaId,
    required String choferId,
    required String camionId,
    String? rutIngresoSti,
    String? rutIngresoPc,
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
    
    return FirebaseErrorHandler.handle(() async {
      // 1. VALIDAR DISPONIBILIDAD DE CHOFER
      print('👤 [asignarFlete] Verificando disponibilidad de chofer...');
      final choferDisponible = await isChoferDisponible(choferId);
      if (!choferDisponible) {
        final fleteActivo = await getFleteActivoChofer(choferId);
        throw StateError(
          'Este chofer ya tiene un flete activo (${fleteActivo?['numero_contenedor'] ?? 'sin número'}). '
          'Debe completarlo antes de asignar otro.',
        );
      }
      print('✅ [asignarFlete] Chofer disponible');

      // 2. VALIDAR DISPONIBILIDAD DE CAMIÓN
      print('🚚 [asignarFlete] Verificando disponibilidad de camión...');
      final camionDisponible = await isCamionDisponible(camionId);
      if (!camionDisponible) {
        final fleteActivo = await getFleteActivoCamion(camionId);
        throw StateError(
          'Este camión ya tiene un flete activo (${fleteActivo?['numero_contenedor'] ?? 'sin número'}). '
          'Debe completarse antes de asignar otro.',
        );
      }
      print('✅ [asignarFlete] Camión disponible');

      // 3. Verificar que el flete existe y está disponible
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
      final updateData = {
        'estado': 'asignado',
        'transportista_id': transportistaId,
        'transportista_asignado': choferId, // Compatibilidad legacy
        'chofer_asignado': choferId,
        'camion_asignado': camionId,
        'fecha_asignacion': Timestamp.fromDate(now),
        'updated_at': Timestamp.fromDate(now),
      };
      
      // Agregar RUTs de puerto si fueron proporcionados
      if (rutIngresoSti != null && rutIngresoSti.isNotEmpty) {
        updateData['rut_ingreso_sti'] = rutIngresoSti;
      }
      if (rutIngresoPc != null && rutIngresoPc.isNotEmpty) {
        updateData['rut_ingreso_pc'] = rutIngresoPc;
      }
      
      await db.collection('fletes').doc(fleteId).update(updateData);
      print('✅ [asignarFlete] Flete actualizado exitosamente');
      
      final clienteId = fleteData['cliente_id'] as String;
      final numeroContenedor = fleteData['numero_contenedor'] as String? ?? 'Sin número';
      
      // ENVIAR NOTIFICACIONES A CLIENTE Y CHOFER
      print('🔔 [asignarFlete] Enviando notificaciones...');
      
      // Notificación al CLIENTE
      try {
        await _notificationService.enviarNotificacion(
          userId: clienteId,
          tipo: 'asignacion',
          titulo: '✅ Flete Asignado',
          mensaje: 'Tu flete $numeroContenedor ha sido asignado a un chofer',
          fleteId: fleteId,
        );
        print('✅ [asignarFlete] Notificación enviada al cliente');
      } catch (e) {
        print('⚠️ [asignarFlete] Error enviando notificación al cliente: $e');
      }
      
      // Notificación al CHOFER
      try {
        await _notificationService.enviarNotificacion(
          userId: choferId,
          tipo: 'asignacion',
          titulo: '🚛 Nuevo Recorrido',
          mensaje: 'Te han asignado el flete $numeroContenedor',
          fleteId: fleteId,
        );
        print('✅ [asignarFlete] Notificación enviada al chofer');
      } catch (e) {
        print('⚠️ [asignarFlete] Error enviando notificación al chofer: $e');
      }
      
      print('🎉 [asignarFlete] Asignación completada exitosamente');
    });
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
        .snapshots()
        .map((snapshot) {
          final fletes = snapshot.docs
              .map((doc) => Flete.fromJson(doc.data(), docId: doc.id))
              .toList();
          
          // Filtrar solo asignados (no disponibles ni solicitados)
          fletes.retainWhere((f) => 
            f.estado == 'asignado' || 
            f.estado == 'en_proceso' || 
            f.estado == 'completado'
          );
          
          // Ordenar en memoria por fecha de asignación
          fletes.sort((a, b) {
            final dateA = a.fechaAsignacion ?? a.createdAt;
            final dateB = b.fechaAsignacion ?? b.createdAt;
            return dateB.compareTo(dateA); // Descendente
          });
          
          return fletes;
        });
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

  /// NUEVO: Reasignar chofer/camión (OPCIÓN HÍBRIDA)
  /// - El transportista hace el cambio inmediatamente
  /// - Se registra en historial de cambios
  /// - Se notifica al cliente por email
  /// - Cliente tiene 24 horas para rechazar
  Future<void> reasignarChoferCamion({
    required String fleteId,
    required String transportistaId,
    required String nuevoChoferId,
    required String nuevoCamionId,
    required String razon,
  }) async {
    print('🔄 [reasignarChoferCamion] Iniciando reasignación');
    print('   FleteID: $fleteId');
    print('   Nuevo ChoferID: $nuevoChoferId');
    print('   Nuevo CamionID: $nuevoCamionId');
    print('   Razón: $razon');

    if (!_isBackendReady) {
      throw StateError('Firebase no está configurado.');
    }

    final db = FirebaseFirestore.instance;
    final now = DateTime.now();
    final fechaLimite = now.add(const Duration(hours: 24));

    try {
      // 1. Obtener datos actuales del flete
      print('📖 [reasignarChoferCamion] Obteniendo datos del flete...');
      final fleteDoc = await db.collection('fletes').doc(fleteId).get();
      
      if (!fleteDoc.exists) {
        throw StateError('Flete no encontrado');
      }

      final fleteData = fleteDoc.data()!;
      final estadoActual = fleteData['estado'] as String;

      // Solo permitir reasignación si está asignado o en proceso
      if (estadoActual != 'asignado' && estadoActual != 'en_proceso') {
        throw StateError('Solo se puede reasignar fletes asignados o en proceso');
      }

      // Verificar que sea el transportista correcto
      if (fleteData['transportista_id'] != transportistaId) {
        throw StateError('No tienes permiso para reasignar este flete');
      }

      final choferAnteriorId = fleteData['chofer_asignado'] as String;
      final camionAnteriorId = fleteData['camion_asignado'] as String;
      final clienteId = fleteData['cliente_id'] as String;
      final numeroContenedor = fleteData['numero_contenedor'] as String? ?? 'Sin número';

      // 2. Obtener nombres del chofer anterior y nuevo
      print('📋 [reasignarChoferCamion] Obteniendo datos de choferes...');
      final choferAnteriorDoc = await db.collection('users').doc(choferAnteriorId).get();
      final choferNuevoDoc = await db.collection('users').doc(nuevoChoferId).get();
      
      final choferAnteriorNombre = choferAnteriorDoc.data()?['display_name'] as String? ?? 'Chofer anterior';
      final choferNuevoNombre = choferNuevoDoc.data()?['display_name'] as String? ?? 'Chofer nuevo';

      // 3. Obtener patentes de camiones
      print('🚚 [reasignarChoferCamion] Obteniendo datos de camiones...');
      final camionAnteriorDoc = await db.collection('camiones').doc(camionAnteriorId).get();
      final camionNuevoDoc = await db.collection('camiones').doc(nuevoCamionId).get();
      
      final camionAnteriorPatente = camionAnteriorDoc.data()?['patente'] as String? ?? 'N/A';
      final camionNuevoPatente = camionNuevoDoc.data()?['patente'] as String? ?? 'N/A';

      // 4. Crear registro de cambio en historial
      print('📝 [reasignarChoferCamion] Creando registro de cambio...');
      final cambioData = {
        'flete_id': fleteId,
        'transportista_id': transportistaId,
        'razon': razon,
        'chofer_anterior_id': choferAnteriorId,
        'chofer_anterior_nombre': choferAnteriorNombre,
        'camion_anterior_id': camionAnteriorId,
        'camion_anterior_patente': camionAnteriorPatente,
        'chofer_nuevo_id': nuevoChoferId,
        'chofer_nuevo_nombre': choferNuevoNombre,
        'camion_nuevo_id': nuevoCamionId,
        'camion_nuevo_patente': camionNuevoPatente,
        'fecha_cambio': Timestamp.fromDate(now),
        'estado': 'activo',
        'fecha_limite_rechazo': Timestamp.fromDate(fechaLimite),
      };

      await db.collection('cambios_asignacion').add(cambioData);
      print('✅ [reasignarChoferCamion] Registro de cambio creado');

      // 5. Actualizar el flete con nueva asignación
      print('🔄 [reasignarChoferCamion] Actualizando flete...');
      await db.collection('fletes').doc(fleteId).update({
        'chofer_asignado': nuevoChoferId,
        'camion_asignado': nuevoCamionId,
        'transportista_asignado': nuevoChoferId, // Legacy
        'updated_at': Timestamp.fromDate(now),
      });
      print('✅ [reasignarChoferCamion] Flete actualizado');

      // 6. Notificar al CLIENTE (email + notificación push)
      print('📧 [reasignarChoferCamion] Enviando notificaciones...');
      
      // Notificación push
      try {
        await _notificationService.enviarNotificacion(
          userId: clienteId,
          tipo: 'cambio_asignacion',
          titulo: '🔄 Cambio de Chofer/Camión',
          mensaje: 'Flete $numeroContenedor: $choferAnteriorNombre → $choferNuevoNombre. Tienes 24h para rechazar.',
          fleteId: fleteId,
        );
        print('✅ [reasignarChoferCamion] Notificación push enviada al cliente');
      } catch (e) {
        print('⚠️ [reasignarChoferCamion] Error enviando notificación push: $e');
      }

      // El email se enviará automáticamente por Cloud Function
      // (se activa cuando se crea un documento en 'cambios_asignacion')

      // 7. Notificar al CHOFER NUEVO
      try {
        await _notificationService.enviarNotificacion(
          userId: nuevoChoferId,
          tipo: 'asignacion',
          titulo: '🚛 Nuevo Flete Asignado',
          mensaje: 'Te han asignado el flete $numeroContenedor (reasignación)',
          fleteId: fleteId,
        );
        print('✅ [reasignarChoferCamion] Notificación enviada al chofer nuevo');
      } catch (e) {
        print('⚠️ [reasignarChoferCamion] Error enviando notificación al chofer: $e');
      }

      // 8. Notificar al CHOFER ANTERIOR
      try {
        await _notificationService.enviarNotificacion(
          userId: choferAnteriorId,
          tipo: 'cambio_asignacion',
          titulo: 'Flete Reasignado',
          mensaje: 'El flete $numeroContenedor ha sido reasignado a otro chofer',
          fleteId: fleteId,
        );
        print('✅ [reasignarChoferCamion] Notificación enviada al chofer anterior');
      } catch (e) {
        print('⚠️ [reasignarChoferCamion] Error enviando notificación al chofer anterior: $e');
      }

      print('🎉 [reasignarChoferCamion] Reasignación completada exitosamente');
    } catch (e) {
      print('💥 [reasignarChoferCamion] Error: $e');
      rethrow;
    }
  }

  /// Obtener historial de cambios de un flete
  Stream<List<Map<String, dynamic>>> getHistorialCambios(String fleteId) {
    if (!_isBackendReady) {
      return Stream<List<Map<String, dynamic>>>.error('Firebase no está configurado.');
    }
    
    return FirebaseFirestore.instance
        .collection('cambios_asignacion')
        .where('flete_id', isEqualTo: fleteId)
        .orderBy('fecha_cambio', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  /// Cliente rechaza un cambio de asignación
  Future<void> rechazarCambioAsignacion({
    required String cambioId,
    required String fleteId,
    required String motivo,
  }) async {
    print('❌ [rechazarCambioAsignacion] Iniciando rechazo');
    print('   CambioID: $cambioId');
    print('   FleteID: $fleteId');
    print('   Motivo: $motivo');

    if (!_isBackendReady) {
      throw StateError('Firebase no está configurado.');
    }

    final db = FirebaseFirestore.instance;
    final now = DateTime.now();

    try {
      // 1. Obtener datos del cambio
      final cambioDoc = await db.collection('cambios_asignacion').doc(cambioId).get();
      
      if (!cambioDoc.exists) {
        throw StateError('Cambio no encontrado');
      }

      final cambioData = cambioDoc.data()!;
      final fechaLimite = (cambioData['fecha_limite_rechazo'] as Timestamp).toDate();

      // Verificar que aún esté dentro del plazo
      if (now.isAfter(fechaLimite)) {
        throw StateError('El plazo para rechazar este cambio ha expirado');
      }

      // 2. Marcar cambio como rechazado
      await db.collection('cambios_asignacion').doc(cambioId).update({
        'estado': 'rechazado_cliente',
        'fecha_rechazo': Timestamp.fromDate(now),
        'motivo_rechazo': motivo,
      });
      print('✅ [rechazarCambioAsignacion] Cambio marcado como rechazado');

      // 3. Revertir el flete a la asignación anterior
      await db.collection('fletes').doc(fleteId).update({
        'chofer_asignado': cambioData['chofer_anterior_id'],
        'camion_asignado': cambioData['camion_anterior_id'],
        'transportista_asignado': cambioData['chofer_anterior_id'], // Legacy
        'updated_at': Timestamp.fromDate(now),
      });
      print('✅ [rechazarCambioAsignacion] Flete revertido a asignación anterior');

      // 4. Notificar al transportista del rechazo
      final transportistaId = cambioData['transportista_id'] as String;
      final numeroContenedor = (await db.collection('fletes').doc(fleteId).get())
          .data()?['numero_contenedor'] as String? ?? 'Sin número';

      try {
        await _notificationService.enviarNotificacion(
          userId: transportistaId,
          tipo: 'cambio_rechazado',
          titulo: '❌ Cambio Rechazado por Cliente',
          mensaje: 'Flete $numeroContenedor: El cliente rechazó el cambio. Motivo: $motivo',
          fleteId: fleteId,
        );
        print('✅ [rechazarCambioAsignacion] Notificación enviada al transportista');
      } catch (e) {
        print('⚠️ [rechazarCambioAsignacion] Error enviando notificación: $e');
      }

      print('🎉 [rechazarCambioAsignacion] Rechazo completado');
    } catch (e) {
      print('💥 [rechazarCambioAsignacion] Error: $e');
      rethrow;
    }
  }
}
