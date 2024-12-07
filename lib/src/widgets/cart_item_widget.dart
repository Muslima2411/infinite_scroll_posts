import 'package:flutter/material.dart';
import 'package:infinite_scroll_posts/src/services/dio_service.dart';

class CartItemWidget extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onDelete;

  const CartItemWidget({
    super.key,
    required this.product,
    required this.onIncrease,
    required this.onDecrease,
    required this.onDelete,
  });

  @override
  CartItemWidgetState createState() => CartItemWidgetState();
}

class CartItemWidgetState extends State<CartItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
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
                fontSize: 20,
                fontWeight: FontWeight.w500,
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
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: widget.onDecrease,
                ),
                Text(
                  widget.product['quantity'].toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: widget.onIncrease,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(
              Icons.cancel,
              color: Colors.red,
            ),
            onPressed: widget.onDelete, // Call the delete function
          ),
        ),
      ],
    );
  }
}
