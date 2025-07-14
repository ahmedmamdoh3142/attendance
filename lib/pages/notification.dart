import 'dart:convert';

import 'package:attndance2/pages/signin.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


class notification extends StatefulWidget {
  const notification({super.key});

  @override
  State<notification> createState() => _homeState();
}

class _homeState extends State<notification> {

  int empId = 0 , vac=0 , per=0 , hol=0 , depid=0;
  String manName = "" , startHour="" , endHour="";

  late List<dynamic> jsonData ; // تحويل الاستجابة إلى JSON
  late List<Employee> employeess =[];

  late List<dynamic> jsonData1 ; // تحويل الاستجابة إلى JSON
  late List<Employee> employeess1 =[];

  late List<Employee1> empname =[];
  late List<Employee1> empname1 =[];

  late Future<void> futureData;


  @override
  void initState() {
    super.initState();

    loadEmployee();
    futureData = getData();
  }

  Future<void> loadEmployee() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empId = prefs.getInt('empId') ?? 0;
      manName = prefs.getString('name') ?? "";
      vac = prefs.getInt('vac') ?? 0;
      per = prefs.getInt('per') ?? 0;
      hol = prefs.getInt('hol') ?? 0;
      depid = prefs.getInt('depid') ?? 0;
      startHour = prefs.getString('startHour') ?? "";
      endHour = prefs.getString('endHour') ?? "";
    });
  }

  Future<void> getData() async {
    empname.clear();
    empname1.clear();
    // تجاوز التحقق من SSL أثناء التطوير
    HttpOverrides.global = MyHttpOverrides();
    final http.Client client = http.Client();


    final response = await client.get(
      Uri.parse("http://41.33.98.4:1738/api/notification/data/${empId}"),
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode == 200) {
      jsonData = jsonDecode(response.body); // تحويل الاستجابة إلى JSON
      employeess = jsonData.map((e) => Employee.fromJson(e)).toList();

      if(employeess.isNotEmpty)
        {
          List<Future<Employee1>> requests = employeess.map<Future<Employee1>>((employee) async {

            final response2 = await client.get(
              Uri.parse("http://41.33.98.4:1738/api/notification/empname/${employee.empid}"),
              headers: {"Content-Type": "application/json"},
            );

            if (response2.statusCode == 200) {
              var jsonData = jsonDecode(response2.body);
              return Employee1.fromJson(jsonData[0]); // استخراج الاسم فقط
            } else {
              print("❌ خطأ في جلب بيانات الموظف ${employee.empid}: ${response2.statusCode}");
              throw Exception("فشل في جلب بيانات الموظف");
            }
          }).toList();

          empname = await Future.wait(requests);
        }
    } else {
      throw Exception("فشل في جلب البيانات: ${response.statusCode}");
    }


    final response1 = await client.get(
      Uri.parse("http://41.33.98.4:1738/api/notification/dataMan/${manName}"),
      headers: {"Content-Type": "application/json"},
    );
    if (response1.statusCode == 200) {
      jsonData1 = jsonDecode(response1.body); // تحويل الاستجابة إلى JSON
      employeess1 = jsonData1.map((e) => Employee.fromJson(e)).toList();


      if(employeess1.isNotEmpty)
        {
          List<Future<Employee1>> requests = employeess1.map<Future<Employee1>>((employee) async {

            final response2 = await client.get(
              Uri.parse("http://41.33.98.4:1738/api/notification/empname/${employee.empid}"),
              headers: {"Content-Type": "application/json"},
            );

            if (response2.statusCode == 200) {
              var jsonData = jsonDecode(response2.body);
              return Employee1.fromJson(jsonData[0]); // استخراج الاسم فقط
            } else {
              print("❌ خطأ في جلب بيانات الموظف ${employee.empid}: ${response2.statusCode}");
              throw Exception("فشل في جلب بيانات الموظف");
            }
          }).toList();

          empname1 = await Future.wait(requests);
        }
    } else {
      throw Exception("فشل في جلب البيانات: ${response.statusCode}");
    }
  }

  Future<void> updateData(int index , String status) async {
    // تجاوز التحقق من SSL أثناء التطوير
    HttpOverrides.global = MyHttpOverrides();
    final http.Client client = http.Client();

    final response = await client.put(
      Uri.parse("http://41.33.98.4:1738/api/notification/update/${employeess1[index].notid}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "newStatuss": status,
      }),
    );

    if(status=="Accept")
      {
        if(employeess1[index].nottype=="Holiday")
          {
            DateTime startDate = DateTime.parse(employeess1[index].fdate.toString());
            DateTime endDate = DateTime.parse(employeess1[index].tdate.toString());
            Duration difference = endDate.difference(startDate);
            int daysBetween = difference.inDays;
            int total = empname1[index].hol - daysBetween;

            final response = await client.put(
              Uri.parse("http://41.33.98.4:1738/api/notification/updateHol/${employeess1[index].empid}"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "newHol": total,
              }),
            );

            DateTime startDate1 = DateTime.parse(employeess1[index].fdate.toString());
            DateTime endDate1 = DateTime.parse(employeess1[index].tdate.toString());
            int daysBetween1 = endDate1.difference(startDate1).inDays ;

            for (int i = 0; i < daysBetween1; i++) {

              DateTime currentDate = startDate1.add(Duration(days: i));
              String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

              final response1 = await client.post(
                Uri.parse("http://41.33.98.4:1738/api/attend"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "empId": empname1[index].empId,
                  "depId": empname1[index].depid,
                  "toDay": formattedDate,
                  "alpha": "h",
                }),
              );
            }

          }
        else if(employeess1[index].nottype=="Vacation")
        {
          DateTime startDate = DateTime.parse(employeess1[index].fdate.toString());
          DateTime endDate = DateTime.parse(employeess1[index].tdate.toString());
          Duration difference = endDate.difference(startDate);
          int daysBetween = difference.inDays;
          int total = empname1[index].vac - daysBetween;

          final response = await client.put(
            Uri.parse("http://41.33.98.4:1738/api/notification/updateVac/${employeess1[index].empid}"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "newVac": total,
            }),
          );

          DateTime startDate1 = DateTime.parse(employeess1[index].fdate.toString());
          DateTime endDate1 = DateTime.parse(employeess1[index].tdate.toString());
          int daysBetween1 = endDate1.difference(startDate1).inDays ;

          for (int i = 0; i < daysBetween1; i++) {

            DateTime currentDate = startDate1.add(Duration(days: i));
            String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

            final response1 = await client.post(
              Uri.parse("http://41.33.98.4:1738/api/attend"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "empId": empname1[index].empId,
                "depId": empname1[index].depid,
                "toDay": formattedDate,
                "alpha": "v",
              }),
            );
          }
        }
        else if(employeess1[index].nottype=="offDay")
        {
          DateTime startDate = DateTime.parse(employeess1[index].fdate.toString());
          DateTime endDate = DateTime.parse(employeess1[index].tdate.toString());
          Duration difference = endDate.difference(startDate);
          int daysBetween = difference.inDays;
          int total = empname1[index].off - daysBetween;

          final response = await client.put(
            Uri.parse("http://41.33.98.4:1738/api/notification/updateOff/${employeess1[index].empid}"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "newOff": total,
            }),
          );

          DateTime startDate1 = DateTime.parse(employeess1[index].fdate.toString());
          DateTime endDate1 = DateTime.parse(employeess1[index].tdate.toString());
          int daysBetween1 = endDate1.difference(startDate1).inDays ;

          for (int i = 0; i < daysBetween1; i++) {

            DateTime currentDate = startDate1.add(Duration(days: i));
            String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

            final response1 = await client.post(
              Uri.parse("http://41.33.98.4:1738/api/attend"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "empId": empname1[index].empId,
                "depId": empname1[index].depid,
                "toDay": formattedDate,
                "alpha": "o",
              }),
            );
          }
        }
        else if(employeess1[index].nottype=="Per")
        {
          int total = empname1[index].per - employeess1[index].nothours;

          final response = await client.put(
            Uri.parse("http://41.33.98.4:1738/api/notification/updatePer/${employeess1[index].empid}"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "newPer": total,
            }),
          );

          DateTime time = DateFormat("HH:mm:ss").parse(startHour);
          DateTime time1 = DateFormat("HH:mm:ss").parse(endHour);

          if(employeess1[index].title == "Late")
            {
              DateTime newTime = time.add(Duration(hours: employeess1[index].nothours));
              String formattedTime = DateFormat("HH:mm:ss").format(newTime);

              final response1 = await client.post(
                Uri.parse("http://41.33.98.4:1738/api/attend"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "empId": empname1[index].empId,
                  "depId": empname1[index].depid,
                  "toDay": employeess1[index].fdate,
                  "startHour": formattedTime,
                  "alpha": "p"
                }),
              );
            }else{
              DateTime newTime = time1.subtract(Duration(hours: employeess1[index].nothours));
              String formattedTime = DateFormat("HH:mm:ss").format(newTime);

              final response1 = await client.post(
                Uri.parse("http://41.33.98.4:1738/api/attend"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "empId": empname1[index].empId,
                  "depId": empname1[index].depid,
                  "toDay": employeess1[index].fdate,
                  "startHour": formattedTime,
                  "alpha": "p",
                }),
              );
          }
        }
      }
  }

  final List<Map<String, String>> data = [
    {
      'name': 'Ahmed mamdoh',
      'startDate': '2025-01-01',
      'endDate': '2025-01-31',
      'image': 'images/ahmed.JPG', // ضع مسار الصورة هنا
    },
    {
      'name': 'Mahmoud ahmed',
      'startDate': '2025-02-01',
      'endDate': '2025-02-28',
      'image': 'images/ahmed.JPG', // ضع مسار الصورة هنا
    },
    {
      'name': 'Ahmed mamdoh',
      'startDate': '2025-01-01',
      'endDate': '2025-01-31',
      'image': 'images/ahmed.JPG', // ضع مسار الصورة هنا
    },
    {
      'name': 'Ahmed mamdoh',
      'startDate': '2025-01-01',
      'endDate': '2025-01-31',
      'image': 'images/ahmed.JPG', // ضع مسار الصورة هنا
    },
    {
      'name': 'Ahmed mamdoh',
      'startDate': '2025-01-01',
      'endDate': '2025-01-31',
      'image': 'images/ahmed.JPG', // ضع مسار الصورة هنا
    },
    {
      'name': 'Ahmed mamdoh',
      'startDate': '2025-01-01',
      'endDate': '2025-01-31',
      'image': 'images/ahmed.JPG', // ضع مسار الصورة هنا
    },
    {
      'name': 'Ahmed mamdoh',
      'startDate': '2025-01-01',
      'endDate': '2025-01-31',
      'image': 'images/ahmed.JPG', // ضع مسار الصورة هنا
    },
    {
      'name': 'Ahmed mamdoh',
      'startDate': '2025-01-01',
      'endDate': '2025-01-31',
      'image': 'images/ahmed.JPG', // ضع مسار الصورة هنا
    },
    // يمكنك إضافة المزيد من العناصر هنا
  ];
  @override
  Widget build(BuildContext context) {

    return  Scaffold(
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
          "Notifications",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
    onRefresh: () async {
      await getData();
      setState(() {
        futureData = getData(); // تحديث البيانات عند السحب
      }); // تحديث البيانات عند السحب
    },
    child: FutureBuilder<void>(
        future: getData(), // 1️⃣ استدعاء الدالة مباشرة هنا
    builder: (context, snapshot) {
    if (employeess1.isEmpty && employeess.isEmpty) {
    return Center(child: Text(
      "No notification yet",
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
    ),); // ⏳ جاري التحميل
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE9F1F7), Color(0xFFB0D0F3)],
            // تدرج من الأزرق الداكن إلى الأزرق الفاتح
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          itemCount: employeess1.length + employeess.length,
          itemBuilder: (context, index) {
            if(index < employeess1.length)
              {
                if(employeess1[index].nottype == "Vacation" || employeess1[index].nottype == "offDay")
                  {
                    return _buildNotificationCard(empname1[index].name ,employeess1[index].fdate.toString() ,
                        employeess1[index].tdate.toString(), employeess1[index].nottype,
                        employeess1[index].nothours.toString() , Color(0xFFE3F2FD) , index);
                  }
                else if(employeess1[index].nottype == "Holiday")
                  {
                    return _buildNotificationCard(empname1[index].name ,employeess1[index].fdate.toString() ,
                        employeess1[index].tdate.toString(), employeess1[index].nottype,
                        employeess1[index].nothours.toString() , Color(0xFFE8F5E9) , index );
                  }
                else if(employeess1[index].nottype == "Per")
                {
                  return _buildNotificationCard(empname1[index].name ,employeess1[index].fdate.toString() ,
                      employeess1[index].tdate.toString(), employeess1[index].nottype,
                      employeess1[index].nothours.toString() , Color(0xFFFFF3E0) , index );
                }
                else
                  {
                    return _buildNotificationCard(empname1[index].name ,employeess1[index].fdate.toString() ,
                        employeess1[index].tdate.toString(), employeess1[index].nottype,
                        employeess1[index].nothours.toString() , Color(0xFFFFEBEE) , index );
                  }

              }
            else{

              if(employeess[index].statuss == "Accept")
                {
                  return _buildNotificationCardyes(Color(0xFFE8F5E9) , Colors.green ,
                      employeess[index].fdate.toString() ,
                      employeess[index].tdate.toString(), employeess[index].nottype);
                }
              else{
                return _buildNotificationCardno(Color(0xFFFFEBEE) , Colors.red ,
                    employeess[index].fdate.toString() ,
                    employeess[index].tdate.toString(), employeess[index].nottype);
              }
            }

          },
        ),
      );
    }
        }))
    );
  }

  Widget _buildNotificationCard(String name, String fdate , String edate , String title, String hours , Color colorr , int index) {
    return GestureDetector(
      onTap: (){
        showCustomDialog(context ,empname1[index].name , employeess1[index].nottype ,
            employeess1[index].fdate.toString() , employeess1[index].tdate.toString() ,
            employeess1[index].comment.toString() , employeess1[index].nothours.toString(),
            employeess1[index].statuss.toString());
      },
      child: Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: colorr,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () async{
                  await updateData(index , "Accept");
                  await getData();
                  setState(() {
                    futureData = getData(); // تحديث البيانات عند السحب
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(10),
                ),
                child: Icon(Icons.check, color: Colors.white, size: 35),
              ),
              Expanded(child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width*4/100,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width*4/120,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        ' ${fdate} - ${edate}',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width*3/100,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              )),
              ElevatedButton(
                onPressed: () async{
                  await updateData(index , "Reject");
                  await getData();
                  setState(() {
                    futureData = getData(); // تحديث البيانات عند السحب
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(10),
                ),
                child: Icon(Icons.close_rounded, color: Colors.white , size: 35,),
              ),
            ],
          )
      ),
    );
  }

  Widget _buildNotificationCardyes(Color colorr , Color color1 ,String fdate , String edate , String title ) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: colorr,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: color1,
                shape: CircleBorder(),
                padding: EdgeInsets.all(10),
              ),
              child: Icon(Icons.check, color: Colors.white, size: 35),
            ),
            Expanded(child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width*4/120,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      ' ${fdate} - ${edate}',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width*3/100,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            )),
          ],
        )
    );
  }

  Widget _buildNotificationCardno(Color colorr , Color color1 ,String fdate , String edate , String title ) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: colorr,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: color1,
                shape: CircleBorder(),
                padding: EdgeInsets.all(10),
              ),
              child: Icon(Icons.close_rounded, color: Colors.white, size: 35),
            ),
            Expanded(child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width*4/120,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      ' ${fdate} - ${edate}',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width*3/100,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            )),
          ],
        )
    );
  }

  void showCustomDialog(BuildContext context ,String name, String type , String from , String to ,
      String comment , String hours , String status) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text("Details", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextRow("Name", name),
              buildTextRow("Type", type),
              buildTextRow("From", from),
              buildTextRow("To", to),
              buildTextRow("Comment", comment),
              buildTextRow("Hours", hours),
              buildTextRow("Status", status),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget buildTextRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }
}

class Employee {
  final int notid;
  final int empid;
  final String nottype;
  final String? fdate;
  final String? tdate;
  final String comment;
  final int nothours;
  final String? title;
  final String manname;
  final String? statuss;

  Employee({required this.notid,required this.empid,required this.nottype
    , this.fdate, this.tdate,required this.comment,
    required this.nothours, this.title,required this.manname, this.statuss});

  @override
  String toString() {
    return '''
    Employee(
    notId: $notid,
      empId: $empid, 
      notType: $nottype, 
      fDate: $fdate, 
      tDate: $tdate, 
      comment: $comment, 
      notHours: $nothours, 
      title: $title, 
      manName: $manname, 
      statuss: $statuss
    )
    ''';
  }

  // تحويل من JSON إلى كائن
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      notid: json['notId']as int,
      empid: json['empId']as int,
      nottype: json['notType']as String,
      fdate: json['fDate']??"",
      tdate: json['tDate']??"",
      comment: json['comment']as String,
      nothours: json['notHours']??"",
      title: json['title']??"",
      manname: json['manName']as String,
      statuss: json['statuss']??"",
    );
  }

  // تحويل من كائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'notId': notid,
      'empId': empid,
      'notType': nottype,
      'fDate': fdate,
      'tDate': tdate,
      'comment': comment,
      'notHours': nothours,
      'title': title,
      'manName': manname,
      'statuss': statuss,
    };
  }
}

class Employee1 {
  final int empId;
  final String? androidId;
  final String name;
  final int vac;
  final int per;
  final int hol;
  final int depid;
  final String starthour;
  final int workhours;
  final int off;

  Employee1({required this.empId, this.androidId , required this.name
    , required this.vac , required this.per , required this.hol,
    required this.depid , required this.starthour, required this.workhours, required this.off});

  // تحويل من JSON إلى كائن
  factory Employee1.fromJson(Map<String, dynamic> json) {
    return Employee1(
      empId: json['empId'],
      name: json['empName'],
      androidId: json['androidId']as String?,
      vac: json['vacCount'],
      per: json['per'],
      hol: json['holCount'],
      depid: json['empDepId'],
      starthour: json['startTime'],
      workhours: json['workHours'],
      off: json['offCount'] ?? 0,
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
      'offCount': off,
    };
  }
}



