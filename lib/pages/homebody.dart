import 'dart:convert';

import 'package:attndance2/pages/notification.dart';
import 'package:attndance2/pages/signin.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:local_auth/local_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attndance2/pages/location.dart';
import 'package:http/http.dart' as http;
import 'package:ntp/ntp.dart';

class homebody extends StatefulWidget {
  const homebody({super.key});

  @override
  State<homebody> createState() => _homeState();
}

class _homeState extends State<homebody> {

  File? image;

  ScrollController _scrollController = ScrollController();
  int todayIndex = 0;

  late List<dynamic> jsonData1 ; // تحويل الاستجابة إلى JSON
  late List<Employee1> check =[];

  late List<dynamic> jsonData2 ; // تحويل الاستجابة إلى JSON
  late List<Employee1> check1 =[];

  late List<dynamic> jsonData3 ; // تحويل الاستجابة إلى JSON
  late List<Employee1> check2 =[];


  final LocalAuthentication auth = LocalAuthentication();
  bool isCheckedIn = false; // حالة تسجيل الدخول
  bool showSuccessIcon = false; // للتحكم في ظهور علامة الصح
  String lastCheckInDate = ""; // لتخزين آخر يوم تم تسجيل الدخول فيه

  late List<dynamic> jsonData ; // تحويل الاستجابة إلى JSON
  late List<Employee> employeess =[];
  int empId = 0 , vac=0 , hol=0 , off=0;
  String offDay = "";


  @override
  void initState() {
    super.initState();
    _loadImage(); // تحميل الصورة المحفوظة عند بدء التطبيق
    // حساب اليوم الحالي
    DateTime today = DateTime.now();
    todayIndex = getDaysInMonth(today).indexWhere((date) => date.day == today.day);

    // التمرير إلى اليوم الحالي بعد تحميل الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // تمرير الـ ScrollView إلى اليوم الحالي
        _scrollController.jumpTo(todayIndex * MediaQuery.of(context).size.width*16/100); // 80.0 هو عرض الـ Container
      }
    });

    _loadImage();
    _loadCheckInStatus(); // تحميل حالة Check-in عند بدء التطبيق
    loadEmployee();
    getNTPTime();


  }

  Future<void> loadEmployee() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empId = prefs.getInt('empId') ?? 0;
      vac = prefs.getInt('vac') ?? 0;
      hol = prefs.getInt('hol') ?? 0;
      off = prefs.getInt('offCount') ?? 0;
      offDay = prefs.getString('offDay') ?? '';
    });
  }

  Future<void> getNTPTime() async {
    DateTime ntpTime = await NTP.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("last_ntp_time", ntpTime.toIso8601String());
  }

  Future<bool> isTimeValidForFingerprint() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    DateTime deviceTime = DateTime.now();

    // آخر وقت موثوق محفوظ من NTP
    String? lastNTPString = prefs.getString("last_ntp_time");
    DateTime? lastTrustedTime = lastNTPString != null ? DateTime.parse(lastNTPString) : null;

    // التأكد لو التاريخ من الجهاز أكبر من الوقت الفعلي
    if (lastTrustedTime != null) {
      // إذا كان التاريخ الحالي أقل من آخر تاريخ موثوق، يعني هو رجع لورا في التاريخ
      if (deviceTime.isBefore(lastTrustedTime)) {
        return false; // التاريخ رجع لورا
      }

      // إذا كان الفرق بين التاريخ الحالي و آخر وقت موثوق أكبر من يوم، نرفض البصمة
      if (deviceTime.isAfter(lastTrustedTime.add(Duration(days: 1)))) {
        return false; // التاريخ تقدم لأكثر من يوم
      }
    }

    // الوقت موثوق وداخل الحدود المقبولة
    return true;
  }

  Future<void> getTime() async {

    // تجاوز التحقق من SSL أثناء التطوير
    HttpOverrides.global = MyHttpOverrides();
    final http.Client client = http.Client();

    final response = await client.get(
      Uri.parse("http://41.33.98.4:1738/api/emp/startTime/${empId}"),
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode == 200) {
      jsonData = jsonDecode(response.body); // تحويل الاستجابة إلى JSON
      employeess = jsonData.map((e) => Employee.fromJson(e)).toList();
      DateTime today = DateTime.now();
      todayIndex = getDaysInMonth(today).indexWhere((date) => date.day == today.day);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(todayIndex * MediaQuery.of(context).size.width * 16 / 100);
        }
      });
    } else {
      throw Exception("فشل في جلب البيانات: ${response.statusCode}");
    }
  }

  Future<void> checkAndInsertHolidays() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    // استرجع آخر شهر وسنة تم تسجيلهم
    int lastMonth = prefs.getInt('lastHolidayMonth') ?? -1;
    int lastYear = prefs.getInt('lastHolidayYear') ?? -1;

    // لو أول مرة في الشهر الحالي
    if (lastMonth != now.month || lastYear != now.year) {

      if(offDay == "Friday")
        {
          List<DateTime> myFridays = getAllFridaysInCurrentMonth();
          List<String> datesToSend = myFridays
              .map((date) => DateFormat('yyyy-MM-dd').format(date))
              .toList();

          for(int i=0 ; i<myFridays.length ; i++)
            {
              // تجاوز التحقق من SSL أثناء التطوير
              HttpOverrides.global = MyHttpOverrides();
              final http.Client client = http.Client();

              final response1 = await client.post(
                Uri.parse("http://41.33.98.4:1738/api/attend"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "empId": empId,
                  "depId": employeess[0].depid,
                  "toDay": datesToSend[i],
                  "alpha": "o",
                }),
              );
            }
        }else{
        List<DateTime> myFridaysandsat = getAllFridaysAndSaturdaysInCurrentMonth();
        List<String> datesToSend = myFridaysandsat
            .map((date) => DateFormat('yyyy-MM-dd').format(date))
            .toList();

        for(int i=0 ; i<myFridaysandsat.length ; i++)
        {
          // تجاوز التحقق من SSL أثناء التطوير
          HttpOverrides.global = MyHttpOverrides();
          final http.Client client = http.Client();

          final response1 = await client.post(
            Uri.parse("http://41.33.98.4:1738/api/attend"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "empId": empId,
              "depId": employeess[0].depid,
              "toDay": datesToSend[i],
              "alpha": "o",
            }),

          );
        }
      }

      await prefs.setInt('lastHolidayMonth', now.month);
      await prefs.setInt('lastHolidayYear', now.year);
    } else {
    }
  }


  Future<void> postAttend() async {

    await checkAndInsertHolidays();

    if(await isTimeValidForFingerprint())
      {
        String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

        DateTime date = DateTime.parse(todayDate);
        DateTime yesterday = date.subtract(Duration(days: 1));
        DateTime yesterday1 = date.subtract(Duration(days: 2));

        String yesterdayString = DateFormat('yyyy-MM-dd').format(yesterday);
        String yesterdayString1 = DateFormat('yyyy-MM-dd').format(yesterday1);

        String currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
        DateFormat format = DateFormat("HH:mm:ss");
        DateTime time = format.parse(employeess[0].starttime);
        DateTime timenow = format.parse(currentTime);
        DateTime time15min = time.add(Duration(minutes: 15));
        DateTime time30min = time.add(Duration(minutes: 30));

        String endTime = addHoursToTime(employeess[0].starttime , employeess[0].workhours);
        DateTime timeout = format.parse(endTime);
        DateTime time15minout = timeout.subtract(Duration(minutes: 15));

        // تجاوز التحقق من SSL أثناء التطوير
        HttpOverrides.global = MyHttpOverrides();
        final http.Client client = http.Client();

        final response = await client.get(
          Uri.parse("http://41.33.98.4:1738/api/attend/check/${empId}/${yesterdayString}"),
          headers: {"Content-Type": "application/json"},
        );
        if (response.statusCode == 200) {
          jsonData2 = jsonDecode(response.body);
          check1 = jsonData2.map((e) => Employee1.fromJson(e)).toList();
        } else {
          throw Exception("فشل في جلب البيانات: ${response.statusCode}");
        }
        if(check1.isEmpty)
        {
          // تجاوز التحقق من SSL أثناء التطوير
          HttpOverrides.global = MyHttpOverrides();
          final http.Client client = http.Client();

          final response1 = await client.post(
            Uri.parse("http://41.33.98.4:1738/api/attend"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "empId": empId,
              "depId": employeess[0].depid,
              "toDay": yesterdayString,
              "alpha": "x",
            }),
          );

          final response = await client.get(
            Uri.parse("http://41.33.98.4:1738/api/attend/check/${empId}/${yesterdayString1}"),
            headers: {"Content-Type": "application/json"},
          );
          if (response.statusCode == 200) {
            jsonData3 = jsonDecode(response.body);
            check2 = jsonData3.map((e) => Employee1.fromJson(e)).toList();
          } else {
            throw Exception("فشل في جلب البيانات: ${response.statusCode}");
          }

          if(check2.isEmpty)
          {
            // تجاوز التحقق من SSL أثناء التطوير
            HttpOverrides.global = MyHttpOverrides();
            final http.Client client = http.Client();

            final response1 = await client.post(
              Uri.parse("http://41.33.98.4:1738/api/attend"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "empId": empId,
                "depId": employeess[0].depid,
                "toDay": yesterdayString1,
                "alpha": "x",
              }),
            );
          }
        }

        final response1 = await client.get(
          Uri.parse("http://41.33.98.4:1738/api/attend/check/${empId}/${todayDate}"),
          headers: {"Content-Type": "application/json"},
        );
        if (response1.statusCode == 200) {
          jsonData1 = jsonDecode(response1.body);
          check = jsonData1.map((e) => Employee1.fromJson(e)).toList();
        } else {
          throw Exception("فشل في جلب البيانات: ${response1.statusCode}");
        }


        if(check.isEmpty)
        {
          if(employeess[0].vip != "yes" && employeess[0].flex != "yes")
          {
            if(timenow.isBefore(time15min))
            {
              // تجاوز التحقق من SSL أثناء التطوير
              HttpOverrides.global = MyHttpOverrides();
              final http.Client client = http.Client();

              final response = await client.post(
                Uri.parse("http://41.33.98.4:1738/api/attend"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "empId": empId,
                  "depId": employeess[0].depid,
                  "toDay": todayDate,
                  "startHour": currentTime,
                  "alpha": "on",
                }),
              );
            }
            else if(timenow.isBefore(time30min))
            {
              // تجاوز التحقق من SSL أثناء التطوير
              HttpOverrides.global = MyHttpOverrides();
              final http.Client client = http.Client();

              final response = await client.post(
                Uri.parse("http://41.33.98.4:1738/api/attend"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "empId": empId,
                  "depId": employeess[0].depid,
                  "toDay": todayDate,
                  "startHour": currentTime,
                  "alpha": "d",
                }),
              );
            }
            else if(timenow.isAfter(time30min))
            {
              // تجاوز التحقق من SSL أثناء التطوير
              HttpOverrides.global = MyHttpOverrides();
              final http.Client client = http.Client();

              final response = await client.post(
                Uri.parse("http://41.33.98.4:1738/api/attend"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "empId": empId,
                  "depId": employeess[0].depid,
                  "toDay": todayDate,
                  "startHour": currentTime,
                  "alpha": "dd",
                }),
              );
            }
          }
          else
          {
            // تجاوز التحقق من SSL أثناء التطوير
            HttpOverrides.global = MyHttpOverrides();
            final http.Client client = http.Client();

            final response = await client.post(
              Uri.parse("http://41.33.98.4:1738/api/attend"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "empId": empId,
                "depId": employeess[0].depid,
                "toDay": todayDate,
                "startHour": currentTime,
                "alpha": "on",
              }),
            );
          }
        }
        else
        {
          if(employeess[0].vip == "yes")
            {
              // تجاوز التحقق من SSL أثناء التطوير
              HttpOverrides.global = MyHttpOverrides();
              final http.Client client = http.Client();

              final response = await client.put(
                Uri.parse("http://41.33.98.4:1738/api/attend/update/${empId}/${todayDate}"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "newEnd": currentTime,
                  "newAlpha": "on",
                }),
              );
            }
          else
            {
              if(check[0].alpha == "d")
              {
                // تجاوز التحقق من SSL أثناء التطوير
                HttpOverrides.global = MyHttpOverrides();
                final http.Client client = http.Client();

                final response = await client.put(
                  Uri.parse("http://41.33.98.4:1738/api/attend/update/${empId}/${todayDate}"),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "newEnd": currentTime.toString(),
                    "newAlpha": "d",
                  }),
                );
              }
              else if(check[0].alpha == "dd")
              {
                // تجاوز التحقق من SSL أثناء التطوير
                HttpOverrides.global = MyHttpOverrides();
                final http.Client client = http.Client();

                final response = await client.put(
                  Uri.parse("http://41.33.98.4:1738/api/attend/update/${empId}/${todayDate}"),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "newEnd": currentTime,
                    "newAlpha": "dd",
                  }),
                );
              }
              else if(check[0].alpha == "v")
              {
                if(timenow.isBefore(time15min))
                {
                  // تجاوز التحقق من SSL أثناء التطوير
                  HttpOverrides.global = MyHttpOverrides();
                  final http.Client client = http.Client();

                  final response = await client.put(
                    Uri.parse("http://41.33.98.4:1738/api/attend/updatestart/${empId}/${todayDate}"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "newStart": currentTime,
                      "newAlpha": "on",
                    }),
                  );
                }
                else if(timenow.isBefore(time30min))
                {
                  // تجاوز التحقق من SSL أثناء التطوير
                  HttpOverrides.global = MyHttpOverrides();
                  final http.Client client = http.Client();

                  final response = await client.put(
                    Uri.parse("http://41.33.98.4:1738/api/attend/updatestart/${empId}/${todayDate}"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "newStart": currentTime,
                      "newAlpha": "d",
                    }),
                  );
                }
                else if(timenow.isAfter(time30min))
                {
                  // تجاوز التحقق من SSL أثناء التطوير
                  HttpOverrides.global = MyHttpOverrides();
                  final http.Client client = http.Client();

                  final response = await client.put(
                    Uri.parse("http://41.33.98.4:1738/api/attend/updatestart/${empId}/${todayDate}"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "newStart": currentTime,
                      "newAlpha": "dd",
                    }),
                  );
                }

                final response1 = await client.put(
                  Uri.parse("http://41.33.98.4:1738/api/notification/updateVac/${empId}"),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "newVac": vac+1,
                  }),
                );


              }
              else if(check[0].alpha == "p")
              {
                if(isCheckedIn)
                {
                  if(check[0].alpha == "d")
                  {
                    // تجاوز التحقق من SSL أثناء التطوير
                    HttpOverrides.global = MyHttpOverrides();
                    final http.Client client = http.Client();

                    final response = await client.put(
                      Uri.parse("http://41.33.98.4:1738/api/attend/update/${empId}/${todayDate}"),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "newEnd": currentTime.toString(),
                        "newAlpha": "d",
                      }),
                    );
                  }
                  else if(check[0].alpha == "dd")
                  {
                    // تجاوز التحقق من SSL أثناء التطوير
                    HttpOverrides.global = MyHttpOverrides();
                    final http.Client client = http.Client();

                    final response = await client.put(
                      Uri.parse("http://41.33.98.4:1738/api/attend/update/${empId}/${todayDate}"),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "newEnd": currentTime,
                        "newAlpha": "dd",
                      }),
                    );
                  }else{
                    // تجاوز التحقق من SSL أثناء التطوير
                    HttpOverrides.global = MyHttpOverrides();
                    final http.Client client = http.Client();

                    final response = await client.put(
                      Uri.parse("http://41.33.98.4:1738/api/attend/update/${empId}/${todayDate}"),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "newEnd": currentTime,
                        "newAlpha": "on",
                      }),
                    );
                  }
                }
                else {
                  if(check[0].startHour == null)
                  {
                    if(timenow.isBefore(time15min))
                    {
                      // تجاوز التحقق من SSL أثناء التطوير
                      HttpOverrides.global = MyHttpOverrides();
                      final http.Client client = http.Client();

                      final response = await client.put(
                        Uri.parse("http://41.33.98.4:1738/api/attend/updatestart/${empId}/${todayDate}"),
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode({
                          "newStart": currentTime,
                          "newAlpha": "on",
                        }),
                      );
                    }
                    else if(timenow.isBefore(time30min))
                    {
                      // تجاوز التحقق من SSL أثناء التطوير
                      HttpOverrides.global = MyHttpOverrides();
                      final http.Client client = http.Client();

                      final response = await client.put(
                        Uri.parse("http://41.33.98.4:1738/api/attend/updatestart/${empId}/${todayDate}"),
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode({
                          "newStart": currentTime,
                          "newAlpha": "d",
                        }),
                      );
                    }
                    else if(timenow.isAfter(time30min))
                    {
                      // تجاوز التحقق من SSL أثناء التطوير
                      HttpOverrides.global = MyHttpOverrides();
                      final http.Client client = http.Client();

                      final response = await client.put(
                        Uri.parse("http://41.33.98.4:1738/api/attend/updatestart/${empId}/${todayDate}"),
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode({
                          "newStart": currentTime,
                          "newAlpha": "dd",
                        }),
                      );
                    }
                  }else{

                    String currentTime1 = DateFormat('HH:mm:ss').format(DateTime.now());
                    DateFormat format1 = DateFormat("HH:mm:ss");
                    DateTime time1 = format1.parse(check[0].startHour.toString());
                    DateTime timenow1 = format1.parse(currentTime1);
                    DateTime time15min1 = time1.add(Duration(minutes: 15));
                    DateTime time30min1 = time1.add(Duration(minutes: 30));

                    if(timenow.isBefore(time15min1))
                    {
                      // تجاوز التحقق من SSL أثناء التطوير
                      HttpOverrides.global = MyHttpOverrides();
                      final http.Client client = http.Client();

                      final response = await client.put(
                        Uri.parse("http://41.33.98.4:1738/api/attend/updatestart/${empId}/${todayDate}"),
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode({
                          "newStart": currentTime,
                          "newAlpha": "on",
                        }),
                      );
                    }
                    else if(timenow.isBefore(time30min1))
                    {
                      // تجاوز التحقق من SSL أثناء التطوير
                      HttpOverrides.global = MyHttpOverrides();
                      final http.Client client = http.Client();

                      final response = await client.put(
                        Uri.parse("http://41.33.98.4:1738/api/attend/updatestart/${empId}/${todayDate}"),
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode({
                          "newStart": currentTime,
                          "newAlpha": "d",
                        }),
                      );
                    }
                    else if(timenow.isAfter(time30min1))
                    {
                      // تجاوز التحقق من SSL أثناء التطوير
                      HttpOverrides.global = MyHttpOverrides();
                      final http.Client client = http.Client();

                      final response = await client.put(
                        Uri.parse("http://41.33.98.4:1738/api/attend/updatestart/${empId}/${todayDate}"),
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode({
                          "newStart": currentTime,
                          "newAlpha": "dd",
                        }),
                      );
                    }
                  }
                }

              }
              else if(check[0].alpha == "h")
              {
                if (timenow.isBefore(time15min)) {
                  // تجاوز التحقق من SSL أثناء التطوير
                  HttpOverrides.global = MyHttpOverrides();
                  final http.Client client = http.Client();

                  final response = await client.put(
                    Uri.parse(
                        "http://41.33.98.4:1738/api/attend/updatestart/${empId}/${todayDate}"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "newStart": currentTime,
                      "newAlpha": "on",
                    }),
                  );
                }
                else if (timenow.isBefore(time30min)) {
                  // تجاوز التحقق من SSL أثناء التطوير
                  HttpOverrides.global = MyHttpOverrides();
                  final http.Client client = http.Client();

                  final response = await client.put(
                    Uri.parse(
                        "http://41.33.98.4:1738/api/attend/updatestart/${empId}/${todayDate}"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "newStart": currentTime,
                      "newAlpha": "d",
                    }),
                  );
                }
                else if (timenow.isAfter(time30min)) {
                  // تجاوز التحقق من SSL أثناء التطوير
                  HttpOverrides.global = MyHttpOverrides();
                  final http.Client client = http.Client();

                  final response = await client.put(
                    Uri.parse(
                        "http://41.33.98.4:1738/api/attend/updatestart/${empId}/${todayDate}"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "newStart": currentTime,
                      "newAlpha": "dd",
                    }),
                  );
                }

                final response1 = await client.put(
                  Uri.parse(
                      "http://41.33.98.4:1738/api/notification/updateHol/${empId}"),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "newHol": hol + 1,
                  }),
                );

              }
              else if(check[0].alpha == "o")
              {
                if(timenow.isBefore(time15min))
                {
                  // تجاوز التحقق من SSL أثناء التطوير
                  HttpOverrides.global = MyHttpOverrides();
                  final http.Client client = http.Client();

                  final response = await client.put(
                    Uri.parse("http://41.33.98.4:1738/api/attend/updatestart/${empId}/${todayDate}"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "newStart": currentTime,
                      "newAlpha": "on",
                    }),
                  );
                }
                else if(timenow.isBefore(time30min))
                {
                  // تجاوز التحقق من SSL أثناء التطوير
                  HttpOverrides.global = MyHttpOverrides();
                  final http.Client client = http.Client();

                  final response = await client.put(
                    Uri.parse("http://41.33.98.4:1738/api/attend/updatestart/${empId}/${todayDate}"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "newStart": currentTime,
                      "newAlpha": "d",
                    }),
                  );
                }
                else if(timenow.isAfter(time30min))
                {
                  // تجاوز التحقق من SSL أثناء التطوير
                  HttpOverrides.global = MyHttpOverrides();
                  final http.Client client = http.Client();

                  final response = await client.put(
                    Uri.parse("http://41.33.98.4:1738/api/attend/updatestart/${empId}/${todayDate}"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "newStart": currentTime,
                      "newAlpha": "dd",
                    }),
                  );
                }

                final response1 = await client.put(
                  Uri.parse("http://41.33.98.4:1738/api/notification/updateOff/${empId}"),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "newOff": off+1,
                  }),
                );


              }
              else if(check[0].alpha == "on")
              {
                if(timenow.isBefore(time15minout))
                {
                  // تجاوز التحقق من SSL أثناء التطوير
                  HttpOverrides.global = MyHttpOverrides();
                  final http.Client client = http.Client();

                  final response = await client.put(
                    Uri.parse("http://41.33.98.4:1738/api/attend/update/${empId}/${todayDate}"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "newEnd": currentTime,
                      "newAlpha": "d",
                    }),
                  );
                }
                else
                {
                  // تجاوز التحقق من SSL أثناء التطوير
                  HttpOverrides.global = MyHttpOverrides();
                  final http.Client client = http.Client();

                  final response = await client.put(
                    Uri.parse("http://41.33.98.4:1738/api/attend/update/${empId}/${todayDate}"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "newEnd": currentTime,
                      "newAlpha": "on",
                    }),
                  );
                }

              }
            }
        }

      }
    else{
      // يمكنك أيضًا عرض رسالة باستخدام Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("تم التلاعب في التاريخ"),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // دالة تجيب كل أيام الجمعة في الشهر الحالي
  List<DateTime> getAllFridaysInCurrentMonth() {
    DateTime now = DateTime.now();
    int year = now.year;
    int month = now.month;

    List<DateTime> fridays = [];
    DateTime date = DateTime(year, month, 1);

    while (date.month == month) {
      if (date.weekday == DateTime.friday) {
        fridays.add(date);
      }
      date = date.add(Duration(days: 1));
    }

    return fridays;
  }

  // دالة تجيب كل أيام الجمعة والسبت في الشهر الحالي
  List<DateTime> getAllFridaysAndSaturdaysInCurrentMonth() {
    DateTime now = DateTime.now();
    int year = now.year;
    int month = now.month;

    List<DateTime> days = [];
    DateTime date = DateTime(year, month, 1);

    while (date.month == month) {
      if (date.weekday == DateTime.friday || date.weekday == DateTime.saturday) {
        days.add(date);
      }
      date = date.add(Duration(days: 1));
    }

    return days;
  }

  String addMinutesToTime(String timeString, int minutesToAdd) {
    // 1️⃣ تحويل الـ String إلى DateTime
    DateTime time = DateTime.parse("2000-01-01 $timeString"); // تعيين تاريخ وهمي لأننا نهتم فقط بالوقت

    // 2️⃣ إضافة 15 دقيقة
    DateTime newTime = time.add(Duration(minutes: minutesToAdd));

    // 3️⃣ تحويله إلى String بصيغة HH:mm:ss
    return "${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}:${newTime.second.toString().padLeft(2, '0')}";
  }

  String addHoursToTime(String timeString, int hoursToAdd) {
    // 1️⃣ تحويل الـ String إلى DateTime
    DateTime time = DateTime.parse("2000-01-01 $timeString"); // تعيين تاريخ وهمي لأننا نهتم فقط بالوقت

    DateTime newTime = time.add(Duration(hours: hoursToAdd));

    // 3️⃣ تحويله إلى String بصيغة HH:mm:ss
    return "${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}:${newTime.second.toString().padLeft(2, '0')}";
  }


  Future<void> _loadImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('saved_image');

    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        image = File(imagePath); // تحميل الصورة وتحديث الواجهة
      });
    }
  }

  List<DateTime> getDaysInMonth(DateTime date) {
    int year = date.year;
    int month = date.month;
    int daysInMonth = DateTime(year, month + 1, 0).day;

    return List.generate(daysInMonth, (index) => DateTime(year, month, index + 1));
  }

  Future<void> _loadCheckInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedDate = prefs.getString('last_check_in_date');
    bool? savedCheckIn = prefs.getBool('is_checked_in');

    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (savedDate == todayDate && savedCheckIn == true) {
      setState(() {
        isCheckedIn = true; // يبقى في حالة Check-out إذا كان نفس اليوم
      });
    } else {
      setState(() {
        isCheckedIn = false; // إعادة الحالة إلى Check-in في يوم جديد
      });
    }
  }

  Future<void> _authenticate() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Scan your finger!',
        options: AuthenticationOptions(biometricOnly: true),
      );

      if (authenticated) {
        bool isWithinArea = await location.isUserWithinRadius();
        if(isWithinArea)
        {
          setState(() {
            showSuccessIcon = true; // عرض أيقونة ✅ لحظياً
          });

          await Future.delayed(Duration(seconds: 2)); // انتظر ثانيتين

          setState(() {
            isCheckedIn = !isCheckedIn; // تغيير الحالة
            showSuccessIcon = false; // إخفاء الأيقونة ✅ وإعادة أيقونة البصمة
          });

          await postAttend();

          // حفظ الحالة في التخزين
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_checked_in', isCheckedIn);
          await prefs.setString('last_check_in_date', DateFormat('yyyy-MM-dd').format(DateTime.now()));
        }
        else{
          // يمكنك أيضًا عرض رسالة باستخدام Snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("موقع خاطئ"),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("حدث خطأ أثناء التحقق: $e");
    }
  }


  @override
  Widget build(BuildContext context) {

    List<DateTime> daysInMonth = getDaysInMonth(DateTime.now());

    return  Scaffold(
        body: FutureBuilder<void>(
          future: getTime(), // 1️⃣ استدعاء الدالة مباشرة هنا
          builder: (context, snapshot) {
            if (employeess.isEmpty) {
              return Center(child: CircularProgressIndicator()); // ⏳ جاري التحميل
            } else {
              String updatedTime = addMinutesToTime(employeess[0].starttime , 15);
              String endTime = addHoursToTime(employeess[0].starttime , employeess[0].workhours);
              return Column(
                  children:[
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15,
                              top: 50
                          ),
                          child: CircleAvatar(
                            radius: MediaQuery.of(context).size.height*3/100,
                            backgroundImage: image != null ? FileImage(image!) : null,
                            backgroundColor: Colors.grey[300],

                          ),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width*5/100,),
                        Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 50
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      employeess[0].name.toString(),
                                      style: TextStyle(
                                          color: Colors.black ,
                                          fontSize: MediaQuery.of(context).size.height*2/100,
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                  SizedBox(height:MediaQuery.of(context).size.height*1/150 ,),
                                  Text(
                                      employeess[0].idd.toString(),
                                      style: TextStyle(
                                          color: Colors.black ,
                                          fontSize: MediaQuery.of(context).size.height*2/120,
                                          fontWeight: FontWeight.w500
                                      )
                                  ),

                                ],
                              ),
                            )
                        ),
                        Padding(
                            padding: const EdgeInsets.only(
                                top: 50
                            ),
                            child: GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => notification()));
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.height*6/100,
                                    height: MediaQuery.of(context).size.height*6/100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF0E41DB),
                                    ),
                                  ),
                                  CircleAvatar(
                                    radius: MediaQuery.of(context).size.height*3/105,
                                    backgroundColor:Color(0xFFF0F4FF) ,
                                    child: Icon(FontAwesomeIcons.bell),
                                  ),
                                ],
                              ),
                            )
                        ),
                        SizedBox(width: 15,),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*3/100,),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      child: Row(
                        children: daysInMonth.map((date) {
                          bool isToday = DateFormat('d').format(date) == DateFormat('d').format(DateTime.now());
                          return Container(
                            width: MediaQuery.of(context).size.width*16/100,
                            margin: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                            padding: EdgeInsets.all(MediaQuery.of(context).size.height*2/160),
                            decoration: BoxDecoration(
                              color: isToday ? Color(0xFF0E41DB): Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Color(0xFF0E41DB), width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('d').format(date), // اليوم (رقم)
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.height*2/100,
                                    fontWeight: FontWeight.bold,
                                    color: isToday ? Colors.white : Colors.black,
                                  ),

                                ),
                                Text(
                                  DateFormat('EEE').format(date), // اسم اليوم باللغة الافتراضية
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.height*2/120,
                                    color: isToday ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*2/100,),
                    Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                              top: 15 ,
                              left: MediaQuery.of(context).size.width*5/100 ,
                              right: MediaQuery.of(context).size.width*5/100,
                              bottom: 10.0),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(color: Color(0xFFF0F4FF) ,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(30) , topRight: Radius.circular(30))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Today Attendance",
                                  style: TextStyle(
                                      color: Colors.black ,
                                      fontSize: MediaQuery.of(context).size.height*2/100,
                                      fontWeight: FontWeight.bold
                                  )
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*2/100,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: 15,
                                          left: MediaQuery.of(context).size.width*4/100 ,
                                          right: MediaQuery.of(context).size.width*4/100 ,
                                          bottom: 10.0),
                                      decoration: BoxDecoration(color: Colors.white ,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.green.shade200.withOpacity(0.5), // لون الشادو متناسق مع البطاقة
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                              offset: Offset(4, 4),
                                            ),
                                          ],
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(30) ,
                                            topRight: Radius.circular(30),
                                            bottomLeft: Radius.circular(30),
                                            bottomRight: Radius.circular(30),
                                          )),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.login,
                                                size:  MediaQuery.of(context).size.height*4/100,
                                              ),
                                              SizedBox(width:  MediaQuery.of(context).size.height*2/130,),
                                              Text(
                                                  "Check In",
                                                  style: TextStyle(
                                                      color: Colors.black ,
                                                      fontSize: MediaQuery.of(context).size.height*2/100,
                                                      fontWeight: FontWeight.w500
                                                  )
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: MediaQuery.of(context).size.height*2/130,),
                                          Text(
                                              "${updatedTime}",
                                              style: TextStyle(
                                                  color: Colors.black ,
                                                  fontSize: MediaQuery.of(context).size.height*2/70,
                                                  fontWeight: FontWeight.bold
                                              )
                                          ),
                                          SizedBox(height: MediaQuery.of(context).size.height*2/130,),
                                          Text(
                                              "On Time",
                                              style: TextStyle(
                                                  color: Colors.black ,
                                                  fontSize: MediaQuery.of(context).size.height*2/100,
                                                  fontWeight: FontWeight.w500
                                              )
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width*4/100),
                                  Expanded(
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            top: 15,
                                            left: MediaQuery.of(context).size.width*4/100 ,
                                            right: MediaQuery.of(context).size.width*4/100 ,
                                            bottom: 10.0),
                                        decoration: BoxDecoration(color: Colors.white ,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.red.shade200.withOpacity(0.5), // لون الشادو متناسق مع البطاقة
                                                blurRadius: 10,
                                                spreadRadius: 2,
                                                offset: Offset(4, 4),
                                              ),
                                            ],
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(30) ,
                                              topRight: Radius.circular(30),
                                              bottomLeft: Radius.circular(30),
                                              bottomRight: Radius.circular(30),
                                            )),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.logout_outlined,
                                                  size:  MediaQuery.of(context).size.height*4/100,
                                                ),
                                                SizedBox(width:  MediaQuery.of(context).size.height*2/130,),
                                                Text(
                                                    "Check Out",
                                                    style: TextStyle(
                                                        color: Colors.black ,
                                                        fontSize: MediaQuery.of(context).size.height*2/100,
                                                        fontWeight: FontWeight.w500
                                                    )
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: MediaQuery.of(context).size.height*2/130,),
                                            Text(
                                                "${endTime}",
                                                style: TextStyle(
                                                    color: Colors.black ,
                                                    fontSize: MediaQuery.of(context).size.height*2/70,
                                                    fontWeight: FontWeight.bold
                                                )
                                            ),
                                            SizedBox(height: MediaQuery.of(context).size.height*2/130,),
                                            Text(
                                                "Go Home",
                                                style: TextStyle(
                                                    color: Colors.black ,
                                                    fontSize: MediaQuery.of(context).size.height*2/100,
                                                    fontWeight: FontWeight.w500
                                                )
                                            ),
                                          ],
                                        ),
                                      )
                                  ),
                                  //SizedBox(width: 30),
                                ],
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*3/100,),
                              Center(
                                child: _buildClock(),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*2/100,),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedSwitcher(
                                      duration: Duration(milliseconds: 500), // تأثير تنقلي
                                      child: showSuccessIcon
                                          ? Icon(Icons.check_circle, color: Colors.green,
                                          size: MediaQuery.of(context).size.height*17/100, key: ValueKey(1))
                                          : Icon(Icons.fingerprint, color: Colors.blue,
                                          size: MediaQuery.of(context).size.height*11/100, key: ValueKey(2)),
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height*2/100),
                                    ElevatedButton.icon(
                                      onPressed: _authenticate,
                                      icon: Icon(Icons.fingerprint),
                                      label: Text(isCheckedIn ? "Check Out" : "Check In"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isCheckedIn ? Colors.red : Colors.blue,
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        textStyle: TextStyle(fontSize: MediaQuery.of(context).size.width*4/100),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            ],
                          ),
                        )
                    ),

                  ]
              ); // ✅ تحميل الصفحة بعد إحضار البيانات
            }
          },
        ),


    );
  }


  /// ✅ Widget لعرض الساعة الرقمية المتحركة
  Widget _buildClock() {
    return StreamBuilder(
      stream: Stream.periodic(Duration(seconds: 1)), // تحديث كل ثانية
      builder: (context, snapshot) {
        String time = DateFormat('hh:mm:ss a').format(DateTime.now()); // تنسيق الوقت
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Color(0xFF0A2F3D), Color(0xFF1B263B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            time,
            style: GoogleFonts.orbitron(
              textStyle: TextStyle(
                fontSize: MediaQuery.of(context).size.width*9/100,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                shadows: [
                  Shadow(blurRadius: 3, color: Colors.blueGrey, offset: Offset(1, 1)), // ظل خفيف جدًا
                ],

              ),
            ),
          ),
        );
      },
    );
  }
}

class Employee {
  final int workhours;
  final String starttime;
  final String name;
  final int idd;
  final String vip;
  final String flex;
  final int depid;

  Employee({required this.starttime,required this.workhours
    ,required this.name,required this.idd,required this.vip,required this.flex,required this.depid});

  // تحويل من JSON إلى كائن
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      starttime: json['startTime'],
      workhours: json['workHours'],
      name: json['empName'],
      idd: json['empIdd'],
      vip: json['vip'],
      flex: json['flex'],
      depid: json['empDepId'],
    );
  }

  // تحويل من كائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'startTime': starttime,
      'workHours': workhours,
      'empName': name,
      'empIdd': idd,
      'vip': vip,
      'flex': flex,
      'empDepId': depid,
    };
  }
}

class Employee1 {
  final String? startHour;
  final String? endHour;
  final String? alpha;
  final String? today;

  Employee1({required this.startHour,required this.endHour,required this.alpha,required this.today});

  // تحويل من JSON إلى كائن
  factory Employee1.fromJson(Map<String, dynamic> json) {
    return Employee1(
        startHour: json['startHour']?? "00:00:00",
        endHour: json['endHour']?? "00:00:00",
        alpha: json['alpha']?? "",
        today: json['toDay']??""
    );
  }

  // تحويل من كائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'startHour': startHour,
      'endHour': endHour,
      'alpha': alpha,
      'toDay': today,
    };
  }

}



