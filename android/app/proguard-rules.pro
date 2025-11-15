# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter embedding
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Google Play Core (deferred components)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**

# Firestore
-keep class com.google.firebase.firestore.** { *; }
-keepclassmembers class com.google.firebase.firestore.** { *; }

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }

# Firebase Messaging (Notificaciones)
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.iid.** { *; }

# Firebase Storage
-keep class com.google.firebase.storage.** { *; }

# Image picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# Permissions
-keep class com.baseflow.permissionhandler.** { *; }

# URL launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# Google Maps (si se usa)
-keep class com.google.android.gms.maps.** { *; }

# Preservar anotaciones
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exception

# Preservar números de línea para debugging
-keepattributes SourceFile,LineNumberTable

# Gson (usado por Firebase)
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Modelos de datos (ajustar según tu estructura)
-keep class com.cargoclick.app.models.** { *; }

# Prevenir warnings
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
