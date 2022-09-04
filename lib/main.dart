import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/utils/utils.dart';


const darkBlue = Color(0xff0077B6);


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
  var uri = Uri.parse('https://api-extern.systembolaget.se/sb-api-ecommerce/v1/productsearch/search?');

  final response = await http.get(uri, headers: {
      'Ocp-Apim-Subscription-Key': 'cfc702aed3094c86b92d6d4ff7a54c84'
    },
  );

  if (response.statusCode == 200) {

    var productArray = [];
    final body = jsonDecode(response.body);

    for (var i = 0; i < 30; i++) {

      Product product = Product(
          productId: (body["products"][i]["productId"] == null) ? 0 : int.parse(body["products"][i]["productId"]),
          productNumber: (body["products"][i]["productNumber"] == null) ? 0 : int.parse(body["products"][i]["productNumber"]),
          productNameBold: (body["products"][i]["productNameBold"] == null) ? "" : body["products"][i]["productNameBold"],
          productNameThin: (body["products"][i]["productNameThin"] == null) ? "" : body["products"][i]["productNameThin"],
          producerName: (body["products"][i]["producerName"] == null) ? "" : body["products"][i]["producerName"],
          alcoholPercentage: (body["products"][i]["alcoholPercentage"] == null) ? 0.0 : body["products"][i]["alcoholPercentage"],
          volume: (body["products"][i]["volume"] == null) ? 0.0 : body["products"][i]["volume"],
          price: (body["products"][i]["price"] == null) ? 0.0 : body["products"][i]["price"],
          country: (body["products"][i]["country"] == null) ? "" : body["products"][i]["country"],
          categoryLevel1: (body["products"][i]["categoryLevel1"] == null) ? "" : body["products"][i]["categoryLevel1"],
          categoryLevel2: (body["products"][i]["categoryLevel2"] == null) ? "" : body["products"][i]["categoryLevel2"],
          categoryLevel3: (body["products"][i]["categoryLevel3"] == null) ? "" : body["products"][i]["categoryLevel3"],
          categoryLevel4: (body["products"][i]["categoryLevel4"] == null) ? "" : body["products"][i]["categoryLevel4"],
          apk: (body["products"][i]["volume"] == null || body["products"][i]["alcoholPercentage"] == null || body["products"][i]["price"] == null) ? 0.0 : body["products"][i]["volume"] * body["products"][i]["alcoholPercentage"] / (body["products"][i]["price"] * 100),
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

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  final database = openDatabase(
    join(await getDatabasesPath(), 'product_database.db'),

    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE products(productId INTEGER PRIMARY KEY, productNumber INTEGER, productNameBold TEXT, productNameThin TEXT, producerName TEXT, alcoholPercentage DOUBLE, volume DOUBLE, price DOUBLE, country TEXT, categoryLevel1 TEXT, categoryLevel2 TEXT, categoryLevel3 TEXT, categoryLevel4 TEXT, apk DOUBLE)),',
      );
    },

    version: 1,
  );

  toProducts(List<Map<String, dynamic>> maps) {
    return List.generate(maps.length, (i) {
      return Product(
        productId: maps[i]['productId'],
        productNumber: maps[i]['productNumber'],
        productNameBold: maps[i]['producerNameBold'],
        productNameThin: maps[i]['producerNameThin'],
        producerName: maps[i]['producerName'],
        alcoholPercentage: maps[i]['alcoholPercentage'],
        volume: maps[i]['volume'],
        price: maps[i]['price'],
        country: maps[i]['country'],
        categoryLevel1: maps[i]['categoryLevel1'],
        categoryLevel2: maps[i]['categoryLevel2'],
        categoryLevel3: maps[i]['categoryLevel3'],
        categoryLevel4: maps[i]['categoryLevel4'],
        apk: maps[i]['apk'],
      );
    });
  }

  Future<void> insertProduct(Product product) async {
    final db = await database;

    await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  List productsArray = await fetchProducts();

  for (int i = 0; i < 30; i++) {
    insertProduct(productsArray[i]);
  }

  Future<List> getProductsSorted(String sortedParameter, bool descending) async{
    final db = await database;
    const  space = "";
    var direction = (descending) ? "DESC" : "ASC";

    final List<Map<String, dynamic>> maps = await db.query(
        'products',
        orderBy: sortedParameter + space + direction,
      limit: 30,
    );

    return toProducts(maps);
  }

  runApp(
      MaterialApp(
        title: 'APK',
        home: HomeScreen();
      ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: darkBlue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Naviga
            },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categories'),
              onTap: () {
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_basket),
              title: const Text('Shoping Lists'),
              onTap: () {
              },
            ),
        ]),
      ),
      appBar: AppBar(
        title: const Text('Home'),
      ),
    );
  }
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: darkBlue,
                ),
                child: Text('Drawer Header'),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pushNamed(context, '/');
                },
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Categories'),
                onTap: () {
                  Navigator.pushNamed(context, '/categories');
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_basket),
                title: const Text('Shoping Lists'),
                onTap: () {
                  Navigator.pushNamed(context, '/shopping_list');
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
        child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: darkBlue,
                ),
                child: Text('Drawer Header'),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pushNamed(context, '/');
                },
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Categories'),
                onTap: () {
                  Navigator.pushNamed(context, '/categories');
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_basket),
                title: const Text('Shoping Lists'),
                onTap: () {
                  Navigator.pushNamed(context, '/shopping_list');
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


