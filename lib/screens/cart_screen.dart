import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stageApp/screens/orders_screen.dart';

import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
        shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40))),
        backgroundColor: Color.fromRGBO(64, 61, 57, 1),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.title.color,
                      ),
                    ),
                    backgroundColor: Color.fromRGBO(235, 94, 40, 1),
                  ),
                  OrderButton(cart: cart)
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) => CartItem(
                cart.items.values.toList()[i].id,
                cart.items.keys.toList()[i],
                cart.items.values.toList()[i].price,
                cart.items.values.toList()[i].quantity,
                cart.items.values.toList()[i].title,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  var _addressController = TextEditingController();
  Map<String, bool> _delivryOption = {
    "onSite": false,
    "delivry": false,
  };

  Future<void> _confirmMyOrder() async {
    bool optionSelcted = false;
    String whatOption = "";
    _delivryOption.forEach((key, value) {
      if (value == true) {
        optionSelcted = true;
        whatOption = key;
      }
    });

    if (optionSelcted == true) {
      if ((whatOption == "delivry" && _addressController.text.isNotEmpty) ||
          whatOption == "onSite") {
        Navigator.of(context).pop();
        setState(() {
          _isLoading = true;
        });
        await Provider.of<Orders>(context, listen: false).addOrder(
          widget.cart.items.values.toList(),
          widget.cart.totalAmount,
          whatOption,
          _addressController.text,
          DateTime(2000),
        );
        setState(() {
          _isLoading = false;
        });
        widget.cart.clear();
        Navigator.of(context).popAndPushNamed(OrdersScreen.routeName);
      }
    }
  }

  void _deliveryBottomSheet() {
    showModalBottomSheet(
        isScrollControlled: true,
        // enableDrag: false,
        // isDismissible: false,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        )),
        context: context,
        builder: (BuildContext ctx) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setState /*You can rename this!*/) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                height: (_delivryOption["delivry"]) ? 270 : 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "Delivery options",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    // Delivry options
                    Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: FlatButton(
                              onPressed: () {
                                setState(() {
                                  _delivryOption["onSite"] =
                                      !_delivryOption["onSite"];
                                  _delivryOption["delivry"] = false;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 50,
                                // width: 80,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  child: Text("I'll drop by !",
                                      style: (_delivryOption["onSite"] == true)
                                          ? Theme.of(context)
                                              .textTheme
                                              .body1
                                              .copyWith(
                                                  color: Colors.white,
                                                  fontSize: 18)
                                          : Theme.of(context)
                                              .textTheme
                                              .body1
                                              .copyWith(
                                                  color: Color.fromRGBO(
                                                      235, 94, 40, 1),
                                                  fontSize: 18)),
                                ),
                                decoration: (_delivryOption["onSite"] == true)
                                    ? BoxDecoration(
                                        color: Color.fromRGBO(235, 94, 40, 1),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)))
                                    : BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Color.fromRGBO(235, 94, 40, 1),
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                              ),
                            )),
                        Expanded(
                          flex: 1,
                          child: FlatButton(
                            onPressed: () {
                              setState(() {
                                _delivryOption["delivry"] =
                                    !_delivryOption["delivry"];
                                _delivryOption["onSite"] = false;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 50,
                              // width: 80,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: Text('Deliver it !',
                                    style: (_delivryOption["delivry"] == true)
                                        ? Theme.of(context)
                                            .textTheme
                                            .body1
                                            .copyWith(
                                                color: Colors.white,
                                                fontSize: 18)
                                        : Theme.of(context)
                                            .textTheme
                                            .body1
                                            .copyWith(
                                                color: Color.fromRGBO(
                                                    235, 94, 40, 1),
                                                fontSize: 18)),
                              ),
                              decoration: (_delivryOption["delivry"] == true)
                                  ? BoxDecoration(
                                      color: Color.fromRGBO(235, 94, 40, 1),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)))
                                  : BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color:
                                              Color.fromRGBO(235, 94, 40, 1)),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_delivryOption["delivry"] == true)
                      SizedBox(
                        height: 20,
                      ),
                    if (_delivryOption["delivry"] == true)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Your address",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    if (_delivryOption["delivry"] == true)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextField(
                          controller: _addressController,
                        ),
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                            onTap: () {
                              _confirmMyOrder();
                            },
                            child: Text(
                              "Confirm",
                              style: TextStyle(
                                  color: Color.fromRGBO(235, 94, 40, 1),
                                  fontSize: 20),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
        child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'),
        onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
            ? null
            : () {
                _deliveryBottomSheet();
              },
        textColor: Color.fromRGBO(235, 94, 40, 1));
  }
}
