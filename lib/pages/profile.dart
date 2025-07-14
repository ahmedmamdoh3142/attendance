import 'dart:convert';

import 'package:attndance2/pages/signin.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _homeState();
}

class _homeState extends State<profile> {

  File? image;
  @override
  void initState() {
    super.initState();
    _loadImage(); // تحميل الصورة عند بدء التطبيق
    loadEmployee();

  }

  int empId = 0 , remain =0;
  late List<dynamic> jsonData ; // تحويل الاستجابة إلى JSON
  late List<Employee> employeess =[];

  // ✅ اختيار الصورة من المعرض
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await _saveImage(imageFile); // حفظ الصورة فورًا

      setState(() {
        image = imageFile; // تحديث الصورة فورًا بعد الاختيار
      });
    }
  }

  // ✅ حفظ الصورة في التخزين المحلي
  Future<void> _saveImage(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/avatar.png';

    await imageFile.copy(path); // حفظ الصورة في التخزين المحلي

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_image', path); // حفظ المسار في SharedPreferences
  }

  // ✅ تحميل الصورة من التخزين المحلي
  Future<void> _loadImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('saved_image');

    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        image = File(imagePath); // تحميل الصورة المحفوظة وتحديث الواجهة
      });
    }
  }

  Future<void> loadEmployee() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empId = prefs.getInt('empId') ?? 0;
    });
  }

  Future<void> getProfile() async {
    // تجاوز التحقق من SSL أثناء التطوير
    HttpOverrides.global = MyHttpOverrides();
    final http.Client client = http.Client();

    final response = await client.get(
      Uri.parse("http://41.33.98.4:1738/api/emp/profile/${empId}"),
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode == 200) {
      jsonData = jsonDecode(response.body); // تحويل الاستجابة إلى JSON
      employeess = jsonData.map((e) => Employee.fromJson(e)).toList();
    } else {
      throw Exception("فشل في جلب البيانات: ${response.statusCode}");
    }
  }


  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      Icon(Icons.home , size: 30, color: Colors.white,),
      Icon(Icons.watch_later , size: 30, color: Colors.white,),
      Icon(Icons.calendar_month , size: 30, color: Colors.white,),
      Icon(Icons.person , size: 30, color: Colors.white,),
    ];
    int index = 3;

    return  Scaffold(
      body: FutureBuilder<void>(
        future: getProfile(), // 1️⃣ استدعاء الدالة مباشرة هنا
        builder: (context, snapshot) {
        if (employeess.isEmpty) {
        return Center(child: CircularProgressIndicator()); // ⏳ جاري التحميل
        } else {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE9F1F7), Color(0xFFB0D0F3)], // تدرج من الأزرق الداكن إلى الأزرق الفاتح
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 15,
                            top: 50
                        ),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: MediaQuery.of(context).size.height*10/100,
                              backgroundImage: image != null ? FileImage(image!) : null,
                              backgroundColor: Colors.grey[300],

                            ),
                            Positioned(
                                bottom: 10,
                                right: 10,
                                child: GestureDetector(
                                    onTap: pickImage,
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: MediaQuery.of(context).size.width*5/100,
                                        color: Colors.blue,
                                      ),
                                    )
                                )
                            )
                          ],
                        )
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width*5/100,),
                    Expanded(
                        child: Container(
                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*6/100),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.person ,
                                      size: MediaQuery.of(context).size.height*3/100),
                                  SizedBox(width: 10,),
                                  Text(
                                      employeess[0].name,
                                      style: TextStyle(
                                          color: Colors.black ,
                                          fontSize: MediaQuery.of(context).size.height*2/100,
                                          fontWeight: FontWeight.w500
                                      )
                                  )
                                ],
                              ),
                              SizedBox(height:MediaQuery.of(context).size.height*2/100 ,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.phone ,
                                      size: MediaQuery.of(context).size.height*3/100),
                                  SizedBox(width: 10,),
                                  Text(
                                      employeess[0].phone,
                                      style: TextStyle(
                                          color: Colors.black ,
                                          fontSize: MediaQuery.of(context).size.height*2/100,
                                          fontWeight: FontWeight.w500
                                      )
                                  )
                                ],
                              ),
                              SizedBox(height:MediaQuery.of(context).size.height*2/100 ,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.security ,
                                      size: MediaQuery.of(context).size.height*3/100),
                                  SizedBox(width: 10,),
                                  Text(
                                      employeess[0].idd.toString(),
                                      style: TextStyle(
                                          color: Colors.black ,
                                          fontSize: MediaQuery.of(context).size.height*2/100,
                                          fontWeight: FontWeight.w500
                                      )
                                  )
                                ],
                              ),
                            ],
                          ),
                        )
                    )

                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 2 / 100),
                Expanded(
                    child: Container(
                      padding: EdgeInsets.only(
                          top: 15 ,
                          left: MediaQuery.of(context).size.width*5/100 ,
                          right: MediaQuery.of(context).size.width*5/100,
                          bottom: 10.0),
                      width: MediaQuery.of(context).size.width,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            GridView.builder(
                              shrinkWrap: true, // هذا يتيح لـ GridView أخذ الحجم الذي يقدمه لها الـ Column
                              physics: NeverScrollableScrollPhysics(),
                              // تحديد عدد الأعمدة
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // عدد الأعمدة (2 في هذه الحالة)
                                crossAxisSpacing: 16, // المسافة بين الأعمدة
                                mainAxisSpacing: 16, // المسافة بين الصفوف
                                childAspectRatio: 1.0, // لتحديد نسبة العرض إلى الارتفاع لكل عنصر
                              ),
                              itemCount: 4, // عدد العناصر (4 كونتينرات)
                              itemBuilder: (context, index) {
                                // تعيين بيانات كل كونتينر
                                switch (index) {
                                  case 0:
                                    return _buildStatContainer(
                                      title: "Remaining days of offdays",
                                      value: employeess[0].off.toString(),
                                      value1: "days",
                                      icon: Icons.calendar_today_sharp,
                                      color: Colors.blue,
                                    );
                                  case 1:
                                    return _buildStatContainer(
                                      title: "Remaining days of vacation",
                                      value: employeess[0].vac.toString(),
                                      value1: "days",
                                      icon: Icons.beach_access,
                                      color: Colors.green,
                                    );
                                  case 2:
                                    return _buildStatContainer(
                                      title: "Remaining days of holidays",
                                      value: employeess[0].hol.toString(),
                                      value1: "days",
                                      icon: Icons.holiday_village,
                                      color: Colors.orange,
                                    );
                                  case 3:
                                    return _buildStatContainer(
                                      title: "Remaining hours of permissions",
                                      value: employeess[0].per.toString(),
                                      value1: "hours",
                                      icon: Icons.timer,
                                      color: Colors.red,
                                    );
                                  default:
                                    return Container(); // في حال كان هناك خطأ
                                }
                              },
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*2/80),

                          ],
                        ),
                      ),

                    )
                ),

              ],
            ),
          );
        }
      }
      )

    );
  }
  // 🔹 دالة لإنشاء كونتينر بتصميم أنيق
  Widget _buildStatContainer({
    required String title,
    required String value,
    required String value1,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.5)], // تدرج اللون
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: MediaQuery.of(context).size.width*10/100),
          SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width*3/100,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value + " " + value1,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width*5/100,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class Employee {
  final String name;
  final String phone;
  final int idd;
  final int vac;
  final int hol;
  final int per;
  final int off;

  Employee({required this.name,required this.phone,required this.idd,required this.vac
    ,required this.hol,required this.per,required this.off});

  // تحويل من JSON إلى كائن
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      name: json['empName'],
      phone: json['empPhone'],
      idd: json['empIdd'],
      vac: json['vacCount'],
      hol: json['holCount'],
      per: json['per'],
      off: json['offCount'],
    );
  }

  // تحويل من كائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'empName': name,
      'empPhone': phone,
      'empIdd': idd,
      'vacCount': vac,
      'holCount': hol,
      'per': per,
      'offCount': off,
    };
  }
}

