import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stageApp/providers/auth.dart';
import 'package:stageApp/widgets/user_order_item.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    print('building orders');
    final isAdmin = Provider.of<Auth>(context).isAdmin;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Your Orders'),
        shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40))),
        backgroundColor: Color.fromRGBO(64, 61, 57, 1),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future:
            Provider.of<Orders>(context, listen: false).fetchAndSetAllOrders(),
        // Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapshot.error != null) {
              // ...
              // Do error handling stuff
              return Center(
                child: Text('An error occurred!'),
              );
            } else {
              return Consumer<Orders>(
                builder: (ctx, orderData, child) => (orderData
                        .orders.isNotEmpty)
                    ? ListView.builder(
                        itemCount: orderData.orders.length,
                        itemBuilder: (ctx, i) =>
                            UserOrderItem(orderData.orders[i]),
                      )
                    : Center(
                        child: Column(
                          children: [
                            Container(
                              child: Image.asset(
                                "assets/images/noOrder.png",
                              ),
                              height: 380,
                              width: 380,
                            ),
                            Text(
                              "No orders yet !",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).popAndPushNamed('/');
                              },
                              child: Container(
                                  width: 140,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(235, 94, 40, 1),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: Center(
                                    child: Text(
                                      "Go Shopping",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 17),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
              );
            }
          }
        },
      ),
    );
  }
}
