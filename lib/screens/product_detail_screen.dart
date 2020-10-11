import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stageApp/providers/cart.dart';

import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String title;
  // final double price;

  // ProductDetailScreen(this.title, this.price);
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId =
        ModalRoute.of(context).settings.arguments as String; // is the id!
    final loadedProduct = Provider.of<Products>(
      context,
      listen: false,
    ).findById(productId);
    final cart = Provider.of<Cart>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      body: Builder(
        builder: (context) => CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Color.fromRGBO(37, 36, 34, 1),
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40))),
              expandedHeight: 400,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                // title: Text("Zenith Lightning"),
                background: Hero(
                  tag: loadedProduct.id,
                  child: Image.network(
                    loadedProduct.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loadedProduct.title,
                              style: TextStyle(
                                fontSize: 30,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              loadedProduct.price.toString() + " Dhs",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          cart.addItem(loadedProduct.id, loadedProduct.price,
                              loadedProduct.title);
                          Scaffold.of(context).hideCurrentSnackBar();
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added item to cart!',
                              ),
                              duration: Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'UNDO',
                                onPressed: () {
                                  cart.removeSingleItem(loadedProduct.id);
                                },
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: Container(
                              width: 130,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(235, 94, 40, 1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: Center(
                                child: Text(
                                  "ADD TO CART",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              )),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      width: double.infinity,
                      child: Text(
                        loadedProduct.description,
                        textAlign: TextAlign.justify,
                        softWrap: true,
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 800,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
