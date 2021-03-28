import 'dart:io';
import 'package:rxdart/subjects.dart';

import 'package:form_validation/src/providers/products_provider.dart';
import 'package:form_validation/src/models/product_model.dart';

class ProductsBloc {
  final _productsController = new BehaviorSubject<List<ProductModel>>();
  final _loadingController = new BehaviorSubject<bool>();

  final _productsProvider = new ProductsProvider();

  Stream<List<ProductModel>> get productsStream => _productsController.stream;
  Stream<bool> get loading => _loadingController.stream;

  void loadProducts() async {
    final products = await _productsProvider.loadProducts();
    _productsController.sink.add(products);
  }

  void addProduct(ProductModel product) async {
    _loadingController.sink.add(true);
    await _productsProvider.createProduct(product);
    _loadingController.sink.add(false);
  }

  Future<String> uploadPhoto(File photo) async {
    _loadingController.sink.add(true);
    final photoURL = await _productsProvider.uploadImage(photo);
    _loadingController.sink.add(false);
    return photoURL;
  }

  void editProduct(ProductModel product) async {
    _loadingController.sink.add(true);
    await _productsProvider.editProduct(product);
    _loadingController.sink.add(false);
  }

  void deleteProduct(String id) async {
    await _productsProvider.deleteProduct(id);
  }

  dispose() {
    _productsController.close();
    _loadingController.close();
  }
}
