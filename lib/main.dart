import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/utils/utils.dart';
import 'package:alkohol_per_krona/components/body.dart';
import 'package:alkohol_per_krona/constants.dart';

List? productCache;

class Product {
  final int productId;
  final int productNumber;
  final String productNameBold;
  final String productNameThin;
  final String producerName;
  final double alcoholPercentage;
  final double volume;
  final double price;
  final String country;
  final String categoryLevel1;
  final String categoryLevel2;
  final String categoryLevel3;
  final String categoryLevel4;
  final double apk;

  const Product({
    required this.productId,
    required this.productNumber,
    required this.productNameBold,
    required this.productNameThin,
    required this.producerName,
    required this.alcoholPercentage,
    required this.volume,
    required this.price,
    required this.country,
    required this.categoryLevel1,
    required this.categoryLevel2,
    required this.categoryLevel3,
    required this.categoryLevel4,
    required this.apk,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productNumber': productNumber,
      'productNameBold': productNameBold,
      'productNameThin': productNameThin,
      'producerName': producerName,
      'alcoholPercentage': alcoholPercentage,
      'volume': volume,
      'price': price,
      'country': country,
      'categoryLevel1': categoryLevel1,
      'categoryLevel2': categoryLevel2,
      'categoryLevel3': categoryLevel3,
      'categoryLevel4': categoryLevel4,
      'apk': apk,
    };
  }

  @override
  String toString() {
    return 'Product{productI: $productId, productNumber: $productNumber, productNameBold: $productNameBold, productNameThin: $productNameThin, producerName: $producerName, alcoholPercentage: $alcoholPercentage, volume: $volume, price: $price, country: $country, categoryLevel1: $categoryLevel1, categoryLevel2: $categoryLevel2, categoryLevel3: $categoryLevel3, categoryLevel4: $categoryLevel4, apk: $apk}';
  }
}

Future<List> fetchProducts() async {
  var uri = Uri.parse(
      'https://api-extern.systembolaget.se/sb-api-ecommerce/v1/productsearch/search?');

  final response = await http.get(
    uri,
    headers: {'Ocp-Apim-Subscription-Key': 'cfc702aed3094c86b92d6d4ff7a54c84'},
  );

  if (response.statusCode == 200) {
    var productArray = [];
    final body = jsonDecode(response.body);

    for (var i = 0; i < 30; i++) {
      Product product = Product(
        productId: (body["products"][i]["productId"] == null)
            ? 0
            : int.parse(body["products"][i]["productId"]),
        productNumber: (body["products"][i]["productNumber"] == null)
            ? 0
            : int.parse(body["products"][i]["productNumber"]),
        productNameBold: (body["products"][i]["productNameBold"] == null)
            ? ""
            : body["products"][i]["productNameBold"],
        productNameThin: (body["products"][i]["productNameThin"] == null)
            ? ""
            : body["products"][i]["productNameThin"],
        producerName: (body["products"][i]["producerName"] == null)
            ? ""
            : body["products"][i]["producerName"],
        alcoholPercentage: (body["products"][i]["alcoholPercentage"] == null)
            ? 0.0
            : body["products"][i]["alcoholPercentage"],
        volume: (body["products"][i]["volume"] == null)
            ? 0.0
            : body["products"][i]["volume"],
        price: (body["products"][i]["price"] == null)
            ? 0.0
            : body["products"][i]["price"],
        country: (body["products"][i]["country"] == null)
            ? ""
            : body["products"][i]["country"],
        categoryLevel1: (body["products"][i]["categoryLevel1"] == null)
            ? ""
            : body["products"][i]["categoryLevel1"],
        categoryLevel2: (body["products"][i]["categoryLevel2"] == null)
            ? ""
            : body["products"][i]["categoryLevel2"],
        categoryLevel3: (body["products"][i]["categoryLevel3"] == null)
            ? ""
            : body["products"][i]["categoryLevel3"],
        categoryLevel4: (body["products"][i]["categoryLevel4"] == null)
            ? ""
            : body["products"][i]["categoryLevel4"],
        apk: (body["products"][i]["volume"] == null ||
                body["products"][i]["alcoholPercentage"] == null ||
                body["products"][i]["price"] == null)
            ? 0.0
            : body["products"][i]["volume"] *
                body["products"][i]["alcoholPercentage"] /
                (body["products"][i]["price"] * 100),
      );

      productArray.add(product);
    }

    return productArray;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

toProduct(Map<String, dynamic> map) {
  return Product(
    productId: map['productId'],
    productNumber: map['productNumber'],
    productNameBold: map['producerNameBold'],
    productNameThin: map['producerNameThin'],
    producerName: map['producerName'],
    alcoholPercentage: map['alcoholPercentage'],
    volume: map['volume'],
    price: map['price'],
    country: map['country'],
    categoryLevel1: map['categoryLevel1'],
    categoryLevel2: map['categoryLevel2'],
    categoryLevel3: map['categoryLevel3'],
    categoryLevel4: map['categoryLevel4'],
    apk: map['apk'],
  );
}

toProducts(List<Map<String, dynamic>> maps) {
  return List.generate(maps.length, (i) {
    return toProduct(maps[i]);
  });
}

Future<void> insertProduct(Product product, Future<Database> database) async {
  final db = await database;

  await db.insert(
    'products',
    product.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List> getProductsSorted(
    String sortedParameter, bool descending, Future<Database> database) async {
  final db = await database;
  const space = " ";
  var direction = (descending) ? "DESC" : "ASC";

  final List<Map<String, dynamic>> maps = await db.query(
    'products',
    orderBy: sortedParameter + space + direction,
    limit: 30,
  );

  return toProducts(maps);
}

Future<bool> doesDatabaseExist(Future<Database> database) async {
  final db = await database;

  final productList = await db.query('products', limit: 1);

  return productList.isNotEmpty;
}

Future<void> deleteAllProducts(Future<Database> database) async {
  final db = await database;

  await db.delete(
    'products',
  );
}

Future<void> setUpDatabase(Future<Database> database) async {
  List productsArray = await fetchProducts();

  for (int i = 0; i < 30; i++) {
    insertProduct(productsArray[i], database);
  }
}

Future<List> loadProductCache(Future<Database> database) async {
  return getProductsSorted("productId", false, database);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = openDatabase(
    join(await getDatabasesPath(), 'product_database.db'),
    onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE products(productId INTEGER PRIMARY KEY, productNumber INTEGER, productNameBold TEXT, productNameThin TEXT, producerName TEXT, alcoholPercentage DOUBLE, volume DOUBLE, price DOUBLE, country TEXT, categoryLevel1 TEXT, categoryLevel2 TEXT, categoryLevel3 TEXT, categoryLevel4 TEXT, apk DOUBLE)');
    },
    version: 1,
  );

  if (await doesDatabaseExist(database)) {
    productCache = await loadProductCache(database);
  } else {
    setUpDatabase(database);
    productCache = await loadProductCache(database);
  }

  runApp(App());
}

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: veryDarkBlue,
            ),
            padding: EdgeInsets.all(20),
            child: Text('Drawer Header'),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => App()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories'),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CategoriesScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_basket),
            title: const Text('Shoping Lists'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ShoppingListScreen()));
            },
          ),
        ]),
      ),
      appBar: buildAppBar(),
      body: Body(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: darkBlue,
      elevation: 0,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {},
        ),
        SizedBox(width: defaultPadding / 2)
      ],
    );
  }
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: veryDarkBlue,
            ),
            child: Text('Drawer Header'),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => App()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories'),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CategoriesScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_basket),
            title: const Text('Shoping Lists'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ShoppingListScreen()));
            },
          ),
        ]),
      ),
      appBar: AppBar(
        title: const Text('Categories'),
      ),
    );
  }
}

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: veryDarkBlue,
            ),
            child: Text('Drawer Header'),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => App()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories'),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CategoriesScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_basket),
            title: const Text('Shoping Lists'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ShoppingListScreen()));
            },
          ),
        ]),
      ),
      appBar: AppBar(
        title: const Text('Shopping List'),
      ),
    );
  }
}
