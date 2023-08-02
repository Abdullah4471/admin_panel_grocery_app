import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/MenuController.dart';
import '../responsive.dart';
import '../services/utils.dart';
import '../widgets/grid_product.dart';
import '../widgets/header.dart';
import '../widgets/side_menu.dart';

class AllProductScreen extends StatefulWidget {
  const AllProductScreen({Key? key}) : super(key: key);

  @override
  State<AllProductScreen> createState() => _AllProductScreenState();
}

class _AllProductScreenState extends State<AllProductScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = Utils(context).getScreenSize;

    return Scaffold(
      key: context.read<MenuController>().getgridscaffoldKey,
      drawer: SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                child: SideMenu(),
                // default flex = 1
                // and it takes 1/6 part of the screen
                // child: SideMenu(),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Header(
                        title: 'Dashboard',
                        fct: () {
                          context.read<MenuController>().controlProductsMenu();
                        }),
                    Responsive(
                      mobile: ProductGridWidget(
                        childAspectRatio:
                            size.width < 650 && size.width > 350 ? 1.1 : 0.8,
                        crossAxisCount: size.width < 650 ? 2 : 4,
                        isInMain: false,
                      ),
                      desktop: ProductGridWidget(
                        isInMain: false,
                        childAspectRatio: size.width < 1400 ? 0.8 : 1.08,

                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
