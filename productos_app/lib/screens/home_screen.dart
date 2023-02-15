import 'package:flutter/material.dart';
import 'package:productos_app/screens/screens.dart';
import 'package:productos_app/services/services.dart';
import 'package:productos_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';

class HomeScreen extends StatelessWidget {
   
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {

    final productsService = Provider.of<ProductService>(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    if(productsService.isLoading){
      return LoadingScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Productos'),
        ),
        leading: IconButton(
          icon: Icon(Icons.logout_outlined),
          onPressed: () {
            
            authService.logout();
            Navigator.pushReplacementNamed(context, 'login');

          },
        ),
      ),

      body: ListView.builder(
        itemCount: productsService.products.length,
        itemBuilder: (BuildContext context, int index) => GestureDetector(
          onTap: (){

            productsService.selectedProduct = productsService.products[index].copy();
            Navigator.pushNamed(context, 'products');

          },
          child: ProductCard(
            product: productsService.products[index],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){

          productsService.selectedProduct = new Product(
            available: false, 
            name: '', 
            price: 0
          );
          Navigator.pushNamed(context, 'products');
        },
      ),
    );
  }
}