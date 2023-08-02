import 'package:admin_panel_grocery_app/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../controllers/MenuController.dart';
import '../responsive.dart';
import '../widgets/side_menu.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuController>().getScaffoldKey,
      drawer:  SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(child: SideMenu(),
                // default flex = 1
                // and it takes 1/6 part of the screen
                // child: SideMenu(),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child:DashboardScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
