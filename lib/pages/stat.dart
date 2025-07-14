import 'dart:convert';

import 'package:attndance2/pages/signin.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class stat extends StatefulWidget {
  const stat({super.key});

  @override
  State<stat> createState() => _homeState();
}


class _homeState extends State<stat> {

  @override
  void initState() {
    super.initState();

    getStartDate();
    loadEmployee();
  }

  DateTime startDate = DateTime(2000, 5, 14);
  DateTime endDate = DateTime(2000, 5, 14);

  int empId = 0;

  List<int> d = [];
  List<int> dd = [];
  List<int> x = [];
  List<int> v = [];
  List<int> on = [];

  int dnum = 0;
  int ddnum = 0;
  int xnum = 0;
  int vnum = 0;
  int onnum = 0;

  void getStartDate() {
    DateTime today = DateTime.now();
    int currentDay = today.day;
    int currentMonth = today.month;
    int currentYear = today.year;

    if (currentDay < 20) {
      // إذا كان اليوم قبل 20، نأخذ 20 من الشهر الماضي و 20 من الشهر الحالي
      startDate = DateTime(currentYear, currentMonth - 1, 20);
      endDate = DateTime(currentYear, currentMonth, 20);
    } else {
      // إذا كان اليوم 20 أو أكثر، نأخذ 20 من هذا الشهر و 20 من الشهر القادم
      startDate = DateTime(currentYear, currentMonth, 20);
      endDate = DateTime(currentYear, currentMonth + 1, 20);
    }

  }

  Future<void> loadEmployee() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empId = prefs.getInt('empId') ?? 0;
    });
  }

  Future<void> getstat() async {
    // تجاوز التحقق من SSL أثناء التطوير
    HttpOverrides.global = MyHttpOverrides();
    final http.Client client = http.Client();

    final response = await client.get(
      Uri.parse(
          "http://41.33.98.4:1738/api/attend/getstat/${empId}/${DateFormat('yyyy-MM-dd').format(startDate)}/${DateFormat('yyyy-MM-dd').format(endDate)}/d"),
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode == 200) {
      d = List<int>.from(jsonDecode(response.body)); // تحويل الاستجابة إلى JSON
      if (d.isNotEmpty) {
        dnum = d.length;
      }

      final response1 = await client.get(
        Uri.parse(
            "http://41.33.98.4:1738/api/attend/getstat/${empId}/${DateFormat('yyyy-MM-dd').format(startDate)}/${DateFormat('yyyy-MM-dd').format(endDate)}/dd"),
        headers: {"Content-Type": "application/json"},
      );
      if (response1.statusCode == 200) {
        dd = List<int>.from(jsonDecode(response1.body)); // تحويل الاستجابة إلى JSON
        if (dd.isNotEmpty) {
          ddnum = dd.length;
        }
      }

      final response2 = await client.get(
        Uri.parse(
            "http://41.33.98.4:1738/api/attend/getstat/${empId}/${DateFormat('yyyy-MM-dd').format(startDate)}/${DateFormat('yyyy-MM-dd').format(endDate)}/x"),
        headers: {"Content-Type": "application/json"},
      );
      if (response2.statusCode == 200) {
        x = List<int>.from(jsonDecode(response2.body)); // تحويل الاستجابة إلى JSON
        if (x.isNotEmpty) {
          xnum = x.length;
        }
      }

      final response3 = await client.get(
        Uri.parse(
            "http://41.33.98.4:1738/api/attend/getstat/${empId}/${DateFormat('yyyy-MM-dd').format(startDate)}/${DateFormat('yyyy-MM-dd').format(endDate)}/v"),
        headers: {"Content-Type": "application/json"},
      );
      if (response3.statusCode == 200) {
        v = List<int>.from(jsonDecode(response3.body)); // تحويل الاستجابة إلى JSON
        if (v.isNotEmpty) {
          vnum = v.length;
        }
      }

      final response4 = await client.get(
        Uri.parse(
            "http://41.33.98.4:1738/api/attend/getstat/${empId}/${DateFormat('yyyy-MM-dd').format(startDate)}/${DateFormat('yyyy-MM-dd').format(endDate)}/on"),
        headers: {"Content-Type": "application/json"},
      );
      if (response4.statusCode == 200) {
        on = List<int>.from(jsonDecode(response4.body)); // تحويل الاستجابة إلى JSON
        if (on.isNotEmpty) {
          onnum = on.length;
        }
      }
      } else {
        throw Exception("فشل في جلب البيانات: ${response.statusCode}");
      }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: FutureBuilder<void>(
        future: getstat(), // 1️⃣ استدعاء الدالة مباشرة هنا
    builder: (context, snapshot) {
      if (d.isNotEmpty || dd.isNotEmpty || v.isNotEmpty || on.isNotEmpty || x.isNotEmpty) {
        return Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*5/100),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE9F1F7), Color(0xFFB0D0F3)], // تدرج من الأزرق الداكن إلى الأزرق الفاتح
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                _buildTitle("Monthly evaluation"),
                Padding(
                  padding: const EdgeInsets.only(left: 20 , right: 20 , bottom: 20),
                  child: GridView.count(
                    shrinkWrap: true, // جعل GridView غير متسع داخل العمود
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2, // تصميم 2 عمود
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    children: [
                      _buildReportCard('On Time', onnum, Icons.access_time, Colors.green),
                      _buildReportCard('Late', dnum+ddnum, Icons.watch_later, Colors.orange),
                      _buildReportCard('Absences', xnum, Icons.cancel, Colors.red),
                      _buildReportCard('Vacations', vnum, Icons.beach_access, Colors.blue),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height*1/80,),
                // ✅ التقييم الشهري – تحليل الحضور والتأخير (رسم بياني دائري)

                SizedBox(
                  height: MediaQuery.of(context).size.height*28/100,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: onnum.toDouble(),
                          title: "presence",
                          color: Colors.green,
                          radius: 60,
                        ),
                        PieChartSectionData(
                          value: (dnum + ddnum).toDouble(),
                          title: "Late",
                          color: Colors.orange,
                          radius: 50,
                        ),
                        PieChartSectionData(
                          value: xnum.toDouble(),
                          title: "Absence",
                          color: Colors.red,
                          radius: 40,
                        ),
                        PieChartSectionData(
                          value: vnum.toDouble(),
                          title: "Vacation",
                          color: Colors.blue,
                          radius: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
        );

      } else {
        return Center(child: CircularProgressIndicator()); // ⏳ جاري التحميل
      }
    }
      )
    );
  }

  // 🔹 دالة لإضافة عناوين للأقسام
  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: MediaQuery.of(context).size.height*3/100
          , fontWeight: FontWeight.bold),
    );
  }

  /// ✅ Widget لعرض كل تقرير في كونتينر
  Widget _buildReportCard(String title, int count, IconData icon, Color color) {
    return Card(
      elevation: 8, // تأثير الظل
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // زوايا مستديرة
      ),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.5)], // تدرج اللون
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: MediaQuery.of(context).size.height*5/100,
              color: Colors.white,
            ),
            SizedBox(height: MediaQuery.of(context).size.height*1/100),
            Text(
              title,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height*2/100,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),
            Text(
              '$count Times',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height*2/110,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

