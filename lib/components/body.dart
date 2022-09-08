import 'package:alkohol_per_krona/main.dart';
import 'package:flutter/material.dart';
import 'package:alkohol_per_krona/constants.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.headline2!,
      textAlign: TextAlign.center,
      child: FutureBuilder<List<Product>?>(
        future: productCache, // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            children = <Widget>[
                  ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ItemCard(product: snapshot.data?[index]);
                    },
                  ),
            ];
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

/*
Column(
children: <Widget>[
Expanded(
child: GridView.builder(
itemCount: 30,
gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 2,
mainAxisSpacing: defaultPadding,
crossAxisSpacing: defaultPadding,
childAspectRatio: 0.75,
),
itemBuilder: (context, index) =>
ItemCard(product: productCache![index]),
),
),
],
);
*/

class ItemCard extends StatelessWidget {
  final Product product;
  const ItemCard({
    Key? key, required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(defaultPadding),
          //height: 180,
          //width: 160,
          decoration: BoxDecoration(
            color: blue,
            borderRadius: BorderRadius.circular(16),
          ),
          //child; Image.asset()
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: defaultPadding / 4),
          child: Text(product.productNameBold, style: TextStyle(color: textColor)),
        ),
        Text(
          "${product.price} kr",
          style: TextStyle(fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}
