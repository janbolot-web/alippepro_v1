import 'package:alippepro_v1/features/market/services/api_service.dart';
import 'package:alippepro_v1/features/market/view/detail_screen.dart';
import 'package:alippepro_v1/features/market/widgets/category_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List products = [];
  List categories = [];

  var _isLoading = false;
  TextEditingController searchController = TextEditingController();

  @override
  initState() {
    super.initState();
    fetchProducts('');
    fetchCategories();
  }

  void fetchProducts(query) async {
    try {
      setState(() {
        _isLoading = true;
      });
      var fetchedProducts = await APIService.getAllProducts(query);
      print("Количество продуктов: ${fetchedProducts.length}");

      setState(() {
        products =
            fetchedProducts; // Update the state with the fetched products
        _isLoading = false;
      });
    } catch (e) {
      print("Ошибка: $e");
    }
  }

  void fetchCategories() async {
    try {
      // setState(() {
      //   _isLoading = true;
      // });
      var fetchedCategories = await APIService.getAllCategories();
      print("Количество продуктов: ${fetchedCategories.length}");

      setState(() {
        categories =
            fetchedCategories; // Update the state with the fetched products
        // _isLoading = false;
      });
    } catch (e) {
      print("Ошибка: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    print('categories $categories');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alippe Market',
          style: GoogleFonts.rubik(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xff1B434D)),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xffF0F0F0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: TextField(
                onChanged: (query) {
                  fetchProducts(query);
                },
                controller: searchController,
                decoration: InputDecoration(
                  hintStyle: GoogleFonts.rubik(
                      fontWeight: FontWeight.w300,
                      color: const Color.fromARGB(119, 27, 67, 77)),
                  hintText: 'Товар издөө',
                  focusColor: const Color(0xff1B434D),
                  hoverColor: const Color(0xff1B434D),
                  suffixIcon:
                      const Image(image: AssetImage('assets/img/search.png')),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Каталог',
                style: GoogleFonts.rubik(
                    color: const Color(0xff1B434D),
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 130,
              child: _isLoading
                  ? _buildLoadingSkeleton()
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        const SizedBox(width: 16),
                        ...categories.map((category) => Padding(
                              padding: const EdgeInsets.only(right: 25),
                              child: CategoryItem(
                                id: category['_id'],
                                title: category['description'],
                                imagePath: category['image'],
                              ),
                            )),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Сунуштайбыз',
                style: GoogleFonts.rubik(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff1B434D),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _isLoading == true
                ? _buildLoadingProductItem()
                : products.isEmpty
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height - 600,
                        child: Center(
                            child: Text(
                          'Сиз издеген товар табылган жок!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                Colors.grey.shade600, // Темно-серый цвет текста
                          ),
                          textAlign: TextAlign.center,
                        )),
                      )
                    : GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return ProductDetailScreen(
                                    parentId: products[index]['parentId'],
                                    title: products[index]['title'],
                                    price: products[index]['price'],
                                    description: products[index]['description'],
                                    category: products[index]['category'],
                                    imagesUrl: products[index]['imagesUrl'],
                                  );
                                },
                              ));
                            },
                            child: _buildProductItem({
                              'title': products[index]['title'],
                              'price': products[index]['price'],
                              'description': products[index]['description'],
                              'category': products[index]['category'],
                              'imagesUrl': products[index]['imagesUrl'],
                            }),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 25, left: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 60,
                  height: 10,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingProductItem() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 0,
        childAspectRatio: 1,
      ),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(String title, String imagePath) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                image: DecorationImage(
                  image: NetworkImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(width: 25),
      ],
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    print(product);
    return Container(
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
    );
  }
}
