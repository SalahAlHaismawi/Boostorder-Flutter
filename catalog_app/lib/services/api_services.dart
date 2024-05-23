import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'https://mangomart-autocount.myboostorder.com/wp-json/wc/v1/products';
  static const String username = 'ck_2682b35c4d9a8b6b6effac126ac552e0bfb315a0';
  static const String password = 'cs_cab8c9a729dfb49c50ce801a9ea41b577c00ad71';

  Future<List<Product>> fetchProducts(int page) async {
    final response = await _fetchProducts(page);

    if (response.statusCode != 200) {
      throw Exception('Failed to load products');
    }

    return compute(_parseProducts, response.body);
  }

  Future<http.Response> _get(String url) async {
    final headers = {
      'Authorization': 'Basic ' + base64Encode(utf8.encode('$username:$password')),
    };
    return await http.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> _fetchProducts(int page) async {
    final url = '$baseUrl?page=$page';
    return await _get(url);
  }

  List<Product> _parseProducts(String responseBody) {
    List<dynamic> data = json.decode(responseBody);
    return data.map((json) => Product.fromJson(json)).toList();
  }
}
