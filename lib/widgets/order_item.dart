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
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      // height:
      //     _expanded ? min(widget.order.products.length * 20.0 + 110, 200) : 95,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              // leading: IconButton(
              //     icon: Icon(
              //       Icons.archive_rounded,
              //       color: Color.fromRGBO(64, 61, 57, 1),
              //       size: 25,
              //     ),
              //     onPressed: () {
              // Provider.of<Orders>(context, listen: false)
              //     .archiveOrder(widget.order);
              //     }),
              title: Text(
                '${widget.order.amount} Dhs',
                style: TextStyle(color: Color.fromRGBO(64, 61, 57, 1)),
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
                          style:
                              TextStyle(color: Color.fromRGBO(64, 61, 57, 1)),
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
                height: widget.order.products.length * 20.0 + 80,
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
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      // Confirm
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: InkWell(
                            onTap: () {
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
                                      onPressed: () async {
                                        Navigator.of(ctx).pop(true);
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        await Provider.of<Orders>(context,
                                                listen: false)
                                            .confirmOrCancelOrder(
                                                widget.order.id,
                                                ord.OrderItem(
                                                  id: widget.order.id,
                                                  amount: widget.order.amount,
                                                  dateTime:
                                                      widget.order.dateTime,
                                                  products:
                                                      widget.order.products,
                                                  orderState: "Confirmed",
                                                ));
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Center(
                                  child: Text(
                                    'Confirm order',
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .copyWith(
                                            color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                color: Color.fromRGBO(6, 214, 160, 1),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Cancel
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: InkWell(
                            onTap: () {
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
                                      onPressed: () async {
                                        Navigator.of(ctx).pop(true);
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        await Provider.of<Orders>(context,
                                                listen: false)
                                            .confirmOrCancelOrder(
                                                widget.order.id,
                                                ord.OrderItem(
                                                  id: widget.order.id,
                                                  amount: widget.order.amount,
                                                  dateTime:
                                                      widget.order.dateTime,
                                                  products:
                                                      widget.order.products,
                                                  orderState: "Cancel",
                                                ));
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Center(
                                  child: Text(
                                    'Cancel order',
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .copyWith(
                                            color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(254, 95, 85, 1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ]),
              )
          ],
        ),
      ),
    );
  }
}
