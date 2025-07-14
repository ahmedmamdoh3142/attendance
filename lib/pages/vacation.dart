import 'package:attndance2/pages/adddelay.dart';
import 'package:attndance2/pages/addholi.dart';
import 'package:attndance2/pages/addvac.dart';
import 'package:attndance2/pages/emergency.dart';
import 'package:flutter/material.dart';

import 'addoff.dart';

class vacation extends StatefulWidget {
  const vacation({super.key});

  @override
  State<vacation> createState() => _homeState();
}
final List<Widget> pages =[
  addvac(),
  addholi(),
  adddelay(),
  emergency(),
  addoff()
];

class _homeState extends State<vacation> {
  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE9F1F7), Color(0xFFB0D0F3)], // تدرج من الأزرق الداكن إلى الأزرق الفاتح
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // محاذاة العناصر في منتصف الصفحة
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.count(
                shrinkWrap: true, // جعل GridView غير متسع داخل العمود
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2, // تصميم 2 عمود
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildReportCard('Vacation', Icons.beach_access, Colors.blue , 0),
                  _buildReportCard('Holiday', Icons.holiday_village, Colors.green , 1),
                  _buildReportCard('Permission', Icons.timer, Colors.orange , 2),
                  _buildReportCard('Emergency', Icons.emergency_outlined, Colors.red , 3),
                  _buildReportCard('Off', Icons.calendar_today_sharp, Colors.brown , 4),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }


  /// ✅ Widget لعرض كل تقرير في كونتينر
  Widget _buildReportCard(String title, IconData icon, Color color , int num) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => pages[num]));
      },
      child: Card(
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
            ],
          ),
        ),
      ),
    );
  }
}

