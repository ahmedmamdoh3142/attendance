import 'package:attndance2/pages/signin.dart';
import 'package:flutter/material.dart';

class onboarding extends StatefulWidget {
  const onboarding({Key? key}) : super(key: key);

  @override
  _onboardingState createState() => _onboardingState();
}

class _onboardingState extends State<onboarding> {
  late Future<List<dynamic>> _users;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          Image.asset('images/back1.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
            height: double.infinity,),
          Column(
            children: [
              Expanded(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Image.asset("images/logo1.png" ,
                    //color: Colors.white,
                    //height: MediaQuery.of(context).size.height*13/100,
                    //width: MediaQuery.of(context).size.height*13/100, fit: BoxFit.cover,),
                  //SizedBox(height: MediaQuery.of(context).size.height*6/100),
                  //Text("Welcome" , style: TextStyle(color: Colors.white
                      //, fontSize:MediaQuery.of(context).size.height*4/100
                      //, fontWeight: FontWeight.bold) ),
                  //SizedBox(height: MediaQuery.of(context).size.height*4/100),

                ],
              ),),
              Row(
                children: [
                  Expanded(child: GestureDetector(
                    onTap:(){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => signin()));
                    } ,
                    child: Container(
                      padding: EdgeInsets.only(top: 20.0 , bottom: 20.0),
                      decoration: BoxDecoration(color: Colors.transparent
                          , borderRadius: BorderRadius.only(topLeft: Radius.circular(50) , topRight: Radius.circular(50))
                      ),
                      child: Center(
                        child:  Text("SIGN IN" , style: TextStyle(color: Colors.black ,
                            fontSize:MediaQuery.of(context).size.height*3/110 , fontWeight: FontWeight.bold) ),
                      ),
                    ),
                  ),),
                ],
              ),
            ],
          )
        ]
      ),
    );
  }
}
