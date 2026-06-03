import 'package:flutter/material.dart';
import 'package:yatra_park/core/constants/app_colors.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100,),



                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(20),
                  ),




                  child: Column(
                    children: [
                      //Making Green Label
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.circle, color: Colors.green, size: 16,
                          ),
                          const SizedBox(width: 6,),
                          Text("ACTIVE SESSION", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,letterSpacing: 1.2),),
                        ],
                      ),


                      //Time ko info


                      const SizedBox(height: 12,),
                      Text("02h : 14m : 38s", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),),


                      const SizedBox(height: 40,),

                      const Text("NPR 120.00", style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),),
                      const Text("Current Fare", style: TextStyle(fontSize: 22, color: AppColors.textMuted),)


                    ],
                  ),
                ),

                const SizedBox(height: 16,),


                //VEHICLE KO PLATE

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                  ),


                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("BA 2 CH 1234", style: TextStyle(fontSize: 26, letterSpacing: 0.5, fontWeight: FontWeight.bold, color: Colors.white),),
                      Icon(
                        Icons.directions_car_filled_outlined,
                        color: Colors.grey.shade500,
                        size: 24,
                      ),
                    ],
                  ),
                )

              ],
            ),
          ),

          //Interactive panel



          DraggableScrollableSheet(
            initialChildSize: 0.38,
            minChildSize: 0.38,
            maxChildSize: 0.85,
            builder: (BuildContext context , ScrollController scrollController){
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                
                child: ListView(
                  controller: scrollController,     //Most vital yesle connect garcha drag 
                  padding: const EdgeInsets.all(24),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),


                    const SizedBox(height: 50,),


                    const Center(
                      child: Text("DRAG FOR QR", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold, fontSize: 30, letterSpacing: 0.5),),
                    ),
                    
                    
                    const SizedBox(height: 4,),
                    const Center(
                      child: Text("Present to Exit Gate Attendant", style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight(500)),),
                    ),


                    const SizedBox(height: 80,),
                    //QR AREA

                    Center(
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),


                        child: Icon(Icons.qr_code_2, size: 300,color: Colors.grey.shade800,),



                      ),
                    ),
                    
                    
                    
                    const SizedBox(height: 20,),
                    const Center(
                      child: Text("This is your qr which hold sthe data of you session",style: TextStyle(color: Colors.grey, fontSize: 14),),
                    )

                  ],
                ),
                
                
              );
            }
          )

        ],
      )
    );
  }
}