import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stageApp/providers/orders.dart';

import '../providers/orders.dart' as ord;

class UserOrderItem extends StatefulWidget {
  final ord.OrderItem order;

  UserOrderItem(this.order);

  @override
  _UserOrderItemState createState() => _UserOrderItemState();
}

class _UserOrderItemState extends State<UserOrderItem> {
  var _expanded = false;
  var _isLoading = false;
  var _isLoadingArchive = false;
  DateTime _delivryDate;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      child: Dismissible(
        background: Container(
          color: Color.fromRGBO(254, 95, 85, 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cancel,
                color: Colors.white,
                size: 30,
              ),
              Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          margin: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 4,
          ),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) {
          return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Are you sure?',
                style: TextStyle(
                  fontSize: 20,
                  color: Color.fromRGBO(254, 95, 85, 1),
                ),
              ),
              content: Text(
                'Do you want to cancel your order?',
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    'No',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop(false);
                  },
                ),
                FlatButton(
                  child: Text(
                    'Yes',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () async {
                    Navigator.of(ctx).pop(true);
                  },
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) {
          Provider.of<Orders>(context, listen: false)
              .deleteOrderFromUser(widget.order);
        },
        key: Key(widget.order.id),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          margin: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              ListTile(
                leading: (_isLoadingArchive)
                    ? CircularProgressIndicator()
                    : InkWell(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Color.fromRGBO(64, 61, 57, 1),
                              size: 25,
                            ),
                            Text(
                              'Infos',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(64, 61, 57, 1),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          String deliveryDate = DateFormat('dd/MM/yyyy')
                              .format(widget.order.deliveryDate);
                          return showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 3,
                              title: Icon(
                                Icons.delivery_dining,
                                size: 50,
                                color: Color.fromRGBO(235, 94, 40, 1),
                              ),
                              content: Container(
                                height: 120,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (widget.order.orderState == "Confirmed")
                                            ? (widget.order.deliveryOption ==
                                                    "onSite")
                                                ? "Your order will be ready the $deliveryDate !"
                                                : "You'll be delivred the $deliveryDate in ${widget.order.deliveryAddress} !"
                                            : (widget.order.orderState ==
                                                    "Canceled")
                                                ? "We're sorry to inform you that your order has been canceled !"
                                                : "Your order needs to be confirmed !",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 20),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                title: Row(
                  children: [
                    Text(
                      '${widget.order.amount} Dhs',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy hh:mm')
                          .format(widget.order.dateTime),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    _isLoading
                        ? Container(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(),
                          )
                        : Text(
                            '${widget.order.orderState}',
                            style: TextStyle(
                              color:
                                  (widget.order.orderState == "In progress...")
                                      ? Colors.amber[600]
                                      : (widget.order.orderState == "Confirmed")
                                          ? Color.fromRGBO(6, 214, 160, 1)
                                          : Color.fromRGBO(254, 95, 85, 1),
                            ),
                          ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                ),
              ),
              if (_expanded)
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  height: widget.order.products.length * 20.0 + 30,
                  child: ListView(children: [
                    ...widget.order.products
                        .map(
                          (prod) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                prod.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${prod.quantity}x ${prod.price} Dhs',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          ),
                        )
                        .toList(),
                  ]),
                )
            ],
          ),
        ),
      ),
    );
  }
}
