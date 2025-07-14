import 'package:geolocator/geolocator.dart';
import 'dart:math';

class location {
  static const double radiusInMeters = 10; // نصف القطر بالمتر

  // قائمة النقاط المركزية [latitude, longitude]
  static const List<List<double>> centralPoints = [
    [30.0554003, 31.4172757], // ميديكال
    [29.9650797, 30.8935087], // البيت عندي
    [30.10576640 , 31.36615530] , // شيراتون
    [30.10585700 , 31.36623340] , //شيراتون
    [31.37081210 , 27.16980450] , // مطروح
    [30.02746540 , 31.49827870] , // بارك مول
    [30.09905650 , 31.38031180] , // خدمة العملاء
    [30.09904020 , 31.38034900] , // خدمة العملاء
    [30.05553880 , 31.41734310] , // ميديكال
    [30.83450680 , 28.92779750] , // ساحل
    [30.83691780 , 28.91898050] , // ساحل
    [30.83710300 , 28.92712060] , // ساحل

  ];

  // الحصول على الموقع الحالي
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // تحقق من تفعيل الـ GPS
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("⚠ GPS غير مفعل!");
        return null;
      }

      // تحقق من الأذونات
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          print("⚠ تم رفض إذن الموقع بشكل دائم! الرجاء تمكينه يدويًا.");
          return null;
        }
      }

      // الحصول على الموقع الحالي
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true, // تحسين الدقة لبعض الأجهزة
      );
    } catch (e) {
      print("❌ خطأ أثناء الحصول على الموقع: $e");
      return null;
    }
  }

  // حساب المسافة بين نقطتين
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371000; // نصف قطر الأرض بالمتر
    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // المسافة بالمتر
  }

  // التحقق من الحضور بناءً على عدة نقاط
  static Future<bool> isUserWithinRadius() async {
    Position? position = await getCurrentLocation();
    if (position == null) {
      print("⚠ تعذر تحديد الموقع الحالي.");
      return false;
    }

    print("📍 الموقع الحالي: ${position.latitude}, ${position.longitude}");

    for (var point in centralPoints) {
      double distance = calculateDistance(point[0], point[1], position.latitude, position.longitude);
      print("📏 المسافة إلى النقطة (${point[0]}, ${point[1]}): ${distance.toStringAsFixed(2)} متر");

      if (distance <= radiusInMeters) {
        print("✅ المستخدم داخل النطاق عند النقطة (${point[0]}, ${point[1]})");
        return true;
      }
    }

    print("❌ المستخدم خارج النطاق.");
    return false;
  }
}
