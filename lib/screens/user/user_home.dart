import 'package:flutter/material.dart';
import 'package:yatra_park/core/constants/app_colors.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(

      body:Padding(
        padding:  EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60,),
            Container(child: const Text("Hello Welcome", style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: AppColors.textWhite),)),


            const Spacer(),

            Center(
              child: GestureDetector(
                onTap: (){
                  debugPrint("QR Scanner Opened");
                },
                child: Container(
                  width: 300,
                  height: 300,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.lightBlue,
                    border: Border.all(
                      color: AppColors.accentBlue,
                      width: 3,
                    ),
                      boxShadow: [
                       BoxShadow(
                         color: AppColors.accentBlue,
                         blurRadius: 20,
                         spreadRadius: 5,
                       )
                      ],
                  ),

                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,size: 80,color: AppColors.textWhite,
                      ),

                      SizedBox(height: 15,),
                      Text("SCAN ENTRY QR", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white, letterSpacing: 1),),

                    ],
                  ),
                ),
              ),
            ),


            const Spacer(),

          ],
        )
      ),


      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.accentBlue,
        unselectedItemColor: AppColors.textMuted,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,

        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          )
        ],

      ),



    );
  }
}