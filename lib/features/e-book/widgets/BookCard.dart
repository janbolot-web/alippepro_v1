import 'package:alippepro_v1/features/e-book/view/book_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookGridCard extends StatefulWidget {
  final String title;
  final String href;
  final String author;
  final String bgImg;
  final String id;
  final bool isOwned;
  final VoidCallback onBookmarkToggle; // Добавьте этот параметр

  const BookGridCard({
    super.key,
    required this.title,
    required this.href,
    required this.author,
    required this.bgImg,
    required this.id,
    required this.isOwned,
    required this.onBookmarkToggle, // Инициализация
  });

  @override
  State<BookGridCard> createState() => _BookGridCardState();
}

class _BookGridCardState extends State<BookGridCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BookScreen(
                        fileName: widget.href,
                        title: widget.title,
                        url:
                            'https://drive.google.com/uc?export=download&id=${widget.href}')),
              )
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                elevation: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    // Если bgImg не пустое, используем изображение, иначе градиент
                    image: widget.bgImg.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(widget.bgImg),
                            fit: BoxFit.cover,
                          )
                        : null,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff22797C), // Начальный цвет
                        Color(0xff003638), // Конечный цвет
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: widget.bgImg.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.rubik(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              overflow: TextOverflow
                                  .ellipsis, // Обрезка длинного текста
                              maxLines: 2, // Ограничение на количество строк
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.author,
                              style: GoogleFonts.rubik(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white),
                              overflow: TextOverflow
                                  .ellipsis, // Обрезка длинного текста
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '275 бет',
                style:
                    GoogleFonts.rubik(color: const Color(0xff888D8C), fontSize: 10),
              ),
              GestureDetector(
                onTap: () {
                  widget.onBookmarkToggle(); // Вызываем колбек
                },
                child: Icon(
                  widget.isOwned
                      ? Icons.bookmark
                      : Icons.bookmark_border_outlined,
                  color: const Color(0xff005558),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
