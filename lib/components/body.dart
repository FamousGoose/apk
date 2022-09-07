import 'package:alkohol_per_krona/main.dart';
import 'package:flutter/material.dart';
import 'package:alkohol_per_krona/constants.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
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
  }
}

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
