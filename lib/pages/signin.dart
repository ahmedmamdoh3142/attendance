import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'package:intl/intl.dart';

class signin extends StatefulWidget {
  const signin({Key? key}) : super(key: key);

  @override
  _signinState createState() => _signinState();
}

class _signinState extends State<signin> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String androidId = "";
  final String baseUrl = "http://41.33.98.4:1738/api";
  late var x=0;
  late List<dynamic> jsonData ; // تحويل الاستجابة إلى JSON
  late List<Employee> employees ;

  @override
  void initState() {
    super.initState();
    getAndroidId();
  }

  // ✅ جلب Android ID
  Future<void> getAndroidId() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    setState(() {
      androidId = androidInfo.id; // تخزين Android ID في المتغير
    });

  }

  Future<void> saveEmployee() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('empId', employees[0].empId);
    await prefs.setString('androidId', androidId);
    await prefs.setString('name', employees[0].name);
    await prefs.setInt('vac', employees[0].vac);
    await prefs.setInt('per', employees[0].per);
    await prefs.setInt('hol', employees[0].hol);
    await prefs.setInt('depid', employees[0].depid);
    await prefs.setString('startHour', employees[0].starthour);
    await prefs.setInt('offCount', employees[0].offcount);
    String endTime = addHoursToTime(employees[0].starthour , employees[0].workhours);
    await prefs.setString('endHour', endTime);
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('manName', employees[0].manname);
  }

  String addHoursToTime(String timeString, int hoursToAdd) {
    // 1️⃣ تحويل الـ String إلى DateTime
    DateTime time = DateTime.parse("2000-01-01 $timeString"); // تعيين تاريخ وهمي لأننا نهتم فقط بالوقت

    DateTime newTime = time.add(Duration(hours: hoursToAdd));

    // 3️⃣ تحويله إلى String بصيغة HH:mm:ss
    return "${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}:${newTime.second.toString().padLeft(2, '0')}";
  }

  // دالة لجلب البيانات من API
  Future getId() async {

    final String username = usernameController.text;
    final String password = passwordController.text;

    if (username.isEmpty) {
      // يمكنك أيضًا عرض رسالة باستخدام Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ يجب إدخال ID!"),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      x=1;

    }else if(password.isEmpty){
      // يمكنك أيضًا عرض رسالة باستخدام Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ يجب إدخال كلمة المرور!"),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      x=1;

    }
    else{
      // تجاوز التحقق من SSL أثناء التطوير
      HttpOverrides.global = MyHttpOverrides();
      final http.Client client = http.Client();

      final response = await client.get(
      Uri.parse("http://41.33.98.4:1738/api/loginapp/getId/${username}/${password}"),
      headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        jsonData = jsonDecode(response.body); // تحويل الاستجابة إلى JSON
        employees = jsonData.map((e) => Employee.fromJson(e)).toList();
        if(employees.isNotEmpty)
        {

          if(employees[0].androidId == null)
          {
            x=4;
            final response = await client.put(
              Uri.parse("http://41.33.98.4:1738/api/loginapp/updateAndroidId/${employees[0].empId}"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "newId": androidId,
              }),
            );
            saveEmployee();
          }else{
            x=3;
          }

        }else{
          x=2;
        }

      } else {
      throw Exception("فشل في جلب البيانات: ${response.statusCode}");
      }
    }
  }

  bool pass = true;
  bool rememberbass = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      body: Stack(
        children: [
          Image.asset('images/back1.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30.0 , top: 30.0),
                child: Text("Hello\nSign in!" , style: TextStyle(
                    color: Colors.white , fontSize: MediaQuery.of(context).size.height*4/100
                    , fontWeight: FontWeight.bold),),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*4/80),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*6/100
                      , left: 30.0 , right: 30.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(color: Colors.white ,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(30) , topRight: Radius.circular(30))),
                  child: Column(
                    children: [
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("ID" , style: TextStyle(color: Color(0xFF071C52) ,
                              fontSize: MediaQuery.of(context).size.height*2/80 , fontWeight: FontWeight.bold),
                          ),
                          TextField(
                            controller: usernameController,
                            decoration: InputDecoration(
                                hintText: "Enter your ID",
                                suffixIcon: Icon(Icons.check)
                            ),
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).size.height*2/130,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*4/100),
                          Text("Password" , style: TextStyle(color: Color(0xFF071C52) ,
                              fontSize: MediaQuery.of(context).size.height*2/80 , fontWeight: FontWeight.bold),
                          ),
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              hintText: "Enter your password",
                              suffixIcon: IconButton(
                                icon : pass? const Icon(Icons.visibility) : const Icon(Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    pass = !pass;
                                  });
                                },
                              ),

                            ),
                            obscureText: pass,
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).size.height*2/130,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                          SizedBox(height:MediaQuery.of(context).size.height*6/100),
                          GestureDetector(
                            onTap: ()async{
                              await getId();
                              if(x==4)
                              {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => home()));
                              }else if(x==2){
                                showDialog(  // 🔹 استخدم showDialog لعرض النافذة
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("خطأ", style: TextStyle(color: Colors.red)),
                                      content: Text("رقم مرور خاطئ"),
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
                              }else if(x==3){
                                showDialog(  // 🔹 استخدم showDialog لعرض النافذة
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("خطأ", style: TextStyle(color: Colors.red)),
                                      content: Text("هذا الرقم الوظيفي مسجل دخول بالفعل"),
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
                            },
                            child: Container(
                                padding: EdgeInsets.only(top: 20.0 , bottom: 20.0),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(gradient: LinearGradient(colors: [
                                  Color(0xFF0E41DB)
                                  , Color(0xFF071C52)
                                  , Color(0xFF020715)
                                ], begin: Alignment.topLeft , end: Alignment.topRight),
                                    borderRadius: BorderRadius.circular(30)
                                ),
                                child: Center(
                                  child: Text("SIGN IN" , style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: MediaQuery.of(context).size.height*3/130
                                  ),
                                  ),
                                )
                            ),
                          )
                        ],
                      ),),
                    ],
                  )
                ),
              )

            ],
          ),
        ],
      ),
    );

  }
}
// تجاوز التحقق من الشهادة SSL
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }

}
class Employee {
  final int empId;
  final String? androidId;
  final String name;
  final int vac;
  final int per;
  final int hol;
  final int depid;
  final String starthour;
  final int workhours;
  final String offday;
  final int offcount;
  final String manname;

  Employee({required this.empId, this.androidId , required this.name
    , required this.vac , required this.per , required this.hol,
    required this.depid , required this.starthour, required this.workhours
    , required this.offday, required this.offcount , required this.manname});

  // تحويل من JSON إلى كائن
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      empId: json['empId'],
      name: json['empName'] ?? '',
      androidId: json['androidId']as String?,
      vac: json['vacCount'],
      per: json['per'],
      hol: json['holCount'],
      depid: json['empDepId'],
      starthour: json['startTime'] ?? '',
      workhours: json['workHours'],
      offday: json['offDay'] ?? '',
      offcount: json['offCount'] ?? 0,
      manname: json['managerName'] ?? '',
    );
  }

  // تحويل من كائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'empId': empId,
      'androidId': androidId,
      'empName': name,
      'vacCount': vac,
      'per': per,
      'holCount': hol,
      'empDepId': depid,
      'startTime': starthour,
      'workHours': workhours,
      'offDay': offday,
      'offCount': offcount,
      'managerName': manname,
    };
  }
}

