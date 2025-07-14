import 'package:attndance2/pages/activity.dart';
import 'package:attndance2/pages/homebody.dart';
import 'package:attndance2/pages/profile.dart';
import 'package:attndance2/pages/stat.dart';
import 'package:attndance2/pages/vacation.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {

  late List<Widget> pages; // ❌ لا نحدد قيمتها هنا

  @override
  void initState() {
    super.initState();
    pages = [
      homebody(), // ✅ الآن `widget` متاح
      vacation(),
      stat(),
      activity(),
      profile(),
    ];
  }

  final items = <Widget>[
    Icon(Icons.home, size: 35, color: Colors.white,),
    Icon(Icons.calendar_month, size: 35, color: Colors.white,),
    Icon(Icons.bar_chart, size: 35, color: Colors.white,),
    Icon(Icons.watch_later, size: 35, color: Colors.white,),
    Icon(Icons.person, size: 35, color: Colors.white,),
  ];

  int indexx = 0;

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: pages[indexx],
        ),
        bottomNavigationBar: CurvedNavigationBar(
          items: items,
          index: indexx,
          height: MediaQuery.of(context).size.height*8/100,
          backgroundColor: Color(0xFFB0D0F3),
          color: Color(0xFF0E41DB),
          buttonBackgroundColor: Color(0xFF071C52),
          animationDuration: Duration(milliseconds: 300),
          onTap: (index) {
            setState(() {
              indexx = index;
            });
          },
        ),
      );
    }
  }


