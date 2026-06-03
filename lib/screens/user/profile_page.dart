import 'package:flutter/material.dart';
import 'package:yatra_park/core/constants/app_colors.dart';
import 'package:yatra_park/models/user_profile.dart';



class ProfilePage extends StatelessWidget{
  final UserProfile userProfile;



  const ProfilePage({
    super.key,
    required this.userProfile,
});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,


      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 40,),

            //Profile avatar

            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.successGreen,
                  width: 3,
                ),
                
                boxShadow: [
                  BoxShadow(
                    color: AppColors.successGreen.withOpacity(0.05),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),

              child: CircleAvatar(
                backgroundColor: AppColors.surfaceDark,
                child: Text(userProfile.name.substring(0,2).toUpperCase(),
                style: const TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold, fontSize: 32, letterSpacing: 1.2),
                ),
              ),
            ),


            const SizedBox(height: 16,),



            //Dyamic area for name and email

            Text(
              userProfile.name,
              style: const TextStyle(color: AppColors.textWhite, fontSize: 24,fontWeight: FontWeight.bold),
            ),


            const SizedBox(height: 4,),
            Text(
              userProfile.email,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14,),
            ),

            const SizedBox(height: 32,),


            //Menu

            Padding(padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.settings_outlined,
                    title: "Account Settings",
                  ),
                  const SizedBox(height: 16,),

                  _buildProfileTile(
                    icon: Icons.directions_car_outlined,
                    title: "My Vehicles",
                    subtitle: "1 Vehicle - BA 2 CH 1234",
                  ),

                  const SizedBox(height: 16,),


                  _buildProfileTile(
                    icon : Icons.info_outline,
                    title: "Support & Help",
                  ),

                  const SizedBox(height: 24,),

                  //Signout

                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                    ),


                    child: TextButton(onPressed: (){}, child: const Text("Sign Out",
                    style: TextStyle(color: AppColors.errorRed , fontSize: 16, fontWeight: FontWeight.bold),)),

                  )
                ],
              ),

            ),


            const Spacer(),


            BottomNavigationBar(
              backgroundColor: AppColors.primaryDark,
              selectedItemColor: AppColors.textWhite,
              unselectedItemColor: AppColors.textMuted,
              currentIndex: 2, // Active highlight focused on the Profile menu segment
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_filled),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_toggle_off_rounded),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }





  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }

