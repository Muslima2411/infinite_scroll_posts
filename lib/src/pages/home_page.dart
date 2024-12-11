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
  double total = 0;
  double tax = 0;
  double deliveryFee = 0;

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
      cartItems[index]["quantity"] += 1; // Update locally first
      total = _calculateTotalSum(); // Recalculate the total immediately
    });

    try {
      final response = await _dioService.updateCartItemQuantity(
        cartItems[index]["id"],
        cartItems[index]["quantity"],
      );

      if (response['status'] == 'success') {
        debugPrint("Quantity updated successfully on the server");
      } else {
        debugPrint("Failed to update quantity on server");
        // Revert to the previous state in case of failure
        setState(() {
          cartItems[index]["quantity"] -= 1;
          total = _calculateTotalSum(); // Recalculate total after reverting
        });
      }
    } catch (e) {
      debugPrint("Error increasing quantity: $e");
      // Revert to the previous state in case of an error
      setState(() {
        cartItems[index]["quantity"] -= 1;
        total = _calculateTotalSum(); // Recalculate total after reverting
      });
    }
  }

  void _decreaseQuantity(int index) async {
    if (cartItems[index]["quantity"] > 1) {
      // Optimistically update the UI before making the API call
      setState(() {
        cartItems[index]["quantity"] -= 1; // Decrease locally
        total = _calculateTotalSum(); // Recalculate total immediately
      });

      try {
        final response = await _dioService.updateCartItemQuantity(
          cartItems[index]["id"],
          cartItems[index]["quantity"],
        );

        if (response['status'] == 'success') {
          debugPrint("Quantity decreased successfully on the server");
        } else {
          debugPrint("Failed to decrease quantity on server");
          // Revert to the previous state if the update fails
          setState(() {
            cartItems[index]["quantity"] += 1; // Revert to previous quantity
            total =
                _calculateTotalSum(); // Recalculate the total after reverting
          });
        }
      } catch (e) {
        debugPrint("Error decreasing quantity: $e");
        // Revert to the previous state in case of an error
        setState(() {
          cartItems[index]["quantity"] += 1; // Revert to previous quantity
          total = _calculateTotalSum(); // Recalculate total after reverting
        });
      }
    }
  }

  void _deleteItemFromCart(String id, int index) async {
    try {
      await _dioService.deleteItemFromCart(id);

      setState(() {
        cartItems.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted successfully')),
      );
    } catch (error) {
      debugPrint("Error deleting item: $error");

      // Show an error message if the deletion fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete item from cart')),
      );
    }
  }

  void _deleteAllItems() async {
    try {
      await _dioService.deleteAllItemsFromCart();

      setState(() {
        cartItems.clear();
        total = 0;
        tax = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All items deleted from cart')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete all items from cart')),
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
                              setState(() {}); // Update UI
                            },
                            onIncrease: () {
                              _increaseQuantity(index);
                              setState(() {}); // Update UI and total
                            },
                            onDecrease: () {
                              _decreaseQuantity(index);
                              setState(() {}); // Update UI and total
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Total: \$${_calculateTotalSum().toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tax (7%): \$${(_calculateTotalSum() * 0.07).toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      "Delivery Fee: \$${_calculateDeliveryFee().toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    MaterialButton(
                      shape: const StadiumBorder(),
                      minWidth: double.infinity,
                      onPressed: () {
                        _deleteAllItems();
                        setState(() {});
                      },
                      color: Colors.green,
                      child: const Text(
                        "Order",
                      ),
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

  double _calculateDeliveryFee() {
    double total = _calculateTotalSum();
    return total > 60 ? 0 : 10;
  }

  double _calculateTotalSum() {
    double totalSum = 0;

    if (cartItems.isEmpty) {
      deliveryFee = 0;
      tax = 0;
      return totalSum;
    }

    for (var item in cartItems) {
      totalSum += (item["price"] ?? 0) * (item["quantity"] ?? 0);
    }
    tax = totalSum * 0.07;
    totalSum += tax;
    deliveryFee = totalSum > 60 ? 0 : 10;
    totalSum += deliveryFee;

    return totalSum;
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
