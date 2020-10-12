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

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
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
    final url = 'https://stage-1a56d.firebaseio.com/orders?auth=$authToken';
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
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://stage-1a56d.firebaseio.com/orders/$userId.json?auth=$authToken';
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
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> archiveOrder(OrderItem order) async {
    final orderId = order.id;
    final archiveUrl =
        'https://stage-1a56d.firebaseio.com/archive/$userId.json?auth=$authToken';
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
      }),
    );

    final orderUrl =
        'https://stage-1a56d.firebaseio.com/orders/$userId.json/$orderId.json?auth=$authToken';
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
        'https://stage-1a56d.firebaseio.com/orders/$userId.json?auth=$authToken';
    final timestamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
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
}
