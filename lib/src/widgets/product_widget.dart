import 'package:flutter/material.dart';

class ProductWidget extends StatefulWidget {
  ProductWidget({
    super.key,
    required this.product,
    this.isChosen = false,
    required this.onAddToCart,
  });

  final Map<String, dynamic> product;
  bool isChosen;
  final VoidCallback onAddToCart;

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ListTile(
        leading: Image.asset(
          'assets/black_burger.png',
          height: 100,
          fit: BoxFit.cover,
        ),
        title: Text(
          widget.product['name'],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "\$${widget.product['price']}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text('Pieces: ${widget.product['pieces']}'),
            Text(widget.product['description']),
          ],
        ),
        trailing: IconButton(
          onPressed: () {
            setState(() {
              widget.isChosen = true;
            });
            widget.onAddToCart();
          },
          icon: Icon(
            widget.isChosen
                ? Icons.shopping_bag_rounded
                : Icons.shopping_bag_outlined,
          ),
        ),
      ),
    );
  }
}
