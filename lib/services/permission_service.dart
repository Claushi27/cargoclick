import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Servicio para manejar permisos de la app con diálogos explicativos
/// Cumple con las políticas de Google Play
class PermissionService {
  /// Solicita permiso de cámara con explicación
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      // Mostrar por qué necesitamos el permiso
      final shouldRequest = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.camera_alt, color: Colors.orange),
              SizedBox(width: 8),
              Text('Permiso de Cámara'),
            ],
          ),
          content: const Text(
            'CargoClick necesita acceso a la cámara para:\n\n'
            '📸 Tomar fotos de los checkpoints del flete\n'
            '📦 Documentar el estado de la carga\n'
            '✅ Generar evidencia para el cliente\n\n'
            'Las fotos solo se usan para este propósito y se almacenan de forma segura.',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Permitir'),
            ),
          ],
        ),
      );

      if (shouldRequest == true) {
        final result = await Permission.camera.request();
        return result.isGranted;
      }
      return false;
    }

    if (status.isPermanentlyDenied) {
      // Llevar a configuración
      await _showPermanentlyDeniedDialog(
        context,
        title: 'Permiso de Cámara Denegado',
        message:
            'Has denegado permanentemente el permiso de cámara.\n\n'
            'Para tomar fotos de checkpoints, debes habilitar el permiso desde Configuración.',
      );
      return false;
    }

    return false;
  }

  /// Solicita permiso de ubicación con explicación
  static Future<bool> requestLocationPermission(BuildContext context) async {
    final status = await Permission.location.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      // Mostrar por qué necesitamos el permiso
      final shouldRequest = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_on, color: Colors.green),
              SizedBox(width: 8),
              Text('Permiso de Ubicación'),
            ],
          ),
          content: const Text(
            'CargoClick necesita acceso a tu ubicación para:\n\n'
            '📍 Registrar la ubicación exacta de cada checkpoint\n'
            '🗺️ Mostrar tracking en tiempo real al cliente\n'
            '✅ Verificar que estés en el lugar correcto\n\n'
            'La ubicación solo se registra durante checkpoints activos.',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Permitir'),
            ),
          ],
        ),
      );

      if (shouldRequest == true) {
        final result = await Permission.location.request();
        return result.isGranted;
      }
      return false;
    }

    if (status.isPermanentlyDenied) {
      // Llevar a configuración
      await _showPermanentlyDeniedDialog(
        context,
        title: 'Permiso de Ubicación Denegado',
        message:
            'Has denegado permanentemente el permiso de ubicación.\n\n'
            'Para registrar checkpoints con ubicación, debes habilitar el permiso desde Configuración.',
      );
      return false;
    }

    return false;
  }

  /// Solicita permiso de notificaciones con explicación
  static Future<bool> requestNotificationPermission(BuildContext context) async {
    final status = await Permission.notification.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      // Mostrar por qué necesitamos el permiso
      final shouldRequest = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.notifications, color: Colors.blue),
              SizedBox(width: 8),
              Text('Notificaciones'),
            ],
          ),
          content: const Text(
            'CargoClick te enviará notificaciones para:\n\n'
            '🚛 Cuando un transportista acepte tu flete\n'
            '📦 Cuando se complete un checkpoint\n'
            '✅ Cuando un flete sea completado\n'
            '🔄 Cambios en la asignación\n\n'
            'Las notificaciones te mantienen informado en tiempo real.',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Ahora no'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Activar'),
            ),
          ],
        ),
      );

      if (shouldRequest == true) {
        final result = await Permission.notification.request();
        return result.isGranted;
      }
      return false;
    }

    if (status.isPermanentlyDenied) {
      await _showPermanentlyDeniedDialog(
        context,
        title: 'Notificaciones Desactivadas',
        message:
            'Las notificaciones están desactivadas.\n\n'
            'Si deseas recibir actualizaciones en tiempo real, puedes habilitarlas desde Configuración.',
      );
      return false;
    }

    return false;
  }

  /// Muestra diálogo para permisos permanentemente denegados
  static Future<void> _showPermanentlyDeniedDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Abrir Configuración'),
          ),
        ],
      ),
    );
  }

  /// Verifica si tiene permisos mínimos necesarios
  static Future<bool> hasMinimumPermissions() async {
    final camera = await Permission.camera.isGranted;
    final location = await Permission.location.isGranted;
    return camera && location;
  }

  /// Solicita todos los permisos necesarios en el primer uso
  static Future<void> requestAllPermissions(BuildContext context) async {
    await requestCameraPermission(context);
    await requestLocationPermission(context);
    await requestNotificationPermission(context);
  }
}
