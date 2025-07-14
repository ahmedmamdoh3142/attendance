import 'dart:convert';
import 'dart:io';

import 'package:attndance2/pages/signin.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class activity extends StatefulWidget {
  const activity({super.key});

  @override
  State<activity> createState() => _homeState();
}

class _homeState extends State<activity> {
  int empId = 0 ;
  late List<dynamic> jsonData ; // تحويل الاستجابة إلى JSON
  late List<Employee> employeess =[];

  @override
  void initState() {
    super.initState();

    loadEmployee();
  }

  Future<void> loadEmployee() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empId = prefs.getInt('empId') ?? 0;
    });
  }

  Future<void> getActivity() async {
    // تجاوز التحقق من SSL أثناء التطوير
    HttpOverrides.global = MyHttpOverrides();
    final http.Client client = http.Client();

    final response = await client.get(
      Uri.parse("http://41.33.98.4:1738/api/attend/activity/${empId}"),
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode == 200) {
      jsonData = jsonDecode(response.body);
      employeess = jsonData.map((e) => Employee.fromJson(e)).toList();
      print(employeess[0]);
    } else {
      throw Exception("فشل في جلب البيانات: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {

    DateTime today = DateTime.now();
    DateTime startDate;
    DateTime endDate;

// إذا كان اليوم هو 21 أو بعده، يبدأ الفترة من 21 من الشهر الحالي إلى نهاية الشهر
    if (today.day >= 21) {
      startDate = DateTime(today.year, today.month, 21); // بداية من 21 من الشهر الحالي
      // نهاية الشهر تكون في آخر يوم في الشهر
      endDate = DateTime(today.year, today.month + 1, 20); // 0 تعني آخر يوم في الشهر الحالي
    } else {
      // إذا كان اليوم قبل 21، تبدأ الفترة من 20 من الشهر الماضي إلى 20 من الشهر الحالي
      if (today.month == 1) {
        // إذا كان الشهر الحالي هو يناير، نذهب إلى ديسمبر من العام السابق
        startDate = DateTime(today.year - 1, 12, 20); // 20 من ديسمبر في السنة الماضية
      } else {
        startDate = DateTime(today.year, today.month - 1, 20);
      }
      endDate = DateTime(today.year, today.month, 20); // 20 من الشهر الحالي
    }

    // توليد قائمة من التواريخ بين البداية والنهاية
    List<DateTime> dateList = [];
    for (DateTime date = startDate;
    date.isBefore(endDate.add(Duration(days: 1))); // لضمان إدراج يوم 20
    date = date.add(Duration(days: 1))) {
      dateList.add(date);
    }

    return  Scaffold(
      body:FutureBuilder<void>(
        future: getActivity(), // 1️⃣ استدعاء الدالة مباشرة هنا
        builder: (context, snapshot) {
        if (employeess.isEmpty) {
        return Center(child: CircularProgressIndicator()); // ⏳ جاري التحميل
        } else {
          return Container(
            padding: EdgeInsets.only(
                left: 10 ,
                right: 10,
                top: MediaQuery.of(context).size.height*4/100
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE9F1F7), Color(0xFFB0D0F3)], // تدرج من الأزرق الداكن إلى الأزرق الفاتح
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                    "Your Activity",
                    style: TextStyle(
                        color: Colors.black ,
                        fontSize: MediaQuery.of(context).size.height*3/100,
                        fontWeight: FontWeight.bold
                    )
                ),
                Expanded( // ✅ حل المشكلة باستخدام Expanded
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: ListView.builder(
                      scrollDirection: Axis.vertical, // 👈 اتجاه عمودي
                      itemCount: dateList.length,
                      itemBuilder: (context, index) {
                        DateTime date = dateList[index];
                        bool isToday = date.day == today.day && date.month == today.month && date.year == today.year;

                        // 🔹 ابحث عن العنصر المطابق للتاريخ في employeess
                        var matchedEmployee = employeess.firstWhere(
                              (emp) => DateFormat('d MMM yyyy').format(DateTime.parse(emp.today)) == DateFormat('d MMM yyyy').format(date),
                          orElse: () => Employee(startHour: "00:00:00", endHour: "00:00:00", alpha: "" , today: ""),
                        );

                        // 🔹 لو وجدنا العنصر نأخذ بياناته، وإلا نضع القيم الافتراضية
                        String start = matchedEmployee.startHour.toString();
                        String end = matchedEmployee.endHour.toString();
                        String alpha = matchedEmployee.alpha.toString();
                        if(alpha=="d" || alpha=="dd")
                          {
                            alpha = "Late";
                          }
                        else if(alpha=="v" || alpha=="h")
                          {
                            alpha = "Vacation";
                          }
                        else if(alpha=="on")
                        {
                          alpha = "On Time";
                        }
                        else if(alpha=="x")
                        {
                          alpha = "Absence";
                        }

                        return Container(
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: isToday ? Colors.blue : Colors.white, // لون مختلف لليوم الحالي
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 5,
                                spreadRadius: 2,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Check In",
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width*4/100,
                                      fontWeight: FontWeight.bold,
                                      color: isToday ? Colors.white : Colors.green,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Check Out",
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width*4/100,
                                      fontWeight: FontWeight.bold,
                                      color: isToday ? Colors.white : Colors.red,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    DateFormat('d MMM yyyy').format(date), // اسم اليوم كامل
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width*3/100,
                                      fontWeight: FontWeight.w500,
                                      color: isToday ? Colors.white : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    start,
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width*4/100,
                                      fontWeight: FontWeight.bold,
                                      color: isToday ? Colors.white : Colors.green,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  SizedBox(height: 5),
                                  Text(
                                    end,
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width*4/100,
                                      fontWeight: FontWeight.bold,
                                      color: isToday ? Colors.white : Colors.red,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    alpha,
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width*3/100,
                                      fontWeight: FontWeight.w500,
                                      color: isToday ? Colors.white : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          );
        }
    }
      )

    );
  }

}

class Employee {
  final String? startHour;
  final String? endHour;
  final String alpha;
  final String today;

  Employee({required this.startHour,required this.endHour,required this.alpha,required this.today});

  // تحويل من JSON إلى كائن
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
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

