# Keep SLF4J bindings if present
-keep class org.slf4j.** { *; }
-dontwarn org.slf4j.**

# Jackson annotations and Java7 support used by some plugins
-keep class com.fasterxml.jackson.** { *; }
-dontwarn com.fasterxml.jackson.**
-keep class java.beans.** { *; }
-dontwarn java.beans.**

# Stripe / BouncyCastle conflicts
-dontwarn org.bouncycastle.**
-keep class org.bouncycastle.** { *; }
