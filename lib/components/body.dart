import 'package:apk_test/main.dart';
import 'package:flutter/material.dart';
import 'package:apk_test/constants.dart';
import 'dart:developer' as developer;

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return SizedBox(
      child: FutureBuilder<List<Product>?>(
        future: productCache, // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            return GridView.count(
              // crossAxisCount is the number of columns
              crossAxisCount: 2,
              // This creates two columns with two items in each column
              children: List.generate(snapshot.data!.length, (index) {
                return ItemCard(product: snapshot.data?[index]);
              }),
            );
          } else if (snapshot.hasError) {
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              ),
            ];
          } else {
            children = const <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Awaiting result...'),
              ),
            ];
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          );
        },
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final Product product;
  const ItemCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5)),
        Container(
          child: Expanded(
            child: (product.imageUrl != "")
                ? Image.network(product.imageUrl, fit: BoxFit.contain)
                : Image.asset(
              "assets/product_images/placeholder-wine-bottle.png",
              fit: BoxFit.contain,
            ), //
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
          child: Text(product.productNameBold,
              textAlign: TextAlign.center,
              style: const TextStyle(color: textColor)),
        ),
        Text(
          "${product.price} kr",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}