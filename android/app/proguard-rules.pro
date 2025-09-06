# Keep Google ML Kit classes
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep Flutter plugins
-keep class io.flutter.plugins.** { *; }

# Keep specific ML Kit classes that are referenced
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.latin.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }