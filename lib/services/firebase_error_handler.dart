import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Manejador centralizado de errores de Firebase
/// Convierte excepciones técnicas en mensajes amigables para el usuario
class FirebaseErrorHandler {
  /// Ejecuta una operación de Firebase y maneja errores comunes
  static Future<T> handle<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  /// Ejecuta una operación de Stream y maneja errores
  static Stream<T> handleStream<T>(Stream<T> stream) {
    return stream.handleError((error) {
      if (error is FirebaseException) {
        throw _handleFirebaseException(error);
      }
      throw Exception('Error inesperado: $error');
    });
  }

  static Exception _handleFirebaseException(FirebaseException e) {
    switch (e.code) {
      // Errores de red
      case 'unavailable':
      case 'network-request-failed':
        return Exception(
          'Sin conexión a internet. Verifica tu conexión y vuelve a intentar.',
        );

      // Errores de permisos
      case 'permission-denied':
        return Exception(
          'No tienes permiso para realizar esta acción. '
          'Contacta al administrador.',
        );

      // Errores de documentos
      case 'not-found':
        return Exception(
          'El documento solicitado no existe o fue eliminado.',
        );

      // Errores de Storage
      case 'storage/object-not-found':
        return Exception('El archivo no existe en el servidor.');

      case 'storage/unauthorized':
        return Exception(
          'No tienes permiso para acceder a este archivo.',
        );

      case 'storage/quota-exceeded':
        return Exception(
          'Se excedió el límite de almacenamiento. Contacta al administrador.',
        );

      case 'storage/retry-limit-exceeded':
        return Exception(
          'El archivo es muy grande o la conexión es inestable. Intenta con una mejor conexión.',
        );

      // Errores de autenticación
      case 'unauthenticated':
        return Exception(
          'Debes iniciar sesión para realizar esta acción.',
        );

      // Errores de validación
      case 'invalid-argument':
        return Exception(
          'Datos inválidos. Verifica la información ingresada.',
        );

      case 'already-exists':
        return Exception('Este elemento ya existe.');

      case 'failed-precondition':
        return Exception(
          'No se puede completar la operación. '
          'Verifica que se cumplan todas las condiciones necesarias.',
        );

      case 'aborted':
        return Exception(
          'La operación fue cancelada debido a un conflicto. '
          'Intenta nuevamente.',
        );

      case 'out-of-range':
        return Exception(
          'El valor ingresado está fuera del rango permitido.',
        );

      // Errores de recursos
      case 'resource-exhausted':
        return Exception(
          'Se excedió el límite de operaciones. Intenta en unos minutos.',
        );

      case 'deadline-exceeded':
        return Exception(
          'La operación tardó demasiado. Verifica tu conexión e intenta nuevamente.',
        );

      // Errores internos
      case 'internal':
      case 'unknown':
        return Exception(
          'Error interno del servidor. Intenta nuevamente en unos minutos.',
        );

      case 'data-loss':
        return Exception(
          'Se perdieron datos. Contacta al administrador inmediatamente.',
        );

      case 'unimplemented':
        return Exception(
          'Esta funcionalidad aún no está implementada.',
        );

      default:
        return Exception(
          'Error: ${e.message ?? e.code}\n'
          'Código: ${e.code}',
        );
    }
  }

  /// Maneja errores de Storage específicamente
  static Exception handleStorageError(FirebaseException e) {
    if (e.code.startsWith('storage/')) {
      return _handleFirebaseException(e);
    }

    switch (e.code) {
      case 'canceled':
        return Exception('Subida cancelada por el usuario.');

      default:
        return _handleFirebaseException(e);
    }
  }
}
