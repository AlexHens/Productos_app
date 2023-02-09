

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:productos_app/models/models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductService extends ChangeNotifier{

  final String _baseUrl = 'enlace a bd realtime de flutter';
  final List<Product> products = [];
  bool isLoading = true;
  late Product selectedProduct;
  bool isSaving = false;
  File? newPictureFile;
  
  
  ProductService(){
    this.loadProducts();
  }

  Future<List<Product>> loadProducts() async{

    this.isLoading = true;
    notifyListeners();

    final url = Uri.https(_baseUrl, 'Products.json');
    final resp = await http.get(url);

    final Map<String, dynamic> productsMap = json.decode(resp.body);

    productsMap.forEach((key, value) {
      
      final temProduct = Product.fromMap(value);
      temProduct.id = key;
      this.products.add(temProduct);

    });

    this.isLoading = false;
    notifyListeners();

    return this.products;
  }

  Future saveOrCreateProduct(Product product) async{

    isSaving = true;
    notifyListeners();

    if(product.id == null){
      
      await this.createProduct(product);
    } else{

      await this.updateProduct(product);
    }

    isSaving = false;
    notifyListeners();

  }

  Future<String> updateProduct(Product product) async{
  
    final url = Uri.https(_baseUrl, 'Products/${product.id}.json');
    final resp = await http.put(url, body: product.toJson());
    final decodedData = resp.body;

    // Actualizar listado de productos
    final index = this.products.indexWhere((element) => element.id == product.id);
    this.products[index] = product;

    return product.id!;
  }

  Future<String> createProduct(Product product) async{
  
    final url = Uri.https(_baseUrl, 'Products.json');
    final resp = await http.post(url, body: product.toJson());
    final decodedData = json.decode(resp.body);
    
    product.id = decodedData['name'];
    
    this.products.add(product);

    return product.id!;
  }

  void updateSelectedProductImage(String path){

    this.selectedProduct.picture = path;
    this.newPictureFile = File.fromUri(Uri(path: path));

    notifyListeners();

  }

  Future<String?>  uploadImage() async{

    if(this.newPictureFile == null){
      return null;
    }

    this.isSaving = true;
    notifyListeners();

    final url = Uri.parse('http a cloudinary con clave secreta');

    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file = await http.MultipartFile.fromPath('file', newPictureFile!.path);

    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if(resp.statusCode != 200 && resp.statusCode != 201){
      print('Algo salió mal');
      print(resp.body);
      return null;
    }

    this.newPictureFile = null;
    
    final decodedData = json.decode(resp.body);
    
    return decodedData['secure_url'];

  }

}