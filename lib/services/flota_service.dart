import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cargoclick/models/camion.dart';

class FlotaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Crea un nuevo camión para el transportista
  Future<String> crearCamion({
    required String transportistaId,
    required String patente,
    required String tipo,
    required String seguroCarga,
    required DateTime docVencimiento,
  }) async {
    try {
      final now = DateTime.now();
      final estadoDoc = Camion.calcularEstadoDocumentacion(docVencimiento);

      final camionData = {
        'transportista_id': transportistaId,
        'patente': patente.toUpperCase(),
        'tipo': tipo,
        'seguro_carga': seguroCarga,
        'doc_vencimiento': Timestamp.fromDate(docVencimiento),
        'estado_documentacion': estadoDoc,
        'disponible': true,
        'created_at': Timestamp.fromDate(now),
        'updated_at': Timestamp.fromDate(now),
      };

      final docRef = await _db.collection('camiones').add(camionData);
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear camión: $e');
    }
  }

  /// Obtiene todos los camiones de un transportista
  Stream<List<Camion>> obtenerCamionesTransportista(String transportistaId) {
    return _db
        .collection('camiones')
        .where('transportista_id', isEqualTo: transportistaId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Camion.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// Actualiza un camión existente
  Future<void> actualizarCamion({
    required String camionId,
    String? patente,
    String? tipo,
    String? seguroCarga,
    DateTime? docVencimiento,
    bool? disponible,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': Timestamp.fromDate(DateTime.now()),
      };

      if (patente != null) updateData['patente'] = patente.toUpperCase();
      if (tipo != null) updateData['tipo'] = tipo;
      if (seguroCarga != null) updateData['seguro_carga'] = seguroCarga;
      if (disponible != null) updateData['disponible'] = disponible;
      
      if (docVencimiento != null) {
        updateData['doc_vencimiento'] = Timestamp.fromDate(docVencimiento);
        updateData['estado_documentacion'] = Camion.calcularEstadoDocumentacion(docVencimiento);
      }

      await _db.collection('camiones').doc(camionId).update(updateData);
    } catch (e) {
      throw Exception('Error al actualizar camión: $e');
    }
  }

  /// Elimina un camión
  Future<void> eliminarCamion(String camionId) async {
    try {
      await _db.collection('camiones').doc(camionId).delete();
    } catch (e) {
      throw Exception('Error al eliminar camión: $e');
    }
  }

  /// Obtiene camiones disponibles de un transportista
  Stream<List<Camion>> obtenerCamionesDisponibles(String transportistaId) {
    return _db
        .collection('camiones')
        .where('transportista_id', isEqualTo: transportistaId)
        .where('disponible', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Camion.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// Obtiene un camión por ID
  Future<Camion?> obtenerCamion(String camionId) async {
    try {
      final doc = await _db.collection('camiones').doc(camionId).get();
      if (!doc.exists) return null;
      return Camion.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Error al obtener camión: $e');
    }
  }

  /// Actualiza el estado de documentación de todos los camiones (ejecutar periódicamente)
  Future<void> actualizarEstadosDocumentacion(String transportistaId) async {
    try {
      final snapshot = await _db
          .collection('camiones')
          .where('transportista_id', isEqualTo: transportistaId)
          .get();

      final batch = _db.batch();

      for (var doc in snapshot.docs) {
        final camion = Camion.fromJson(doc.data(), doc.id);
        final nuevoEstado = Camion.calcularEstadoDocumentacion(camion.docVencimiento);
        
        if (nuevoEstado != camion.estadoDocumentacion) {
          batch.update(doc.reference, {
            'estado_documentacion': nuevoEstado,
            'updated_at': Timestamp.fromDate(DateTime.now()),
          });
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error al actualizar estados: $e');
    }
  }
}
