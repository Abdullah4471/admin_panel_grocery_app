import 'package:admin_panel_grocery_app/widgets/order_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../consts/constant.dart';



class OrdersList extends StatelessWidget {
  final bool isInDishBoard;
  const OrdersList({Key? key,  this.isInDishBoard=true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      //there was a null error just add those lines
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.data!.docs.isNotEmpty) {
            return Container(
              padding:  EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: isInDishBoard &&snapshot.data!.docs.length> 5 ?5:snapshot.data!.docs.length,
                  itemBuilder: (ctx, index) {
                    return Column(
                      children:  [
                        OrderWidget(
                          userName: snapshot.data!.docs[index]['userName'],
                          productId: snapshot.data!.docs[index]['productId'],
                          userId: snapshot.data!.docs[index]['userId'],
                          price: snapshot.data!.docs[index]['price'],
                          totalPrice: snapshot.data!.docs[index]['totalPrice'],
                          quantity: snapshot.data!.docs[index]['quantity'],
                          orderDate: snapshot.data!.docs[index]['orderDate'],
                          imageUrl: snapshot.data!.docs[index]['imageUrl'],
                        ),
                        Divider(
                          thickness: 3,
                        ),
                      ],
                    );
                  }),
            );
          } else {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(18.0),
                child: Text('Your store is empty'),
              ),
            );
          }
        }
        return const Center(
          child: Text(
            'Something went wrong',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
        );
      },
    );
  }
}
