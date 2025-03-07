// import 'package:flutter/material.dart';
// import '../services/api_service.dart';

// class AdminScreen extends StatefulWidget {
//   @override
//   _AdminScreenState createState() => _AdminScreenState();
// }

// class _AdminScreenState extends State<AdminScreen> {
//   final _productFormKey = GlobalKey<FormState>();
//   final _storeFormKey = GlobalKey<FormState>();

//   // Поля для продукта
//   String _productName = '';
//   double _productPrice = 0.0;
//   String _productDescription = '';
//   String _productCategory = '';
//   int _productStock = 0;

//   // Поля для магазина
//   String _storeName = '';
//   String _storeLocation = '';

//   Future<void> _createProduct() async {
//     if (_productFormKey.currentState!.validate()) {
//       _productFormKey.currentState!.save();
//       final success = await ApiService({
//         'name': _productName,
//         'price': _productPrice,
//         'description': _productDescription,
//         'category': _productCategory,
//         'stock': _productStock,
//       });

//       if (success) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('Product created successfully!')));
//       } else {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('Failed to create product')));
//       }
//     }
//   }

//   Future<void> _createStore() async {
//     if (_storeFormKey.currentState!.validate()) {
//       _storeFormKey.currentState!.save();
//       final success = await ApiService.createStore({
//         'name': _storeName,
//         'location': _storeLocation,
//         'products': [], // Список продуктов по умолчанию пуст
//       });

//       if (success) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('Store created successfully!')));
//       } else {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('Failed to create store')));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Admin Panel')),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Форма для создания продукта
//             Form(
//               key: _productFormKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Create Product', style: TextStyle(fontSize: 18)),
//                   TextFormField(
//                     decoration: InputDecoration(labelText: 'Name'),
//                     onSaved: (value) => _productName = value!,
//                     validator: (value) => value!.isEmpty ? 'Name is required' : null,
//                   ),
//                   TextFormField(
//                     decoration: InputDecoration(labelText: 'Price'),
//                     keyboardType: TextInputType.number,
//                     onSaved: (value) => _productPrice = double.parse(value!),
//                     validator: (value) => value!.isEmpty ? 'Price is required' : null,
//                   ),
//                   TextFormField(
//                     decoration: InputDecoration(labelText: 'Description'),
//                     onSaved: (value) => _productDescription = value!,
//                     validator: (value) =>
//                         value!.isEmpty ? 'Description is required' : null,
//                   ),
//                   TextFormField(
//                     decoration: InputDecoration(labelText: 'Category'),
//                     onSaved: (value) => _productCategory = value!,
//                     validator: (value) => value!.isEmpty ? 'Category is required' : null,
//                   ),
//                   TextFormField(
//                     decoration: InputDecoration(labelText: 'Stock'),
//                     keyboardType: TextInputType.number,
//                     onSaved: (value) => _productStock = int.parse(value!),
//                     validator: (value) => value!.isEmpty ? 'Stock is required' : null,
//                   ),
//                   SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: _createProduct,
//                     child: Text('Create Product'),
//                   ),
//                 ],
//               ),
//             ),
//             Divider(height: 40),
//             // Форма для создания магазина
//             Form(
//               key: _storeFormKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Create Store', style: TextStyle(fontSize: 18)),
//                   TextFormField(
//                     decoration: InputDecoration(labelText: 'Store Name'),
//                     onSaved: (value) => _storeName = value!,
//                     validator: (value) => value!.isEmpty ? 'Store name is required' : null,
//                   ),
//                   TextFormField(
//                     decoration: InputDecoration(labelText: 'Location'),
//                     onSaved: (value) => _storeLocation = value!,
//                     validator: (value) =>
//                         value!.isEmpty ? 'Location is required' : null,
//                   ),
//                   SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: _createStore,
//                     child: Text('Create Store'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
