import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

/// Servicio para optimizar imágenes antes de subirlas a Firebase Storage
/// Reduce el tamaño de las fotos para ahorrar ancho de banda y almacenamiento
class ImageCompressionService {
  /// Comprime una imagen manteniendo buena calidad
  /// 
  /// Parámetros:
  /// - [imageFile]: Archivo de imagen original
  /// - [quality]: Calidad de compresión (0-100), default 70
  /// - [maxWidth]: Ancho máximo en píxeles, default 1024
  /// - [maxHeight]: Alto máximo en píxeles, default 1024
  /// 
  /// Returns: Archivo comprimido o null si falla
  static Future<File?> compressImage(
    File imageFile, {
    int quality = 70,
    int maxWidth = 1024,
    int maxHeight = 1024,
  }) async {
    try {
      print('🖼️ [ImageCompression] Iniciando compresión...');
      print('   Archivo original: ${imageFile.path}');
      print('   Tamaño original: ${(await imageFile.length() / 1024).toStringAsFixed(2)} KB');

      // Comprimir imagen
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes == null) {
        print('❌ [ImageCompression] Error: compressedBytes es null');
        return null;
      }

      print('✅ [ImageCompression] Imagen comprimida');
      print('   Tamaño comprimido: ${(compressedBytes.length / 1024).toStringAsFixed(2)} KB');
      print('   Reducción: ${(100 - (compressedBytes.length / await imageFile.length() * 100)).toStringAsFixed(1)}%');

      // Crear archivo temporal con la imagen comprimida
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      
      await tempFile.writeAsBytes(compressedBytes);
      print('💾 [ImageCompression] Archivo temporal creado: ${tempFile.path}');

      return tempFile;
    } catch (e) {
      print('❌ [ImageCompression] Error al comprimir imagen: $e');
      return null;
    }
  }

  /// Comprime múltiples imágenes en paralelo
  static Future<List<File>> compressImages(
    List<File> imageFiles, {
    int quality = 70,
    int maxWidth = 1024,
    int maxHeight = 1024,
  }) async {
    print('🖼️ [ImageCompression] Comprimiendo ${imageFiles.length} imágenes...');

    final compressedFiles = await Future.wait(
      imageFiles.map((file) => compressImage(
        file,
        quality: quality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      )),
    );

    // Filtrar nulls
    final validFiles = compressedFiles.whereType<File>().toList();
    
    print('✅ [ImageCompression] ${validFiles.length}/${imageFiles.length} imágenes comprimidas exitosamente');
    
    return validFiles;
  }

  /// Calcula el tamaño de un archivo en KB
  static Future<double> getFileSizeInKB(File file) async {
    final bytes = await file.length();
    return bytes / 1024;
  }

  /// Calcula el tamaño de un archivo en MB
  static Future<double> getFileSizeInMB(File file) async {
    final kb = await getFileSizeInKB(file);
    return kb / 1024;
  }

  /// Verifica si una imagen necesita compresión
  /// Returns true si el archivo es mayor a [maxSizeKB] kilobytes
  static Future<bool> needsCompression(File file, {int maxSizeKB = 500}) async {
    final sizeKB = await getFileSizeInKB(file);
    return sizeKB > maxSizeKB;
  }

  /// Limpia archivos temporales de compresión antiguos
  static Future<void> cleanTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      
      int deletedCount = 0;
      for (var file in files) {
        if (file.path.contains('compressed_') && file is File) {
          await file.delete();
          deletedCount++;
        }
      }
      
      print('🧹 [ImageCompression] Limpiados $deletedCount archivos temporales');
    } catch (e) {
      print('⚠️ [ImageCompression] Error limpiando archivos temporales: $e');
    }
  }
}
