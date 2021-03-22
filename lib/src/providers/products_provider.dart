import 'dart:convert';
import 'dart:io';

import 'package:form_validation/src/user_preferences/user_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:form_validation/src/models/product_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mime_type/mime_type.dart';

class ProductsProvider {
  final String _url = "${env['FIREBASE_DATABASE_BASE_URL']}";
  final _pref = new UserPreferences();

  Future<Map<String, dynamic>> createProduct(ProductModel product) async {
    final url = '$_url/products.json?auth=${_pref.token}';
    final response = await http.post(url, body: productModelToJson(product));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> editProduct(ProductModel product) async {
    final url = '$_url/products/${product.id}.json?auth=${_pref.token}';
    final response = await http.put(url, body: productModelToJson(product));
    return json.decode(response.body);
  }

  Future<List<ProductModel>> loadProducts() async {
    final url = '$_url/products.json?auth=${_pref.token}';
    final response = await http.get(url);
    final Map<String, dynamic> decodedData = json.decode(response.body);
    if (decodedData == null) return [];
    final List<ProductModel> products = new List();
    decodedData.forEach((id, product) {
      final tempProduct = ProductModel.fromJson(product);
      tempProduct.id = id;
      products.add(tempProduct);
    });
    return products;
  }

  Future<Null> deleteProduct(String id) async {
    final url = '$_url/products/$id.json?auth=${_pref.token}';
    final response = await http.delete(url);
    return json.decode(response.body);
  }

  Future<String> uploadImage(File image) async {
    final url = Uri.parse(
        "${env['CLOUDINARY_API_BASE_URL']}/${env['CLOUDINARY_CLOUD_NAME']}/image/upload?upload_preset=${env['CLOUDINARY_UPLOAD_PRESET']}");
    final mimeType = mime(image.path).split('/');
    final imageUploadRequest = http.MultipartRequest('POST', url);
    final file = await http.MultipartFile.fromPath('file', image.path,
        contentType: MediaType(mimeType[0], mimeType[1]));
    imageUploadRequest.files.add(file);
    final streamResponse = await imageUploadRequest.send();
    final response = await http.Response.fromStream(streamResponse);
    if (![200, 201].contains(response.statusCode)) return null;
    final responseData = json.decode(response.body);
    return responseData['secure_url'];
  }
}
