import 'package:admin_panel_grocery_app/services/utils.dart';
import 'package:admin_panel_grocery_app/widgets/text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';

class OrderWidget extends StatefulWidget {
  final double price, totalPrice;
  final String productId, userId, imageUrl, userName;
  final int quantity;
  final Timestamp orderDate;

  const OrderWidget(
      {Key? key,
      required this.price,
      required this.totalPrice,
      required this.productId,
      required this.userId,
      required this.imageUrl,
      required this.userName,
      required this.quantity,
      required this.orderDate})
      : super(key: key);

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  late String orderDateStr;
  @override
  void initState() {
    var postDate =widget.orderDate.toDate();
    orderDateStr ='${postDate.day}/${postDate.month}/${postDate.year}';
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Utils(context).getTheme;
    Size size = Utils(context).getScreenSize;
    Color color = Utils(context).color;
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(8.0),
        color: Theme.of(context).cardColor.withOpacity(0.4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              flex: size.width < 650 ? 3 : 1,
              child: FancyShimmerImage(
                imageUrl:
                    widget.imageUrl,
                boxFit: BoxFit.fill,
                height: size.width * 0.2,
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(
              flex: 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: "${widget.quantity}x \$${widget.price.toStringAsFixed(2)}",
                    color: color,
                    textSize: 16,
                    isTitle: true,
                  ),
                  FittedBox(
                    child: Row(
                      children: [
                        TextWidget(
                          text: "By",
                          color: Colors.blue,
                          textSize: 16,
                          isTitle: true,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        TextWidget(
                          text: '${widget.userName}',
                          color: color,
                          textSize: 14,
                          isTitle: true,
                        )
                      ],
                    ),
                  ),
                  Text(orderDateStr),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
