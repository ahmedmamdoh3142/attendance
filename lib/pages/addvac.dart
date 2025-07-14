import 'dart:convert';

import 'package:attndance2/pages/signin.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class addvac extends StatefulWidget {
  const addvac({super.key});

  @override
  State<addvac> createState() => _homeState();
}

class _homeState extends State<addvac> {

  @override
  void initState() {
    super.initState();

    loadEmployee();
  }

  TextEditingController fromController = TextEditingController();
  TextEditingController toController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  int empId = 0, vac=0 , hol=0 , per=0;
  String manName = "";
  late List<Employee> employees ;
  late List<dynamic> jsonData ;

  // دالة لاختيار التاريخ
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000); // أول تاريخ ممكن
    DateTime lastDate = DateTime(2101); // آخر تاريخ ممكن

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != initialDate) {
      setState(() {
        if (isStartDate) {
          fromController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          toController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  Future<void> loadEmployee() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empId = prefs.getInt('empId') ?? 0;
      manName = prefs.getString('manName') ?? "";
      vac = prefs.getInt('vac') ?? 0;
      hol = prefs.getInt('hol') ?? 0;
      per = prefs.getInt('per') ?? 0;
    });
  }

  Future<void> getVacCount() async {
    // تجاوز التحقق من SSL أثناء التطوير
    HttpOverrides.global = MyHttpOverrides();
    final http.Client client = http.Client();



    if (fromController.text.isNotEmpty &&
        toController.text.isNotEmpty) {

      DateTime startDate = DateTime.parse(fromController.text.trim());
      DateTime endDate = DateTime.parse(toController.text.trim());
      Duration difference = endDate.difference(startDate);
      int daysBetween = difference.inDays;

      final response = await client.get(
        Uri.parse("http://41.33.98.4:1738/api/emp/getdata/${empId}"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        jsonData = jsonDecode(response.body); // تحويل الاستجابة إلى JSON
        employees = jsonData.map((e) => Employee.fromJson(e)).toList();
      }

      print("a7777777777777777777777777777777a");
      print(manName);

      if(employees[0].vac >= daysBetween)
      {
        final response = await client.post(
          Uri.parse("http://41.33.98.4:1738/api/notification"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "empId": empId,
            "notType": "Vacation",
            "comment": commentController.text,
            "notHours": 0,
            "fDate": fromController.text,
            "tDate": toController.text,
            "manName": manName,
          }),
        );
        fromController.text = "";
        toController.text = "";
        commentController.text = "";
        showSuccessDialog(context);
      }else{
        fromController.text = "";
        toController.text = "";
        commentController.text = "";
        showDialog(  // 🔹 استخدم showDialog لعرض النافذة
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("خطأ", style: TextStyle(color: Colors.red)),
              content: Text("رصيد اجازاتك لا يسمح"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // إغلاق النافذة المنبثقة
                  },
                  child: Text("حسناً"),
                ),
              ],
            );
          },
        );
      }

    } else {
      // عرض رسالة إذا كانت الحقول فارغة
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('يجب ملئ جميع الحقول')));
    }


  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Color(0xFF0E41DB),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "Vacation",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE9F1F7), Color(0xFFB0D0F3)],
              // تدرج من الأزرق الداكن إلى الأزرق الفاتح
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text("From", style: TextStyle(color: Color(0xFF071C52),
                    fontSize: MediaQuery
                        .of(context)
                        .size
                        .height * 2 / 80, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: fromController,
                  decoration: InputDecoration(
                      hintText: "Enter your start date",
                      suffixIcon: GestureDetector(
                        onTap: () {
                          _selectDate(context, true);
                        },
                        child: Icon(Icons.calendar_month),
                      )
                  ),
                  style: TextStyle(
                      fontSize: MediaQuery
                          .of(context)
                          .size
                          .height * 2 / 130,
                      fontWeight: FontWeight.w500
                  ),
                ),

                SizedBox(height: MediaQuery
                    .of(context)
                    .size
                    .height * 4 / 100),

                Text("To", style: TextStyle(color: Color(0xFF071C52),
                    fontSize: MediaQuery
                        .of(context)
                        .size
                        .height * 2 / 80, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: toController,
                  decoration: InputDecoration(
                      hintText: "Enter your end date",
                      suffixIcon: GestureDetector(
                        onTap: () {
                          _selectDate(context, false);
                        },
                        child: Icon(Icons.calendar_month),
                      )
                  ),
                  style: TextStyle(
                      fontSize: MediaQuery
                          .of(context)
                          .size
                          .height * 2 / 130,
                      fontWeight: FontWeight.w500
                  ),
                ),
                SizedBox(height: MediaQuery
                    .of(context)
                    .size
                    .height * 4 / 100),
                Text("Comment", style: TextStyle(color: Color(0xFF071C52),
                    fontSize: MediaQuery
                        .of(context)
                        .size
                        .height * 2 / 80, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: "Enter your comment",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  style: TextStyle(
                      fontSize: MediaQuery
                          .of(context)
                          .size
                          .height * 2 / 130,
                      fontWeight: FontWeight.w500
                  ),

                  maxLines: 5,
                ),
                SizedBox(height: MediaQuery
                    .of(context)
                    .size
                    .height * 4 / 100),
                GestureDetector(
                  onTap: () {
                    getVacCount();
                  },
                  child: Container(
                      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Color(0xFF0E41DB)
                            , Color(0xFF071C52)
                            , Color(0xFF020715)
                          ], begin: Alignment.topLeft, end: Alignment.topRight),
                          borderRadius: BorderRadius.circular(30)
                      ),
                      child: Center(
                        child: Text("Submit", style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery
                                .of(context)
                                .size
                                .height * 3 / 130
                        ),
                        ),
                      )
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}


  // 📌 دالة مستقلة يمكن استدعاؤها بسهولة في أي مكان
  void showSuccessDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildSuccessDialog(context);
      },
    );
  }

// 📌 تصميم نافذة النجاح مع أنيميشن الانزلاق
  Widget _buildSuccessDialog(BuildContext context) {
    return SlideTransitionExample(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Color(0xFF0E41DB), size: MediaQuery.of(context).size.width*19/100),
            SizedBox(height: MediaQuery.of(context).size.height*1/100),
            Text(
              "Vacation Applied Successfully",
              style: TextStyle(fontSize: MediaQuery.of(context).size.width*5/100, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*1/100),
            Text(
              "Your vacation has been applied successfully",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: MediaQuery.of(context).size.width*4/100, color: Colors.grey),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*2/100),
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height*5/100,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0E41DB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // إغلاق النافذة
                },
                child: Text("Done", style: TextStyle(fontSize: MediaQuery.of(context).size.width*4/100, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

// 📌 ويدجت خاصة لعمل الأنيميشن
  class SlideTransitionExample extends StatefulWidget {
  final Widget child;
  SlideTransitionExample({required this.child});

  @override
  _SlideTransitionExampleState createState() => _SlideTransitionExampleState();
  }

  class _SlideTransitionExampleState extends State<SlideTransitionExample>
  with SingleTickerProviderStateMixin {
    late AnimationController _controller;
    late Animation<Offset> _animation;

    @override
    void initState() {
      super.initState();
      _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
      );

      _animation = Tween<Offset>(
        begin: Offset(0, 1),
        end: Offset(0, 0),
      ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));

      _controller.forward(); // تشغيل الأنيميشن عند الفتح
    }

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return SlideTransition(
        position: _animation,
        child: widget.child,
      );
    }
  }

class Employee {
  final int vac;
  final int per;
  final int hol;
  final int offcount;

  Employee({ required this.vac , required this.per , required this.hol, required this.offcount});

  // تحويل من JSON إلى كائن
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      vac: json['vacCount'],
      per: json['per'],
      hol: json['holCount'],
      offcount: json['offCount'] ?? 0,
    );
  }

  // تحويل من كائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'vacCount': vac,
      'per': per,
      'holCount': hol,
      'offCount': offcount,
    };
  }
}



