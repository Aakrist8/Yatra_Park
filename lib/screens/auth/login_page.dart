

import 'package:flutter/material.dart';
import 'package:yatra_park/core/constants/app_colors.dart';


class LoginPage extends StatelessWidget{
  const LoginPage ({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Row(                                                         //Yatra Park Top part
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Yatra", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),),
                          const Text("Park", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.accentOrange),)
                        ],
                      ),

                      const SizedBox(height: 8),

                      const Text("Smart Parking, Made Easy", style: TextStyle(fontSize: 14, fontWeight: FontWeight(500), color: AppColors.textMuted),),

                      const  SizedBox(height: 70,),

                      TextField(                                          //Textfield to enter details for login
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                              borderSide: BorderSide(
                                  color: Colors.blue
                              )
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                              borderSide: BorderSide(
                                  color: Colors.black
                              )
                          ),

                          suffixText : "Email ID",
                          suffixIcon: IconButton(
                            icon: Icon(Icons.mail),
                            onPressed: (){
                              debugPrint("clicked");
                            },
                          ),
                        ),
                      ),

                      Container(height: 11,),


                      TextField(
                        decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(11),
                                borderSide: BorderSide(
                                    color: Colors.blue
                                )
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                              borderSide: BorderSide(
                                  color: Colors.black
                              ),
                            )
                        ),
                      ),

                      const  SizedBox(height: 25,),

                      ElevatedButton(                              //Login Button
                        onPressed: (){
                          debugPrint("Clicked");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          foregroundColor: AppColors.textWhite,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          )
                        ),
                        
                        child: Text("Login"),
                        
                      ),



                      const SizedBox(height: 25,),


                      Row(                                                                  //For signup if no account is present
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account?", style: TextStyle(fontSize: 14, color: AppColors.textMuted),),


                          GestureDetector(
                            onTap: () {
                              debugPrint("Navigate to sign up page clicked!");
                            },

                            child: const Text("Sign Up", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.accentOrange),),
                          )

                        ],
                      )

                    ],
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }








}