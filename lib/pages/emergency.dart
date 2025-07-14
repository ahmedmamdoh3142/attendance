import 'dart:convert';
import 'dart:io';

import 'package:attndance2/pages/signin.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class emergency extends StatefulWidget {
  const emergency({super.key});

  @override
  State<emergency> createState() => _homeState();
}

class _homeState extends State<emergency> {

  @override
  void initState() {
    super.initState();

    loadEmployee();
  }
  TextEditingController commentController = TextEditingController();

  int empId = 0;
  String manName = "";

  Future<void> loadEmployee() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empId = prefs.getInt('empId') ?? 0;
      manName = prefs.getString('manName') ?? "";
    });
  }

  Future<void> postEmmergency() async {
    // تجاوز التحقق من SSL أثناء التطوير
    HttpOverrides.global = MyHttpOverrides();
    final http.Client client = http.Client();

    if (commentController.text.isNotEmpty) {

      final response = await client.post(
        Uri.parse("http://41.33.98.4:1738/api/notification"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "empId": empId,
          "notType": "Emmergency",
          "comment": commentController.text,
          "manName": manName,
          "notHours": 0,
        }),
      );
      commentController.text = "";
      showSuccessDialog(context);

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
            "Emergency",
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
                    postEmmergency();
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
            "Emergency Applied Successfully",
            style: TextStyle(fontSize: MediaQuery.of(context).size.width*5/100, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*1/100),
          Text(
            "Your Emergency has been applied successfully",
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



