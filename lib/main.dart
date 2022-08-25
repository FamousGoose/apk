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
    // If the server did return a 200 OK response,
    // then parse the JSON.
    /*var productArray = new List(30);

    for (var i = 0; i < 30; i++) {
      productArray.add(response.body)
    }*/

    print("Hello World!");
    print(response.body.runtimeType);


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
  final Float alcoholPercentage;
  final Float volume;
  final Float price;
  final String country;
  final String categoryLevel1;
  final String categoryLevel2;
  final String categoryLevel3;
  final String categoryLevel4;
  final Float apk;

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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'],
      productNumber: json['productNumber'],
      productNameBold: json['productNameBold'],
      productNameThin: json['productNameThin'],
      producerName: json['producerName'],
      alcoholPercentage: json['alcoholPercentage'],
      volume: json['volume'],
      price: json['price'],
      country: json['country'],
      categoryLevel1: json['categoryLevel1'],
      categoryLevel2: json['categoryLevel2'],
      categoryLevel3: json['categoryLevel3'],
      categoryLevel4: json['categoryLevel4'],
      apk: json['volume'] * json['alcoholPercentage'] / (json['price'] * 100),
    );
  }
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


