import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


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
      var product = Product(
          productId: (body["products"][i]["productId"] == null) ? "" : body["products"][i]["productId"],
          productNumber: (body["products"][i]["productNumbe"] == null) ? "" : body["products"][i]["productNumbe"],
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

      print(productArray[15]);
    }

    //print(body["products"][0]["productId"]);


    return [];
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Product {
  final String productId;
  final String productNumber;
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
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch Data Example'),
        ),
        body: Center(
          /*child: FutureBuilder<Product>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data!.productNameBold);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),*/
        ),
      ),
    );
  }
}


