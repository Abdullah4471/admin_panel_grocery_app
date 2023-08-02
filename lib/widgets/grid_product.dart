import 'package:admin_panel_grocery_app/services/utils.dart';
import 'package:admin_panel_grocery_app/widgets/product_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../consts/constant.dart';
class ProductGridWidget extends StatelessWidget {
  const ProductGridWidget(
      {Key? key,
        this.crossAxisCount = 4,
        this.childAspectRatio = 1,
        this.isInMain = true})
      : super(key: key);
  final int crossAxisCount;
  final double childAspectRatio;
  final bool isInMain;
  @override
  Widget build(BuildContext context) {
    final Color color =Utils(context).color;
    return StreamBuilder<QuerySnapshot>(
      //there was a null error just add those lines
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.data!.docs.isNotEmpty) {
            return snapshot.data!.docs.length ==0
             ? Center(
              child: Padding(
                padding: EdgeInsets.all(18.0),
                child: Text('Your store is empty'),
              ),
            ):GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: isInMain && snapshot.data!.docs.length > 4
                    ? 4
                    : snapshot.data!.docs.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: defaultPadding,
                  mainAxisSpacing: defaultPadding,
                ),
                itemBuilder: (context, index) {
                  return ProductWidget(
                    id: snapshot.data!.docs[index]['id'],
                  );
                });
          } else
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(18.0),
                child: Text(
                  'Your store is empty',
                  style: TextStyle( fontSize: 16,),
                ),
              ),
            );

        }
        return Center(child: Text('Something went wrong',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: color),),);
      },
    );
  }
}