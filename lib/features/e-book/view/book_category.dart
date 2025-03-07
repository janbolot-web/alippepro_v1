import 'package:alippepro_v1/features/e-book/widgets/BookCard.dart';
import 'package:alippepro_v1/models/book.dart';
import 'package:alippepro_v1/services/book_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookCategory extends StatefulWidget {
  final String category;
  const BookCategory({super.key, required this.category});

  @override
  State<BookCategory> createState() => _BookCategoryState();
}

class _BookCategoryState extends State<BookCategory> {
  late Future<List<Book>> books;
  final TextEditingController _controller = TextEditingController();
  String inputValue = '';
  List<String> userBooksIds = []; // Список ID книг пользователя

  @override
  void initState() {
    super.initState();
    books = fetchBooksByCategory(widget.category);
    loadUserBooks();
  }

  void _searchBooks() {
    setState(() {
      books = fetchSearchBooks(_controller.text, widget.category);
    });
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
    return Scaffold(
      backgroundColor: const Color(0xffF0F0F0),
      appBar: AppBar(
        title: Text(
          widget.category,
          textAlign: TextAlign.center,
          style: GoogleFonts.rubik(
              color: const Color(0xff1B434D),
              fontSize: 24,
              fontWeight: FontWeight.bold),
        ),
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Поисковая строка
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
              child: TextField(
                controller: _controller,
                onChanged: (text) {
                  _searchBooks();
                },
                onSubmitted: (text) =>
                    _searchBooks(), // Поиск при нажатии Enter
                style: GoogleFonts.rubik(),
                decoration: InputDecoration(
                  hintText: 'Издөө',
                  hintStyle: GoogleFonts.rubik(
                      fontSize: 18,
                      color: const Color.fromARGB(126, 27, 67, 77)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchBooks,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Используем Expanded для правильной разметки ListView.builder
            Padding(
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
                ))
          ],
        ),
      ),
    );
  }
}
