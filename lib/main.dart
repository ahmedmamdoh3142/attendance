
import 'package:attndance2/pages/home.dart';
import 'package:attndance2/pages/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  bool isLoggedIn = await checkLoginState();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

Future<bool> checkLoginState() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
}


class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  MyApp({super.key,required this.isLoggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,

      home: isLoggedIn ? home() : onboarding(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void _incrementCounter() {
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
