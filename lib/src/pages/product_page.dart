import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:form_validation/src/models/product_model.dart';
import 'package:form_validation/src/providers/products_provider.dart';
import 'package:form_validation/src/utils/validator.dart' as utils;

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ProductsProvider productProvider = new ProductsProvider();

  ProductModel productModel = new ProductModel();
  bool _fetching = false;
  File photo;

  @override
  Widget build(BuildContext context) {
    final ProductModel productData = ModalRoute.of(context).settings.arguments;
    if (productData != null) {
      productModel = productData;
    }
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_size_select_actual),
            onPressed: _selectPhoto,
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: _takePhoto,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                _showPhoto(),
                _createName(),
                _createPrice(),
                _createAvailable(),
                _createButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createName() {
    return TextFormField(
      initialValue: productModel.title,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(labelText: 'Product'),
      validator: (value) {
        return (value.length < 3) ? 'Type the name of the product' : null;
      },
      onSaved: (value) => productModel.title = value,
    );
  }

  Widget _createPrice() {
    return TextFormField(
      initialValue: productModel.value.toString(),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: 'Price'),
      validator: (value) {
        return (utils.isNumeric(value)) ? null : 'Only numbers';
      },
      onSaved: (value) => productModel.value = double.parse(value),
    );
  }

  Widget _createButton() {
    return RaisedButton.icon(
      onPressed: (_fetching) ? null : _handleSubmit,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: Colors.deepPurple,
      textColor: Colors.white,
      label: Text('Save'),
      icon: Icon(Icons.save),
    );
  }

  _createAvailable() {
    return SwitchListTile(
      value: productModel.available,
      title: Text('Available'),
      activeColor: Colors.deepPurple,
      onChanged: (value) => setState(() {
        productModel.available = value;
      }),
    );
  }

  void _handleSubmit() async {
    if (!formKey.currentState.validate()) return;
    formKey.currentState.save();
    setState(() {
      _fetching = true;
    });
    if (photo != null) {
      productModel.imageUrl = await productProvider.uploadImage(photo);
    }
    if (productModel.id == null) {
      productProvider.createProduct(productModel);
    } else {
      productProvider.editProduct(productModel);
    }
    setState(() {
      _fetching = false;
    });
    showSnackbar('Product successful stored');
    Navigator.pop(context);
  }

  void showSnackbar(String message) {
    final snackbar = SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: 1500),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  Widget _showPhoto() {
    if (productModel.imageUrl != null) {
      return FadeInImage(
        image: NetworkImage(productModel.imageUrl),
        placeholder: AssetImage('assets/jar-loading.gif'),
        height: 300.0,
        fit: BoxFit.contain,
      );
    } else {
      return Image(
        image: AssetImage(photo?.path ?? 'assets/no-image.png'),
        height: 300.0,
        fit: BoxFit.cover,
      );
    }
  }

  void _selectPhoto() async {
    _processPhoto(ImageSource.gallery);
  }

  void _takePhoto() async {
    _processPhoto(ImageSource.camera);
  }

  void _processPhoto(ImageSource origin) async {
    final _picker = ImagePicker();

    final pickedFile = await _picker.getImage(
      source: origin,
    );

    photo = File(pickedFile.path);

    if (photo != null) {
      productModel.imageUrl = null;
    }

    setState(() {});
  }
}
