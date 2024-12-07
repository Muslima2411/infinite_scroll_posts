import 'dart:developer';

import 'package:dio/dio.dart';

class DioService {
  final Dio _dio;

  DioService() : _dio = Dio();

  Future<Map<String, dynamic>> fetchProducts(String url) async {
    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Failed to fetch products");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchCartItems(String url) async {
    try {
      final response = await _dio.get(url);
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception("Error fetching cart items: $e");
    }
  }

  Future<Map<String, dynamic>> addItemToCart(Map<String, dynamic> item) async {
    try {
      final response = await _dio.post(
        'http://10.0.2.2:8081/addCart', // Endpoint for adding items to cart
        data: item, // Send item data in the request body
      );
      return response.data; // Return the server response
    } catch (e) {
      throw Exception("Error adding item to cart: $e");
    }
  }

  Future<Map<String, dynamic>> updateCartItemQuantity(
      String itemId, int newQuantity) async {
    log(itemId);
    log(newQuantity.toString());

    try {
      final response = await _dio.put(
        'http://10.0.2.2:8081/updateCart/$itemId',
        data: {
          'quantity': newQuantity,
        },
      );

      return response.data;
    } catch (e) {
      throw Exception('Error updating cart item: $e');
    }
  }

  // New method to delete an item from the cart
  Future<void> deleteItemFromCart(String itemId) async {
    try {
      final response = await _dio.delete(
        'http://10.0.2.2:8081/removeCart/$itemId',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete item');
      }
    } catch (e) {
      throw Exception('Error deleting item from cart: $e');
    }
  }
}
