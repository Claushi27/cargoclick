import 'dart:typed_data';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cargoclick/models/checkpoint.dart';
import 'package:cargoclick/services/notifications_service.dart';
import 'package:cargoclick/services/notification_service.dart';
import 'package:cargoclick/services/firebase_error_handler.dart';
import 'package:cargoclick/services/image_compression_service.dart';

class CheckpointService {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _notificationsService = NotificationsService();
  final _notificationService = NotificationService();

  // Definición de los 5 checkpoints obligatorios
  static const checkpointTypes = [
    {
      'id': 'retiro_unidad',
      'titulo': '1. Retiro de Unidad',
      'descripcion': 'Foto del contenedor y sello de seguridad',
      'icon': 'local_shipping',
      'requiereFotos': 2,
    },
    {
      'id': 'ubicacion_gps',
      'titulo': '2. Ubicación GPS',
      'descripcion': 'Pantallazo del GPS en tiempo real',
      'icon': 'location_on',
      'requiereFotos': 1,
    },
    {
      'id': 'llegada_cliente',
      'titulo': '3. Llegada al Cliente',
      'descripcion': 'Foto del lugar y GPS con hora de llegada',
      'icon': 'place',
      'requiereFotos': 2,
    },
    {
      'id': 'salida_cliente',
      'titulo': '4. Salida del Cliente',
      'descripcion': 'Guía de despacho firmada con hora',
      'icon': 'exit_to_app',
      'requiereFotos': 1,
    },
    {
      'id': 'entrega_unidad_vacia',
      'titulo': '5. Entrega Unidad Vacía',
      'descripcion': 'Foto del Interchange',
      'icon': 'check_circle',
      'requiereFotos': 1,
    },
  ];

  /// Obtiene el estado de un checkpoint específico
  Stream<Checkpoint?> getCheckpoint(String fleteId, String tipo) {
    return FirebaseErrorHandler.handleStream(
      _db
          .collection('fletes')
          .doc(fleteId)
          .collection('checkpoints')
          .doc(tipo)
          .snapshots()
          .map((doc) {
        if (!doc.exists) return null;
        return Checkpoint.fromJson(doc.data()!, docId: doc.id);
      }),
    );
  }

  /// Obtiene todos los checkpoints de un flete
  Stream<List<Checkpoint>> getCheckpoints(String fleteId) {
    return FirebaseErrorHandler.handleStream(
      _db
          .collection('fletes')
          .doc(fleteId)
          .collection('checkpoints')
          .orderBy('created_at')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Checkpoint.fromJson(doc.data(), docId: doc.id))
              .toList()),
    );
  }

  /// Sube un checkpoint con sus fotos
  Future<void> subirCheckpoint({
    required String fleteId,
    required String choferId,
    required String tipo,
    required List<Uint8List> fotos,
    String? notas,
    Map<String, double>? ubicacion,
    String? gpsLink,
  }) async {
    final now = DateTime.now();

    // 1. Subir fotos a Storage
    final fotoUrls = <FotoCheckpoint>[];
    for (var i = 0; i < fotos.length; i++) {
      final timestamp = now.millisecondsSinceEpoch;
      final fileName = '${tipo}_${timestamp}_$i.jpg';
      final ref = _storage.ref('fletes/$fleteId/checkpoints/$tipo/$fileName');

      await ref.putData(
        fotos[i],
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final url = await ref.getDownloadURL();

      fotoUrls.add(FotoCheckpoint(
        url: url,
        storagePath: ref.fullPath,
        nombre: fileName,
        createdAt: now,
      ));
    }

    // 2. Guardar checkpoint en Firestore
    final checkpointData = {
      'tipo': tipo,
      'chofer_id': choferId,
      'timestamp': Timestamp.fromDate(now),
      'ubicacion': ubicacion,
      'fotos': fotoUrls.map((f) => f.toJson()).toList(),
      'notas': notas,
      'completado': true,
      'created_at': Timestamp.fromDate(now),
    };
    
    // Agregar GPS link si existe
    if (gpsLink != null && gpsLink.isNotEmpty) {
      checkpointData['gps_link'] = gpsLink;
    }

    await _db
        .collection('fletes')
        .doc(fleteId)
        .collection('checkpoints')
        .doc(tipo)
        .set(checkpointData);

    // 3. Verificar si se completaron todos los checkpoints
    final checkpointsSnapshot = await _db
        .collection('fletes')
        .doc(fleteId)
        .collection('checkpoints')
        .get();

    final completados = checkpointsSnapshot.docs.length;
    final total = checkpointTypes.length;

    // Si es el último checkpoint, marcar flete como completado
    if (completados == total) {
      try {
        await _db.collection('fletes').doc(fleteId).update({
          'estado': 'completado',
          'fecha_completado': Timestamp.fromDate(now),
          'updated_at': Timestamp.fromDate(now),
        });
        print('✅ Flete marcado como completado');
        
        // ENVIAR NOTIFICACIONES AL CLIENTE Y TRANSPORTISTA
        final fleteDoc = await _db.collection('fletes').doc(fleteId).get();
        final fleteData = fleteDoc.data();
        if (fleteData != null) {
          final clienteId = fleteData['cliente_id'] as String;
          final transportistaId = fleteData['transportista_id'] as String?;
          final numeroContenedor = fleteData['numero_contenedor'] as String? ?? 'Sin número';
          
          // Notificar al CLIENTE
          try {
            await _notificationService.enviarNotificacion(
              userId: clienteId,
              tipo: 'completado',
              titulo: '🎉 Flete Completado',
              mensaje: 'El flete $numeroContenedor ha sido completado exitosamente',
              fleteId: fleteId,
            );
            print('✅ Notificación de completado enviada al cliente');
          } catch (e) {
            print('⚠️ Error notificando al cliente: $e');
          }
          
          // Notificar al TRANSPORTISTA
          if (transportistaId != null) {
            try {
              await _notificationService.enviarNotificacion(
                userId: transportistaId,
                tipo: 'completado',
                titulo: '✅ Flete Completado',
                mensaje: 'El flete $numeroContenedor ha sido completado',
                fleteId: fleteId,
              );
              print('✅ Notificación de completado enviada al transportista');
            } catch (e) {
              print('⚠️ Error notificando al transportista: $e');
            }
          }
        }
        
      } catch (e) {
        print('⚠️ Error al actualizar estado del flete: $e');
        // No lanzar el error, el checkpoint ya está guardado
      }
    } else {
      // Actualizar solo updated_at para indicar progreso
      try {
        await _db.collection('fletes').doc(fleteId).update({
          'estado': 'en_proceso',
          'updated_at': Timestamp.fromDate(now),
        });
        print('✅ Flete actualizado a en_proceso');
      } catch (e) {
        print('⚠️ Error al actualizar flete: $e');
        // No lanzar el error, el checkpoint ya está guardado
      }
    }

    // 4. Notificar al admin
    final fleteDoc = await _db.collection('fletes').doc(fleteId).get();
    final fleteData = fleteDoc.data();
    if (fleteData != null) {
      final clienteId = fleteData['cliente_id'] as String;
      final checkpointInfo =
          checkpointTypes.firstWhere((c) => c['id'] == tipo);

      await _notificationsService.sendNotification(
        toUserId: clienteId,
        title: completados == total
            ? '¡Flete completado!'
            : 'Checkpoint completado',
        body: completados == total
            ? 'Todos los checkpoints han sido completados'
            : 'Checkpoint: ${checkpointInfo['titulo']}',
        data: {
          'flete_id': fleteId,
          'checkpoint': tipo,
          'completado': completados.toString(),
          'total': total.toString(),
        },
      );
    }
  }

  /// Verifica si un checkpoint está completado
  Future<bool> isCheckpointCompletado(String fleteId, String tipo) async {
    final doc = await _db
        .collection('fletes')
        .doc(fleteId)
        .collection('checkpoints')
        .doc(tipo)
        .get();
    return doc.exists && (doc.data()?['completado'] == true);
  }

  /// Obtiene el progreso de checkpoints (completados / total)
  Future<Map<String, int>> getProgreso(String fleteId) async {
    final snapshot = await _db
        .collection('fletes')
        .doc(fleteId)
        .collection('checkpoints')
        .where('completado', isEqualTo: true)
        .get();

    return {
      'completados': snapshot.docs.length,
      'total': checkpointTypes.length,
    };
  }

  /// Sube un checkpoint con fotos optimizadas (NUEVO - RECOMENDADO)
  /// Comprime las imágenes antes de subirlas para ahorrar datos y storage
  Future<void> subirCheckpointOptimizado({
    required String fleteId,
    required String choferId,
    required String tipo,
    required List<File> fotosFiles,
    String? notas,
    Map<String, double>? ubicacion,
    String? gpsLink,
  }) async {
    return FirebaseErrorHandler.handle(() async {
      final now = DateTime.now();
      print('📤 [subirCheckpoint] Iniciando subida optimizada de checkpoint');
      print('   Tipo: $tipo');
      print('   Fotos: ${fotosFiles.length}');

      // 1. Comprimir todas las fotos en paralelo
      print('🗜️ [subirCheckpoint] Comprimiendo ${fotosFiles.length} fotos...');
      final fotosComprimidas = await ImageCompressionService.compressImages(
        fotosFiles,
        quality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (fotosComprimidas.isEmpty) {
        throw Exception('Error al comprimir imágenes. Intenta nuevamente.');
      }
      
      print('✅ [subirCheckpoint] ${fotosComprimidas.length} fotos comprimidas');

      // 2. Subir fotos comprimidas a Storage
      final fotoUrls = <FotoCheckpoint>[];
      for (var i = 0; i < fotosComprimidas.length; i++) {
        final timestamp = now.millisecondsSinceEpoch;
        final fileName = '${tipo}_${timestamp}_$i.jpg';
        final ref = _storage.ref('fletes/$fleteId/checkpoints/$tipo/$fileName');

        print('📤 [subirCheckpoint] Subiendo foto ${i + 1}/${fotosComprimidas.length}...');
        await ref.putFile(
          fotosComprimidas[i],
          SettableMetadata(contentType: 'image/jpeg'),
        );

        final url = await ref.getDownloadURL();

        fotoUrls.add(FotoCheckpoint(
          url: url,
          storagePath: ref.fullPath,
          nombre: fileName,
          createdAt: now,
        ));
        
        print('✅ [subirCheckpoint] Foto ${i + 1} subida');
      }

      // 3. Limpiar archivos temporales
      await ImageCompressionService.cleanTempFiles();

      // 4. Guardar checkpoint en Firestore
      print('💾 [subirCheckpoint] Guardando checkpoint en Firestore...');
      final checkpointData = {
        'tipo': tipo,
        'chofer_id': choferId,
        'timestamp': Timestamp.fromDate(now),
        'ubicacion': ubicacion,
        'fotos': fotoUrls.map((f) => f.toJson()).toList(),
        'notas': notas,
        'completado': true,
        'created_at': Timestamp.fromDate(now),
      };

      if (gpsLink != null && gpsLink.isNotEmpty) {
        checkpointData['gps_link'] = gpsLink;
      }

      await _db
          .collection('fletes')
          .doc(fleteId)
          .collection('checkpoints')
          .doc(tipo)
          .set(checkpointData);
      
      print('✅ [subirCheckpoint] Checkpoint guardado en Firestore');

      // 5. Verificar si se completaron todos los checkpoints
      final checkpointsSnapshot = await _db
          .collection('fletes')
          .doc(fleteId)
          .collection('checkpoints')
          .get();

      final completados = checkpointsSnapshot.docs.length;
      final total = checkpointTypes.length;

      print('📊 [subirCheckpoint] Progreso: $completados/$total checkpoints');

      // 6. Actualizar estado del flete
      if (completados == total) {
        print('🎉 [subirCheckpoint] Todos los checkpoints completados!');
        await _db.collection('fletes').doc(fleteId).update({
          'estado': 'completado',
          'fecha_completado': Timestamp.fromDate(now),
          'updated_at': Timestamp.fromDate(now),
        });

        // Enviar notificaciones de completado
        final fleteDoc = await _db.collection('fletes').doc(fleteId).get();
        final fleteData = fleteDoc.data();
        if (fleteData != null) {
          final clienteId = fleteData['cliente_id'] as String;
          final transportistaId = fleteData['transportista_id'] as String?;
          final numeroContenedor =
              fleteData['numero_contenedor'] as String? ?? 'Sin número';

          // Notificar al cliente
          try {
            await _notificationService.enviarNotificacion(
              userId: clienteId,
              tipo: 'completado',
              titulo: '🎉 Flete Completado',
              mensaje:
                  'El flete $numeroContenedor ha sido completado exitosamente',
              fleteId: fleteId,
            );
          } catch (e) {
            print('⚠️ [subirCheckpoint] Error notificando al cliente: $e');
          }

          // Notificar al transportista
          if (transportistaId != null) {
            try {
              await _notificationService.enviarNotificacion(
                userId: transportistaId,
                tipo: 'completado',
                titulo: '✅ Flete Completado',
                mensaje: 'El flete $numeroContenedor ha sido completado',
                fleteId: fleteId,
              );
            } catch (e) {
              print(
                  '⚠️ [subirCheckpoint] Error notificando al transportista: $e');
            }
          }
        }
      } else {
        // Actualizar a en_proceso
        await _db.collection('fletes').doc(fleteId).update({
          'estado': 'en_proceso',
          'updated_at': Timestamp.fromDate(now),
        });
        print('✅ [subirCheckpoint] Flete actualizado a en_proceso');
      }

      // 7. Notificar progreso al cliente
      final fleteDoc = await _db.collection('fletes').doc(fleteId).get();
      final fleteData = fleteDoc.data();
      if (fleteData != null) {
        final clienteId = fleteData['cliente_id'] as String;
        final checkpointInfo =
            checkpointTypes.firstWhere((c) => c['id'] == tipo);

        try {
          await _notificationService.enviarNotificacion(
            userId: clienteId,
            tipo: 'checkpoint',
            titulo: completados == total
                ? '🎉 Flete Completado'
                : '📍 Checkpoint Completado',
            mensaje: completados == total
                ? 'Todos los checkpoints han sido completados'
                : 'Checkpoint: ${checkpointInfo['titulo']}',
            fleteId: fleteId,
          );
        } catch (e) {
          print('⚠️ [subirCheckpoint] Error enviando notificación: $e');
        }
      }

      print('🎉 [subirCheckpoint] Checkpoint subido exitosamente');
    });
  }
}
