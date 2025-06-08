// ignore_for_file: unnecessary_new, prefer_const_constructors, unused_field, deprecated_member_use

import 'package:finpay/config/images.dart';
import 'package:finpay/config/textstyle.dart';
import 'package:finpay/controller/home_controller.dart';
import 'package:finpay/controller/tab_controller.dart';
import 'package:finpay/view/card/card_view.dart';
import 'package:finpay/view/home/home_view.dart';
import 'package:finpay/view/profile/profile_view.dart';
import 'package:finpay/view/statistics/statistics_view.dart';
// Solo un import para ReservaScreen
import 'package:finpay/view/reservas/reserva_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({super.key});

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  final tabController = Get.put(TabScreenController());
  final homeController = Get.put(HomeController());

  @override
  void initState() {
    tabController.customInit();
    homeController.customInit();
    super.initState();
  }

  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // FloatingActionButton para nueva reserva
      floatingActionButton: FloatingActionButton(
        backgroundColor: HexColor(AppTheme.primaryColorString!),
        onPressed: () {
          // Navegación a nueva reserva
          Get.to(() => ReservaScreen());
        },
        child: const Icon(
          Icons.add_location_alt,
          color: Colors.white,
          size: 24,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomNavigationBar(
        elevation: 20,
        currentIndex: tabController.pageIndex.value,
        onTap: (index) {
          setState(() {
            tabController.pageIndex.value = index;
          });
        },
        backgroundColor: AppTheme.isLightTheme == false
            ? HexColor('#15141f')
            : Theme.of(context).appBarTheme.backgroundColor,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: AppTheme.isLightTheme == false
            ? const Color(0xffA2A0A8)
            : HexColor(AppTheme.primaryColorString!).withOpacity(0.4),
        selectedItemColor: HexColor(AppTheme.primaryColorString!),
        items: [
          BottomNavigationBarItem(
            icon: SizedBox(
              height: 20,
              width: 20,
              child: SvgPicture.asset(
                DefaultImages.homr,
                color: tabController.pageIndex.value == 0
                    ? HexColor(AppTheme.primaryColorString!)
                    : AppTheme.isLightTheme == false
                        ? const Color(0xffA2A0A8)
                        : HexColor(AppTheme.primaryColorString!)
                            .withOpacity(0.4),
              ),
            ),
            label: "home",
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              height: 20,
              width: 20,
              child: SvgPicture.asset(
                DefaultImages.chart,
                color: tabController.pageIndex.value == 1
                    ? HexColor(AppTheme.primaryColorString!)
                    : AppTheme.isLightTheme == false
                        ? const Color(0xffA2A0A8)
                        : HexColor(AppTheme.primaryColorString!)
                            .withOpacity(0.4),
              ),
            ),
            label: "Statistics",
          ),
          BottomNavigationBarItem(
              icon: SizedBox(
                height: 20,
                width: 20,
                child: SvgPicture.asset(
                  DefaultImages.card,
                  color: tabController.pageIndex.value == 2
                      ? HexColor(AppTheme.primaryColorString!)
                      : AppTheme.isLightTheme == false
                          ? const Color(0xffA2A0A8)
                          : HexColor(AppTheme.primaryColorString!)
                              .withOpacity(0.4),
                ),
              ),
              label: "Card"),
          BottomNavigationBarItem(
              icon: SizedBox(
                height: 20,
                width: 20,
                child: SvgPicture.asset(
                  DefaultImages.user,
                  color: tabController.pageIndex.value == 3
                      ? HexColor(AppTheme.primaryColorString!)
                      : AppTheme.isLightTheme == false
                          ? const Color(0xffA2A0A8)
                          : HexColor(AppTheme.primaryColorString!)
                              .withOpacity(0.4),
                ),
              ),
              label: "profile"),
        ],
      ),

      body: GetX<TabScreenController>(
        init: tabController,
        builder: (tabController) => tabController.pageIndex.value == 0
            ? HomeView(homeController: homeController)
            : tabController.pageIndex.value == 1
                ? const StatisticsView()
                : tabController.pageIndex.value == 2
                    ? const CardView()
                    : const ProfileView(),
      ),
    );
  }
}
