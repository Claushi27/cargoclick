import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear un nuevo rating
  Future<void> crearRating({
    required String fleteId,
    required String clienteId,
    required String transportistaId,
    required int estrellas,
    String? comentario,
  }) async {
    try {
      final rating = Rating(
        fleteId: fleteId,
        clienteId: clienteId,
        transportistaId: transportistaId,
        estrellas: estrellas,
        comentario: comentario,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('ratings').add(rating.toJson());
      print('✅ Rating creado exitosamente');
    } catch (e) {
      print('❌ Error al crear rating: $e');
      rethrow;
    }
  }

  // Verificar si ya existe un rating para un flete
  Future<bool> existeRating(String fleteId) async {
    try {
      final snapshot = await _firestore
          .collection('ratings')
          .where('flete_id', isEqualTo: fleteId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error al verificar rating: $e');
      return false;
    }
  }

  // Obtener rating de un flete específico
  Future<Rating?> getRatingPorFlete(String fleteId) async {
    try {
      final snapshot = await _firestore
          .collection('ratings')
          .where('flete_id', isEqualTo: fleteId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return Rating.fromJson(
        snapshot.docs.first.data(),
        docId: snapshot.docs.first.id,
      );
    } catch (e) {
      print('❌ Error al obtener rating: $e');
      return null;
    }
  }

  // Obtener todos los ratings de un transportista
  Stream<List<Rating>> getRatingsTransportista(String transportistaId) {
    return _firestore
        .collection('ratings')
        .where('transportista_id', isEqualTo: transportistaId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Rating.fromJson(doc.data(), docId: doc.id))
            .toList());
  }

  // Calcular rating promedio de un transportista
  Future<double> getRatingPromedio(String transportistaId) async {
    try {
      final snapshot = await _firestore
          .collection('ratings')
          .where('transportista_id', isEqualTo: transportistaId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      final ratings = snapshot.docs
          .map((doc) => Rating.fromJson(doc.data(), docId: doc.id))
          .toList();

      final suma = ratings.fold<int>(0, (sum, rating) => sum + rating.estrellas);
      return suma / ratings.length;
    } catch (e) {
      print('❌ Error al calcular rating promedio: $e');
      return 0.0;
    }
  }

  // Obtener estadísticas de ratings (para dashboard transportista)
  Future<Map<String, dynamic>> getEstadisticasRatings(String transportistaId) async {
    try {
      final snapshot = await _firestore
          .collection('ratings')
          .where('transportista_id', isEqualTo: transportistaId)
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'total': 0,
          'promedio': 0.0,
          'por_estrellas': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        };
      }

      final ratings = snapshot.docs
          .map((doc) => Rating.fromJson(doc.data(), docId: doc.id))
          .toList();

      final porEstrellas = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
      for (var rating in ratings) {
        porEstrellas[rating.estrellas] = (porEstrellas[rating.estrellas] ?? 0) + 1;
      }

      final suma = ratings.fold<int>(0, (sum, rating) => sum + rating.estrellas);
      final promedio = suma / ratings.length;

      return {
        'total': ratings.length,
        'promedio': promedio,
        'por_estrellas': porEstrellas,
      };
    } catch (e) {
      print('❌ Error al obtener estadísticas: $e');
      return {
        'total': 0,
        'promedio': 0.0,
        'por_estrellas': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      };
    }
  }

  // Contar total de fletes publicados por un cliente
  Future<int> getTotalFletesCliente(String clienteId) async {
    try {
      final snapshot = await _firestore
          .collection('fletes')
          .where('cliente_id', isEqualTo: clienteId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error al contar fletes: $e');
      return 0;
    }
  }

  // Obtener información básica del cliente que publicó un flete
  Future<Map<String, dynamic>> getInfoCliente(String clienteId) async {
    try {
      // Obtener datos del usuario
      final userDoc = await _firestore
          .collection('users')
          .doc(clienteId)
          .get();

      if (!userDoc.exists) {
        return {
          'nombre': 'Cliente',
          'empresa': '',
          'telefono': '',
          'email': '',
          'totalFletes': 0,
        };
      }

      final userData = userDoc.data()!;
      final totalFletes = await getTotalFletesCliente(clienteId);

      return {
        'nombre': userData['display_name'] ?? 'Cliente',
        'empresa': userData['empresa'] ?? '',
        'telefono': userData['phone_number'] ?? '',
        'email': userData['email'] ?? '',
        'totalFletes': totalFletes,
      };
    } catch (e) {
      print('❌ Error al obtener info cliente: $e');
      return {
        'nombre': 'Cliente',
        'empresa': '',
        'telefono': '',
        'email': '',
        'totalFletes': 0,
      };
    }
  }
}
