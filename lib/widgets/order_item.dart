import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stageApp/providers/orders.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height:
          _expanded ? min(widget.order.products.length * 20.0 + 110, 200) : 95,
      child: Dismissible(
        key: Key(widget.order.id),
        background: Container(
          color: Color.fromRGBO(254, 95, 85, 1),
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Canceled",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
            ),
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          margin: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 4,
          ),
        ),
        secondaryBackground: Container(
          color: Color.fromRGBO(6, 214, 160, 1),
          child: Text(
            "Confirmed",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
            ),
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          margin: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 4,
          ),
        ),
        confirmDismiss: (direction) {
          if (direction == DismissDirection.startToEnd) {
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
                  'Do you want to cancel this order?',
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
                    onPressed: () {
                      Navigator.of(ctx).pop(true);
                    },
                  ),
                ],
              ),
            );
          } else if (direction == DismissDirection.endToStart) {
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
                  'Do you want to confirm this order?',
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
                    onPressed: () {
                      Navigator.of(ctx).pop(true);
                    },
                  ),
                ],
              ),
            );
          }
        },
        onDismissed: (direction) {
          // Provider.of<Cart>(context, listen: false).removeItem(productId);
        },
        child: Card(
          margin: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              ListTile(
                leading: IconButton(
                    icon: Icon(
                      Icons.archive_rounded,
                      color: Color.fromRGBO(64, 61, 57, 1),
                      size: 25,
                    ),
                    onPressed: () {
                      Provider.of<Orders>(context, listen: false)
                          .archiveOrder(widget.order);
                    }),
                title: Text(
                  '${widget.order.amount} Dhs',
                  style: TextStyle(color: Color.fromRGBO(64, 61, 57, 1)),
                ),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
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
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                height: _expanded
                    ? min(widget.order.products.length * 20.0 + 10, 100)
                    : 0,
                child: ListView(
                  children: widget.order.products
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
                              '${prod.quantity}x \$${prod.price}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      )
                      .toList(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
