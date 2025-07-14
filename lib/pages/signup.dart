import 'package:attndance2/pages/signin.dart';
import 'package:flutter/material.dart';

class signup extends StatefulWidget {
  const signup({Key? key}) : super(key: key);

  @override
  _signupState createState() => _signupState();
}
bool pass = true;


class _signupState extends State<signup> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      body: Stack(
        children: [
          Image.asset('images/bg1.png',
            fit: BoxFit.cover,
            width: double.infinity,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30.0 , top: 30.0),
                child: Text("Create Your\n Account" , style: TextStyle(
                    color: Colors.white , fontSize: MediaQuery.of(context).size.height*4/100
                    , fontWeight: FontWeight.bold),),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*4/80),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*6/100
                      , left: 30.0 , right: 30.0),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(color: Colors.white ,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(30) , topRight: Radius.circular(30))),
                  child: Column(
                    children: [
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Name" , style: TextStyle(color: Color(0xFF071C52) ,
                              fontSize: MediaQuery.of(context).size.height*2/80 , fontWeight: FontWeight.bold),
                          ),
                          TextField(
                            decoration: InputDecoration(
                                hintText: "Enter your name",
                                suffixIcon: Icon(Icons.check)
                            ),
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).size.height*2/130,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*3/100),
                          Text("ID" , style: TextStyle(color: Color(0xFF071C52) ,
                              fontSize: MediaQuery.of(context).size.height*2/80 , fontWeight: FontWeight.bold),
                          ),
                          TextField(
                            decoration: InputDecoration(
                                hintText: "Enter your ID",
                                suffixIcon: Icon(Icons.check)
                            ),
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).size.height*2/130,
                                fontWeight: FontWeight.w500
                            ),

                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*3/100),
                          Text("Password" , style: TextStyle(color: Color(0xFF071C52) ,
                              fontSize: MediaQuery.of(context).size.height*2/80 , fontWeight: FontWeight.bold),
                          ),
                          TextField(
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
                          SizedBox(height: MediaQuery.of(context).size.height*3/100),
                          Container(
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
                                child: Text("SIGN UP" , style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.of(context).size.height*3/130
                                ),
                                ),
                              )
                          ),

                        ],
                      ),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Already have an account?" , style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20
                              ),
                              ),
                              SizedBox(height:10),
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => signin()));
                                },
                                child: Text("SIGN IN" , style: TextStyle(
                                    color: const Color.fromARGB(255, 4,72,129),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25
                                ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(height:20),
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
