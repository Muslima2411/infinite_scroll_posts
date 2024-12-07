import 'package:flutter/material.dart';
import 'package:infinite_scroll_posts/src/widgets/cart_item_widget.dart';
import 'package:infinite_scroll_posts/src/widgets/product_widget.dart';
import '../services/dio_service.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  ProductsPageState createState() => ProductsPageState();
}

class ProductsPageState extends State<ProductsPage> {
  final DioService _dioService = DioService();
  final List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = false;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchCartItems();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    const url = 'http://10.0.2.2:8081/products';

    try {
      final responseData = await _dioService.fetchProducts(url);
      setState(() {
        products.addAll(
          responseData.entries.map((e) => {
                "id": e.key,
                ...e.value,
              }),
        );
      });
    } catch (e) {
      setState(() {
        isError = true;
      });
      debugPrint("Error fetching products: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchCartItems() async {
    const url = 'http://10.0.2.2:8081/cart';

    try {
      final responseData = await _dioService.fetchCartItems(url);
      setState(() {
        cartItems = responseData;
      });
    } catch (e) {
      debugPrint("Error fetching cart items: $e");
    }
  }

  void _addToCart(Map<String, dynamic> product) async {
    try {
      final response = await _dioService.addItemToCart({
        'id': product['id'],
        'name': product['name'],
        'price': product['price'],
        'pieces': product['pieces'],
        'quantity': 1, // Initialize quantity to 1
        'images': product['images'],
        'description': product['description']
      });

      // Handle the server response
      if (response['status'] == 'success') {
        debugPrint("Item added to cart successfully on the server");

        // Add the product to cartItems with a quantity of 1
        setState(() {
          product['isInCart'] = true; // Mark product as added to cart
          product['quantity'] =
              1; // Ensure quantity is set to 1 when added to cart
          cartItems.add(product); // Add to cart
        });
      } else {
        debugPrint("Failed to add item to cart on the server");
      }
    } catch (e) {
      debugPrint("Error adding item to cart on server: $e");
    }
  }

  void _increaseQuantity(int index) async {
    setState(() {
      // Update quantity locally first
      cartItems[index]['quantity'] = cartItems[index]['quantity'] + 1;
    });

    final itemId = cartItems[index]['id'];
    final newQuantity = cartItems[index]['quantity'];

    try {
      final response =
          await _dioService.updateCartItemQuantity(itemId, newQuantity);
      if (response['status'] == 'success') {
        debugPrint("Quantity updated on server successfully");
      } else {
        debugPrint("Failed to update quantity on server");
      }
    } catch (e) {
      debugPrint("Error updating quantity on server: $e");
    }
  }

  void _decreaseQuantity(int index) async {
    setState(() {
      // Ensure quantity doesn't go below 1
      if (cartItems[index]['quantity'] > 1) {
        cartItems[index]['quantity'] = (cartItems[index]['quantity'] ?? 0) - 1;
      }
    });

    final itemId = cartItems[index]['id'];
    final newQuantity = cartItems[index]['quantity'];

    try {
      final response =
          await _dioService.updateCartItemQuantity(itemId, newQuantity);
      if (response['status'] == 'success') {
        debugPrint("Quantity updated on server successfully");
      } else {
        debugPrint("Failed to update quantity on server");
      }
    } catch (e) {
      debugPrint("Error updating quantity on server: $e");
    }
  }

  void _deleteItemFromCart(String id, int index) async {
    try {
      await _dioService.deleteItemFromCart(id);
      debugPrint("deleleted succesfully");
      cartItems.removeAt(index);
      print(cartItems);
      _fetchCartItems();
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete item from cart')),
      );
    }
  }

  void _showCart() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
              height: 600,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text(
                      "Cart Items:",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return CartItemWidget(
                            product: item,
                            onDelete: () {
                              _deleteItemFromCart(item["id"].toString(), index);
                              setState(() {}); // Trigger rebuild within modal
                            },
                            onIncrease: () {
                              _increaseQuantity(index);
                              setState(() {}); // Trigger rebuild within modal
                            },
                            onDecrease: () {
                              _decreaseQuantity(index);
                              setState(() {}); // Trigger rebuild within modal
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Total: \$${_calculateTotalSum()?.toStringAsFixed(2) ?? 0}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  double? _calculateTotalSum() {
    double total = 0;
    for (var item in cartItems) {
      total += item['price'] ?? 0 * item['quantity'] ?? 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Products',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showCart,
            icon: Stack(
              children: [
                const Icon(
                  size: 30,
                  Icons.shopping_cart,
                ),
                if (cartItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cartItems.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Failed to load data",
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _fetchProducts,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductWidget(
                      product: product,
                      isChosen: product['isInCart'] ?? false,
                      onAddToCart: () {
                        _addToCart(product);
                      },
                    );
                  },
                ),
    );
  }
}
