
import 'package:alippepro_v1/features/e-book/widgets/BookCard.dart';
import 'package:alippepro_v1/models/book.dart';
import 'package:alippepro_v1/services/book_controller.dart';
import 'package:flutter/material.dart';

class MyBooks extends StatefulWidget {
  const MyBooks({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  State<MyBooks> createState() => _MyBooksState();
}

class _MyBooksState extends State<MyBooks> {
  late Future<List<Book>> books;
  List<String> userBooksIds = []; // Список ID книг пользователя

  @override
  void initState() {
    super.initState();
    books = fetchMyBooks();
    loadUserBooks();
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: FutureBuilder<List<Book>>(
        future: books,
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
                  bgImg: book.previewImg,
                  title: book.title,
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
    );
  }
}
