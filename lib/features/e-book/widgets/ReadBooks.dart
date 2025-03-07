import 'package:alippepro_v1/features/e-book/widgets/BookCard.dart';
import 'package:alippepro_v1/models/book.dart';
import 'package:alippepro_v1/services/book_controller.dart';
import 'package:flutter/material.dart';

class ReadBooks extends StatefulWidget {
  final futureBooks;
  const ReadBooks({super.key, required this.futureBooks});

  @override
  State<ReadBooks> createState() => _ReadBooksState();
}

class _ReadBooksState extends State<ReadBooks> {
  List<String> userBooksIds = []; // Список ID книг пользователя

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> loadUserBooks() async {
    // Предположим, что fetchUserBooks возвращает список книг пользователя
    final List<Book> userBooks = await fetchMyBooks();
    setState(() {
      // Получаем ID книг и сохраняем их
      userBooksIds = userBooks.map((book) => book.id).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          // Container(
          //   padding: EdgeInsets.only(top: 13, left: 40, bottom: 25),
          //   color: Colors.white,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text(
          //         'Окуп жаткан китептер',
          //         style: GoogleFonts.rubik(
          //           fontSize: 14,
          //           color: Color(0xff005558),
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //       const SizedBox(height: 16),
          //       FutureBuilder<List<Book>>(
          //         future: futureBooks,
          //         builder: (context, snapshot) {
          //           if (snapshot.connectionState == ConnectionState.waiting) {
          //             return Center(child: CircularProgressIndicator());
          //           } else if (snapshot.hasError) {
          //             return Center(child: Text('Ошибка: ${snapshot.error}'));
          //           } else {
          //             final books = snapshot.data!;
          //             return SingleChildScrollView(
          //               scrollDirection: Axis
          //                   .horizontal, // Устанавливаем горизонтальный скролл
          //               child: Row(
          //                 children: books.map((book) {
          //                   return GestureDetector(
          //                     onTap: () => {
          //                       Navigator.push(
          //                         context,
          //                         MaterialPageRoute(
          //                             builder: (context) => BookScreen(
          //                                 fileName: book
          //                                     .href, // Название файла для сохранения
          //                                 title: book.title,
          //                                 url:
          //                                     'https://drive.google.com/uc?export=download&id=${book.href}')),
          //                       )
          //                     },
          //                     child: Container(
          //                       margin: EdgeInsets.only(right: 24),
          //                       child: Column(
          //                         children: [
          //                           Container(
          //                             width: 100,
          //                             height: 130,
          //                             decoration: BoxDecoration(
          //                               image: DecorationImage(
          //                                 image: NetworkImage(
          //                                     'https://d2wzqffx6hjwip.cloudfront.net/spree/images/attachments/000/062/605/original/9781922790736.jpg'),
          //                                 fit: BoxFit.cover,
          //                               ),
          //                               borderRadius: BorderRadius.circular(8),
          //                             ),
          //                           ),
          //                           const SizedBox(height: 4),
          //                           // LinearProgressIndicator(
          //                           //   value: progress,
          //                           //   color: Colors.teal,
          //                           //   backgroundColor: Colors.grey[300],
          //                           // ),
          //                         ],
          //                       ),
          //                     ),
          //                   );
          //                 }).toList(),
          //               ),
          //             );
          //           }
          //         },
          //       ),

          //     ],
          //   ),
          // ),
          const SizedBox(height: 22),
          // Блок других книг

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: FutureBuilder<List<Book>>(
              future: widget.futureBooks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                } else {
                  final books = snapshot.data!;
                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 45,
                    mainAxisSpacing: 24,
                    physics: const NeverScrollableScrollPhysics(),
                    children: books.map((book) {
                      bool isOwnedByUser = userBooksIds.contains(book.id);
                      return BookGridCard(
                        id: book.id,
                        title: book.title,
                        bgImg: book.previewImg,
                        href: book.href,
                        author: book.author,
                        isOwned: isOwnedByUser,
                        onBookmarkToggle: () {
                          // Обработка логики добавления/удаления книги
                          saveToBook(book.id).then((_) {
                            setState(() {
                              // Обновляем состояние, чтобы перерисовать
                              userBooksIds.contains(book.id)
                                  ? userBooksIds.remove(book.id)
                                  : userBooksIds.add(book.id);
                            });
                          });
                        },
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
