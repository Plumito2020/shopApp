import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import './cart_screen.dart';
import '../providers/products.dart';

enum FilterOptions {
  Favorites,
  All,
}
enum Category {
  Electronic,
  Hardware,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;
  var _searchController = TextEditingController();

  @override
  void initState() {
    // Provider.of<Products>(context).fetchAndSetProducts(); // WON'T WORK!
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<Products>(context).fetchAndSetProducts();
    // });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40))),
        backgroundColor: Color.fromRGBO(64, 61, 57, 1),
        title: Text('Zenith Lightning'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            icon: Icon(
              Icons.more_vert,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // Search Bar

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Center(
                            child: Icon(
                              Icons.search,
                              color: Color.fromRGBO(37, 36, 34, 1),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 13),
                            child: Center(
                              child: TextFormField(
                                controller: _searchController,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) {},
                                keyboardType: TextInputType.text,
                                maxLines: 1,
                                decoration: InputDecoration(
                                  hintText: "Search",
                                  hoverColor: Theme.of(context).accentColor,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(30),
                                      ),
                                      borderSide: BorderSide.none),
                                ),
                                onChanged: (value) {
                                  if (value.isEmpty) {
                                    Provider.of<Products>(context)
                                        .fetchAndSetProducts();
                                  } else {
                                    Provider.of<Products>(context)
                                        .searchProduct(_searchController.text);
                                  }
                                },
                                // validator: (value) {},
                                // onSaved: (value) {},
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        PopupMenuButton(
                          onSelected: (Category selectedValue) {
                            if (selectedValue == Category.Electronic) {
                              setState(() {
                                _isLoading = true;
                              });
                              Provider.of<Products>(context)
                                  .fetchAndSetProductsByCategory("Electronic")
                                  .then((_) {
                                setState(() {
                                  _isLoading = false;
                                });
                              });
                            } else if (selectedValue == Category.Hardware) {
                              setState(() {
                                _isLoading = true;
                              });
                              Provider.of<Products>(context)
                                  .fetchAndSetProductsByCategory("Hardware")
                                  .then((_) {
                                setState(() {
                                  _isLoading = false;
                                });
                              });
                            } else {
                              setState(() {
                                _isLoading = true;
                              });
                              Provider.of<Products>(context)
                                  .fetchAndSetProducts()
                                  .then((_) {
                                setState(() {
                                  _isLoading = false;
                                });
                              });
                            }
                          },
                          icon: Icon(Icons.filter_list),
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              child: Text('Electronic'),
                              value: Category.Electronic,
                            ),
                            PopupMenuItem(
                              child: Text('Hardware'),
                              value: Category.Hardware,
                            ),
                            PopupMenuItem(
                              child: Text('All'),
                              value: Category.All,
                            ),
                          ],
                        ),
                        Text("Filters"),
                      ],
                    ),
                  ),
                ),
                // Grid products
                Expanded(
                  child: ProductsGrid(_showOnlyFavorites),
                ),
              ],
            ),
    );
  }
}
