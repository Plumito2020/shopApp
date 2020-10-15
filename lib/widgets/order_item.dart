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
  var _isLoadingArchive = false;
  DateTime _delivryDate;

  Future<void> _confirmOrder() async {
    if (_delivryDate != null) {
      Navigator.of(context).pop();
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Orders>(context, listen: false).confirmOrCancelOrder(
        widget.order.id,
        ord.OrderItem(
          id: widget.order.id,
          amount: widget.order.amount,
          dateTime: widget.order.dateTime,
          products: widget.order.products,
          orderState: "Confirmed",
          orderMakerId: widget.order.orderMakerId,
          deliveryAddress: widget.order.deliveryAddress,
          deliveryOption: widget.order.deliveryOption,
          deliveryDate: _delivryDate,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deliveryBottomSheet() {
    showModalBottomSheet(
        isScrollControlled: true,
        // enableDrag: false,
        // isDismissible: false,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        )),
        context: context,
        builder: (BuildContext ctx) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setState /*You can rename this!*/) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                height: 200,
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
                        "Delivery date",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    // Date Picker
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            border: Border.all(color: Colors.grey[600])),
                        height: 60,
                        width: double.infinity,
                        child: FlatButton(
                            onPressed: () {
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2021),
                              ).then((date) {
                                setState(() {
                                  _delivryDate = date;
                                });
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(
                                  width: 14,
                                ),
                                (_delivryDate == null)
                                    ? Text(
                                        "Pick a date",
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 15),
                                      )
                                    : Text(
                                        DateFormat.yMMMMd('en_US')
                                            .format(_delivryDate),
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 15),
                                      ),
                              ],
                            )),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                            onTap: () {
                              _confirmOrder();
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
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      child: Dismissible(
        background: Container(
          color: Color.fromRGBO(64, 61, 57, 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.archive_rounded,
                color: Colors.white,
                size: 30,
              ),
              Text(
                'Archive',
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
                'Do you want to archive this order?',
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
              .archiveOrder(widget.order);
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
                    // Archive Order
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
                                height:
                                    (widget.order.deliveryOption == "onSite")
                                        ? 100
                                        : 200,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (widget.order.deliveryOption ==
                                                "onSite")
                                            ? "The costumer will drop by to pick up his order !"
                                            : "The order will be delivred to the costumer !",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      if (widget.order.deliveryOption !=
                                          "onSite")
                                        Divider(),
                                      if (widget.order.deliveryOption !=
                                          "onSite")
                                        SizedBox(
                                          height: 10,
                                        ),
                                      if (widget.order.deliveryOption !=
                                          "onSite")
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Address  ",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    235, 94, 40, 1),
                                                fontSize: 15),
                                          ),
                                        ),
                                      if (widget.order.deliveryOption !=
                                          "onSite")
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "${widget.order.deliveryAddress}",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15),
                                          ),
                                        ),
                                      if (widget.order.deliveryOption !=
                                          "onSite")
                                        SizedBox(
                                          height: 10,
                                        ),
                                      if (widget.order.deliveryDate !=
                                          DateTime(2000))
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Delivery date  ",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    235, 94, 40, 1),
                                                fontSize: 15),
                                          ),
                                        ),
                                      if (widget.order.deliveryDate !=
                                          DateTime(2000))
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            DateFormat('dd/MM/yyyy').format(
                                                widget.order.deliveryDate),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15),
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                title: Text(
                  'Total : ${widget.order.amount} Dhs',
                  style: TextStyle(color: Colors.black),
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
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        // Confirm order
                        if (widget.order.orderState != "Confirmed")
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: InkWell(
                                onTap: () {
                                  _deliveryBottomSheet();
                                },
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Center(
                                      child: Text(
                                        'Confirm order',
                                        style: Theme.of(context)
                                            .textTheme
                                            .body1
                                            .copyWith(
                                                color: Colors.white,
                                                fontSize: 18),
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
                        if (widget.order.orderState != "Canceled")
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
                                                dateTime: widget.order.dateTime,
                                                products: widget.order.products,
                                                orderState: "Canceled",
                                                orderMakerId:
                                                    widget.order.orderMakerId,
                                                deliveryAddress: widget
                                                    .order.deliveryAddress,
                                                deliveryOption:
                                                    widget.order.deliveryOption,
                                                deliveryDate: DateTime(2000),
                                              ),
                                            );
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Center(
                                      child: Text(
                                        'Cancel order',
                                        style: Theme.of(context)
                                            .textTheme
                                            .body1
                                            .copyWith(
                                                color: Colors.white,
                                                fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(254, 95, 85, 1),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
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
      ),
    );
  }
}
