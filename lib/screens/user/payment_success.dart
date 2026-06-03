import 'dart:io';

import "package:flutter/material.dart";
import 'package:yatra_park/core/constants/app_colors.dart';

class PaymentSuccessPage extends StatelessWidget {

  //This needs to be dynamic


  final String fareAmount;
  final String vehicleNumber;
  final String duration;
  final String exitTime;
  final String paymentMethod;




  const PaymentSuccessPage({
    super.key,
    this.fareAmount = "NPR 120.00",
    this.vehicleNumber = "BA 2 CH 1234",
    this.duration = "02h : 14m",
    this.exitTime = "10 : 11 AM",
    this.paymentMethod = "CASH",
});


  @override
  Widget build(BuildContext context) {
          return Scaffold(
            backgroundColor: AppColors.primaryDark,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),



                    //Making the checkmark


                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.successGreen,
                          width: 5,
                        ),
                        
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.successGreen.withOpacity(0.05),
                            blurRadius: 20,
                            spreadRadius: 5,
                          )
                        ],
                        
                      ),

                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.successGreen,
                        size: 90,
                      ),
                    ),



                    const SizedBox(height: 32,),



                    //header


                    const Text("Payment Successful!", style: TextStyle(color: AppColors.successGreen, fontSize: 30,fontWeight: FontWeight.bold),),
                    
                    
                    const SizedBox(height: 10,),
                    

                    const Text("Barrier is opening. Have a safe journey!", textAlign: TextAlign.center, style: TextStyle(color: AppColors.successGreen, fontSize: 18, fontWeight: FontWeight(500),
                    ),),

                    const SizedBox(height: 40,),


                    //Ticket Info Part


                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20 , horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.borderDark,
                          width: 1,
                        ),
                      ),
                      
                      
                      child: Column(
                        children: [
                          const Text("FINAL FARE PAID", style: TextStyle(color: AppColors.textMuted,fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1),),
                          const SizedBox(height: 6,),

                          Text(fareAmount , style: const TextStyle(color: AppColors.accentOrange,fontSize: 28, fontWeight: FontWeight.bold),),




                          //center divider


                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Divider(
                              color: AppColors.borderDark,
                              thickness: 1.5,
                            ),
                          ),



                          //RECEIPT DETAILS

                          _buildReceiptRow("Vehicle:", vehicleNumber),
                          const SizedBox(height: 14,),


                          _buildReceiptRow("Duration:", duration),
                          const SizedBox(height: 14,),


                          _buildReceiptRow("Exit Time:", exitTime),
                          const SizedBox(height: 14,),




                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Method:", style: TextStyle(color: AppColors.textMuted,fontSize: 15),),
                              Text(paymentMethod , style: const TextStyle(color: AppColors.textWhite,fontSize: 15,fontWeight: FontWeight.bold),),

                            ],
                          )





                        ],
                      ),
                      
                      
                    ),



                    const Spacer(),


                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route)=>route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                          elevation: 0,
                        ),
                        child: const Text("BACK TO HOME", style: TextStyle(color: AppColors.textWhite,fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),),
                      ),
                    ),



                    const SizedBox(height: 16,)



                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildReceiptRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Separates columns completely to outer boundaries
      children: [
        Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 15)),
        Text(value, style: const TextStyle(color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight.w500)),
      ],
    );
  }
}



