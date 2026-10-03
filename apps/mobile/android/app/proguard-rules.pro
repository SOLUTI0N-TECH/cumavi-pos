# ONNX Runtime (on-device background removal of product photos).
# Its native library looks up these Java classes, fields and methods by name
# through JNI; if R8 renames or strips them, the app aborts as soon as a
# photo is processed. The AAR ships no consumer rules, so keep them here.
-keep class ai.onnxruntime.** { *; }
-keepclassmembers class ai.onnxruntime.** { *; }
-dontwarn ai.onnxruntime.**
