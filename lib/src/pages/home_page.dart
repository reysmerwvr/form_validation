import 'package:flutter/material.dart';
import 'package:form_validation/src/bloc/products_bloc.dart';
import 'package:form_validation/src/bloc/provider.dart';
import 'package:form_validation/src/models/product_model.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productsBloc = Provider.productsBloc(context);
    productsBloc.loadProducts();

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: _createList(productsBloc),
      floatingActionButton: _createButton(context),
    );
  }

  Widget _createButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, 'product'),
      backgroundColor: Colors.deepPurple,
      child: Icon(Icons.add),
    );
  }

  Widget _createList(ProductsBloc productsBloc) {
    return StreamBuilder(
      stream: productsBloc.productsStream,
      builder:
          (BuildContext context, AsyncSnapshot<List<ProductModel>> snapshot) {
        if (snapshot.hasData) {
          final products = snapshot.data;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) =>
                _createItem(context, productsBloc, products[index]),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _createItem(
      BuildContext context, ProductsBloc productsBloc, ProductModel product) {
    return Dismissible(
        key: UniqueKey(),
        background: Container(
          color: Colors.red,
        ),
        onDismissed: (direction) => productsBloc.deleteProduct(product.id),
        child: Card(
          child: Column(
            children: <Widget>[
              (product.imageUrl == null)
                  ? Image(
                      image: AssetImage('assets/no-image.png'),
                    )
                  : FadeInImage(
                      placeholder: AssetImage('assets/jar-loading.gif'),
                      image: NetworkImage(product.imageUrl),
                      height: 300.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
              ListTile(
                title: Text('${product.title} - ${product.value}'),
                subtitle: Text(product.id),
                onTap: () => Navigator.pushNamed(
                  context,
                  'product',
                  arguments: product,
                ),
              ),
            ],
          ),
        ));
  }
}
