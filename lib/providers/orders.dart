import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:stageApp/models/http_exception.dart';

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
  final String orderState;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
    this.orderState = "inProgress",
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetAllOrders() async {
    final url =
        'https://stage-1a56d.firebaseio.com/orders.json?auth=$authToken';
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title'],
                ),
              )
              .toList(),
          orderState: orderData['state'],
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    // final filterString =
    //     'orderBy="userId"&equalTo="XMlft7aDaNdaGrRSeZz33gZIMVC3"';
    final url =
        'https://stage-1a56d.firebaseio.com/orders.json?auth=$authToken';
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      if (orderData["userId"] == userId) {
        loadedOrders.add(
          OrderItem(
            id: orderId,
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']),
            products: (orderData['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                    id: item['id'],
                    price: item['price'],
                    quantity: item['quantity'],
                    title: item['title'],
                  ),
                )
                .toList(),
            orderState: orderData['state'],
          ),
        );
      }
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> archiveOrder(OrderItem order) async {
    final orderId = order.id;
    final archiveUrl =
        'https://stage-1a56d.firebaseio.com/archive.json?auth=$authToken';
    final timestamp = DateTime.now();
    final response = await http.post(
      archiveUrl,
      body: json.encode({
        'amount': order.amount,
        'archiveDateTime': timestamp.toIso8601String(),
        'orderDateTime': order.dateTime.toIso8601String(),
        'products': order.products
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price,
                })
            .toList(),
        'state': order.orderState,
      }),
    );

    final orderUrl =
        'https://stage-1a56d.firebaseio.com/orders/$orderId.json?auth=$authToken';
    final existingOrderIndex = _orders.indexWhere((o) => o.id == orderId);
    var existingOrder = _orders[existingOrderIndex];
    _orders.removeAt(existingOrderIndex);
    notifyListeners();
    final responseOrder = await http.delete(orderUrl);
    if (responseOrder.statusCode >= 400) {
      _orders.insert(existingOrderIndex, existingOrder);
      notifyListeners();
      throw HttpException('Could not archive the order.');
    }
    existingOrder = null;

    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        'https://stage-1a56d.firebaseio.com/orders.json?auth=$authToken';
    final timestamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        'userId': "XMlft7aDaNdaGrRSeZz33gZIMVC3",
        'amount': total,
        'dateTime': timestamp.toIso8601String(),
        'products': cartProducts
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price,
                })
            .toList(),
        'state': "In progress...",
      }),
    );
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        dateTime: timestamp,
        products: cartProducts,
      ),
    );
    notifyListeners();
  }

  Future<void> confirmOrCancelOrder(String id, OrderItem order) async {
    final orderIndex = _orders.indexWhere((order) => order.id == id);

    if (orderIndex >= 0) {
      final url =
          'https://stage-1a56d.firebaseio.com/orders/$id.json?auth=$authToken';
      await http.put(url,
          body: json.encode({
            'amount': order.amount,
            'dateTime': order.dateTime.toIso8601String(),
            'products': order.products
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price,
                    })
                .toList(),
            'state': order.orderState,
          }));
      _orders[orderIndex] = order;
      print(order.orderState);
      notifyListeners();
    } else {
      print('...');
    }
  }
}
