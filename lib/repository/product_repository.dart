import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product.dart';

class ProductRepository {
  final String url = 'https://port-0-luckydepot-m6q0n8sc55b3c20e.sel4.cloudtype.app';

  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$url/product/'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['result'] != null && responseData['result'] is List) {
          final List<dynamic> data = responseData['result'];
          return data.map((json) => Product.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  deleteProduct(int productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$url/product/$productId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 새 상품 추가
  addProduct(String name, String price, String image, String quantity,
    String categoryId, String imageBytes) async {
  try {
    // 1. 이미지 업로드
    var imageRequest = http.MultipartRequest(
      'POST', 
      Uri.parse('$url/product/image/')
    );
    imageRequest.files.add(
      http.MultipartFile.fromBytes(
        'file',
        base64Decode(imageBytes),
        filename: image
      )
    );
    
    var imageResponse = await imageRequest.send();
    
    if (imageResponse.statusCode == 200) {
      // 2. 상품 정보 저장
      final response = await http.post(
        Uri.parse('$url/product/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'price': int.parse(price),
          'image': image,
          'quantity': int.parse(quantity),
          'category_id': int.parse(categoryId)
        }),
      );
      
      return response.statusCode == 201;
    }
    return false;
  } catch (e) {
    return false;
  }
}


  // 수량 업데이트
  Future<bool> updateQuantity(int productId, int additionalQuantity) async {
    try {
      final response = await http.put(
        Uri.parse('$url/product/$productId?quantity=$additionalQuantity'), 
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }


  // 카테고리 추가
  addNewCategory(String categoryName) async {
    try {
      final response = await http.post(
        Uri.parse('$url/category/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': categoryName
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // 카테고리 목록 조회
  Future<List<String>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$url/category/'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
        if (responseData['result'] != null && responseData['result'] is List) {
          final List<dynamic> data = responseData['result'];
          return data.map((item) => item['name'].toString()).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
