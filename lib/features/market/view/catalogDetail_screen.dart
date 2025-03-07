import 'package:alippepro_v1/features/market/services/api_service.dart';
import 'package:alippepro_v1/features/market/view/detail_screen.dart';
import 'package:flutter/material.dart';

class CatalogDetailScreen extends StatefulWidget {
  final id;
  final title;

  const CatalogDetailScreen({
    super.key,
    required this.id,
    required this.title,
  });
  @override
  _CatalogDetailScreenState createState() => _CatalogDetailScreenState();
}

class _CatalogDetailScreenState extends State<CatalogDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  var _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProductsByCategory(widget.id);
  }

  var products;
  void getProductsByCategory(id) async {
    try {
      setState(() {
        _isLoading = true;
      });

      var fetchedProducts = await APIService.getProductsByCategory(id);

      setState(() {
        products =
            fetchedProducts; // Update the state with the fetched products
        _isLoading = false;
      });
    } catch (e) {
      print("Ошибка: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            widget.title,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: _isLoading == false
            ? (products != null && products!.isNotEmpty)
                ? Column(
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Товар издев',
                            suffixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      // Filter and Sort Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.swap_vert),
                              onPressed: () {
                                // Sort functionality
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.filter_list),
                              onPressed: () {
                                // Filter functionality
                              },
                            ),
                          ],
                        ),
                      ),

                      // Product Grid
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: products.isNotEmpty ? products?.length : 1,
                          itemBuilder: (context, index) {
                            return _buildProductItem(products[index]);
                          },
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Text('Бул каталогдо азырынча товар жок'),
                  )
            : const Center(child: CircularProgressIndicator()));
  }

  Widget _buildProductItem(product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return ProductDetailScreen(
              parentId: product['parentId'],
              title: product['title'],
              price: product['price'],
              description: product['description'],
              category: product['category'],
              imagesUrl: product['imagesUrl'],
            );
          },
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                      product['imagesUrl'] != null
                          ? product['imagesUrl'][0]
                          : 'https://static.vecteezy.com/system/resources/thumbnails/022/059/000/small_2x/no-image-available-icon-vector.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'],
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product['price']} с',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.orange),
                      SizedBox(width: 4),
                      Text('4.7', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final image;
  const ProductCard({super.key, this.image});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    print(widget.image);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with Discount Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  widget.image,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.pink[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  // child: const Text(
                  //   '-46%',
                  //   style: TextStyle(color: Colors.white, fontSize: 12),
                  // ),
                ),
              ),
            ],
          ),

          // Product Details
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Мугалим чырпыкта...',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const Text('4.7'),
                    const Spacer(),
                    Text(
                      '796 с',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.pink[200],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '1546 с',
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Favorite Button
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.white),
              onPressed: () {
                // Favorite toggle functionality
              },
            ),
          ),
        ],
      ),
    );
  }
}
