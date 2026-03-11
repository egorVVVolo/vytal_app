# Сохраняем информацию о типах (Generics), это критично для Gson/TypeToken
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod

# Защищаем плагин уведомлений
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Защищаем Gson (библиотека, которую использует плагин внутри)
-keep class com.google.gson.** { *; }
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.stream.** { *; }

# Предотвращаем предупреждения, которые могут остановить сборку
-dontwarn sun.misc.**
-dontwarn com.google.gson.**