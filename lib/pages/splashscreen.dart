import 'package:attndance2/pages/onboarding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class splashscreen extends StatefulWidget {
  const splashscreen({Key? key}) : super(key: key);

  @override
  _splashscreenState createState() => _splashscreenState();
}

class _splashscreenState extends State<splashscreen> {

  @override
  void initState(){
    Future.delayed(Duration(seconds: 3) , (){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => onboarding()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset('images/bg1.png',
            fit: BoxFit.cover,
            width: double.infinity,),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("images/building2.png" ,
                color: Colors.white,
                height: 120, width: 120, fit: BoxFit.cover,),
              Text("ARAB DEVELOPERS" , style: TextStyle(color: Colors.white , fontSize:30.0)
              ),
            ],
          ),
        ],
      ),
    );
  }
}
