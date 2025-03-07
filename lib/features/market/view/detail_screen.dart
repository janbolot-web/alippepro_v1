import 'package:alippepro_v1/features/market/services/api_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // Для использования шрифтов

class ProductDetailScreen extends StatefulWidget {
  final title;
  final price;
  final description;
  final category;
  final imagesUrl;
  final parentId;

  const ProductDetailScreen({
    super.key,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.imagesUrl,
    required this.parentId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _current = 0;
  List images = [];
  var store;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    images = widget.imagesUrl;
    fetchStoreById();
  }

  Future fetchStoreById() async {
    try {
      store = await APIService.getStoreById(widget.parentId);
      print(store);
    } catch (e) {
      setState(() {
        store = [];
      });
    }
  }

  void _onInstagramTap() async {
    // Получаем имя пользователя Instagram
    final String instagramUsername = store['author'][0]['instagram'];
    final String instagramUrl = "https://www.instagram.com/$instagramUsername";

    // Заданное сообщение
    const String message =
        "Саламатсызбы, мен „Alippe Ai” тиркемесинен жазып жатам☺️\nСиз киргизген товар боюнча билейин дегем😇";

    // Instagram не поддерживает передачу prefilled сообщения через URL,
    // поэтому можно скопировать текст в буфер обмена и уведомить пользователя.
    Clipboard.setData(const ClipboardData(text: message));
    print("Сообщение скопировано в буфер обмена: $message");

    if (await canLaunch(instagramUrl)) {
      await launch(instagramUrl);
    } else {
      throw 'Could not launch $instagramUrl';
    }
  }

  void _onWhatsAppTap() async {
    // Получаем номер WhatsApp
    final String whatsappNumber = store['author'][0]['whatsapp'];
    // Заданное сообщение
    const String message =
        "Саламатсызбы, мен „Alippe Ai” тиркемесинен жазып жатам☺️\nСиз киргизген товар боюнча билейин дегем😇";
    // Формируем URL для WhatsApp с prefilled сообщением
    final String whatsappUrl =
        "https://wa.me/+996$whatsappNumber?text=${Uri.encodeFull(message)}";

    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      throw 'Could not launch $whatsappUrl';
    }
  }

  void _onPhoneTap() async {
    String phone = "tel:${store['author'][0]['phoneNumber']}";

    if (await canLaunch(phone)) {
      await launch(phone);
    } else {
      throw 'Could not launch $phone';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F0F0),
      appBar: AppBar(
        title: Text(
          widget.title.toString(),
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff1B434D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Изображение товара
            GestureDetector(
              onTap: _openFullScreenCarousel,
              child: CarouselSlider(
                carouselController: _controller,
                options: CarouselOptions(
                    height: 346.0,
                    viewportFraction: .8,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: false,
                    autoPlay: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    }),
                items: images.map((imageUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: 7.0,
                    height: 7.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (_current == entry.key
                            ? const Color(0xff005558)
                            : const Color(0xffD9D9D9))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Цена и скидка
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.price} c', // Текущая цена
                            style: GoogleFonts.rubik(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: const Color(0xffAC046A),
                            ),
                          ),
                          // Text(
                          //   '1546 с', // Старая цена
                          //   style: GoogleFonts.openSans(
                          //     decoration: TextDecoration.lineThrough,
                          //     color: Colors.grey,
                          //   ),
                          // ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        // child: Text(
                        //   '-46%',
                        //   style: GoogleFonts.openSans(
                        //     color: Colors.white,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Название товара
                  Text(
                    widget.title.toString(),
                    style: GoogleFonts.rubik(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    widget.category[0]['description'].toString(),
                    style: GoogleFonts.rubik(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Описание товара
                  Text(
                    'Cүрөттөмө: ',
                    style: GoogleFonts.rubik(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  // Описание товара
                  Text(
                    widget.description.toString(),
                    style: GoogleFonts.rubik(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Кнопки для социальных сетей
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildButton(
                          color: const Color(0xFFAC046A),
                          icon: FontAwesomeIcons.instagram,
                          text: 'Instagram',
                          onTap: _onInstagramTap,
                        ),
                        const SizedBox(height: 16),
                        _buildButton(
                          color: const Color(0xFF005558),
                          icon: FontAwesomeIcons.whatsapp,
                          text: 'WhatsApp',
                          onTap: _onWhatsAppTap,
                        ),
                        const SizedBox(height: 16),
                        _buildButton(
                          color: const Color(0xFF005558),
                          icon: Icons.phone,
                          text: 'Позвонить',
                          onTap: _onPhoneTap,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required Color color,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullScreenCarousel() {
    int currentFull = _current;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: Column(
                children: [
                  Expanded(
                    child: CarouselSlider(
                      carouselController: _controller,
                      options: CarouselOptions(
                        initialPage: currentFull,
                        height: double.infinity,
                        enlargeCenterPage: false,
                        enableInfiniteScroll: false,
                        autoPlay: false,
                        viewportFraction: 1.0,
                        onPageChanged: (index, reason) {
                          setStateDialog(() {
                            currentFull = index;
                          });
                        },
                      ),
                      items: images.map((imageUrl) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(imageUrl),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: images.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () {
                          _controller.animateToPage(
                              entry.key); // Перелистываем слайдер

                          setState(() {
                            currentFull =
                                entry.key; // Синхронизируем с основным экраном
                          });
                        },
                        child: Container(
                          width: 7.0,
                          height: 7.0,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (currentFull == entry.key
                                ? const Color(0xff005558)
                                : const Color(0xffD9D9D9)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
