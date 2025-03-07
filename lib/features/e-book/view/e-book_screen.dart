// ignore_for_file: file_names

import 'package:alippepro_v1/features/e-book/view/book_category.dart';
import 'package:alippepro_v1/features/e-book/widgets/MyBooks.dart';
import 'package:alippepro_v1/features/e-book/widgets/ReadBooks.dart';
import 'package:alippepro_v1/models/book.dart';
import 'package:alippepro_v1/services/book_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf_render/pdf_render.dart';

class EBookScreen extends StatefulWidget {
  const EBookScreen({super.key});

  @override
  State<EBookScreen> createState() => _EBookScreenState();
}

class _EBookScreenState extends State<EBookScreen> {
  PdfDocument? _document;
  PdfPageImage? _pageImage;
  final bool _loading = true;
  final TextEditingController _controller = TextEditingController();

  late Future<List<Book>> futureBooks;
  List<String> userBooksIds = []; // Список ID книг пользователя

  int _selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureBooks = fetchBooks(); // Вызов функции для получения книг
    loadUserBooks();
  }

  fetchBooksFromCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookCategory(category: category)),
    );
  }

  Future<void> loadUserBooks() async {
    // Предположим, что fetchUserBooks возвращает список книг пользователя
    final List<Book> userBooks = await fetchMyBooks();
    setState(() {
      // Получаем ID книг и сохраняем их
      userBooksIds = userBooks.map((book) => book.id).toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _searchBooks() {
    setState(() {
      futureBooks = fetchSearchBooks(_controller.text, '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F0F0),
      appBar: AppBar(
        title: Text(
          'Электрондук\nкитептер',
          textAlign: TextAlign.center,
          style: GoogleFonts.rubik(
              color: const Color(
                0xff1B434D,
              ),
              fontSize: 24,
              fontWeight: FontWeight.bold),
        ),
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Поисковая строка
          Padding(
            padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
            child: TextField(
              controller: _controller,
              onChanged: (text) {
                _searchBooks();
              },
              onSubmitted: (text) => _searchBooks(), // Поиск при нажатии Enter
              style: GoogleFonts.rubik(),
              decoration: InputDecoration(
                hintText: 'Издөө',
                hintStyle: GoogleFonts.rubik(
                    fontSize: 18, color: const Color.fromARGB(126, 27, 67, 77)),
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
          const SizedBox(height: 16),
          // Кнопки "Китепкана" и "Менин китептерим"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _onItemTapped(0);
                  },
                  icon: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(width: 1, color: const Color(0xff054E45))),
                    child: Image.asset(
                      'assets/img/category-2.png',
                      width: 30,
                    ),
                  ),
                  label: Text(
                    'Китепкана',
                    style: GoogleFonts.rubik(
                        color: _selectedIndex == 0
                            ? Colors.white
                            : const Color(0xff054E45)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _selectedIndex == 0 ? const Color(0xff054E45) : Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _onItemTapped(1);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: _selectedIndex == 1
                          ? const Color(0xff054E45)
                          : Colors.white,
                    ),
                    padding:
                        const EdgeInsets.only(left: 5, right: 15, top: 5, bottom: 5),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border:
                                  Border.all(width: 1, color: Colors.white)),
                          child: Image.asset(
                            'assets/img/archive-tick.png',
                            width: 30,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Менин\nкитептерим',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rubik(
                            height: 1.2,
                            fontSize: 14,
                            color: _selectedIndex == 1
                                ? Colors.white
                                : const Color(0xff054E45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Кнопка категории
          if (_selectedIndex != 0) MyBooks(context: context),
          if (_selectedIndex == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ListTile(
                leading: Image.asset(
                  'assets/img/category-1.png',
                  width: 24,
                ),
                title: Text(
                  'Категориялар',
                  style: GoogleFonts.rubik(
                      color: const Color(0xff005558),
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xff005558),
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return DraggableScrollableSheet(
                        initialChildSize: 0.93, //set this as you want
                        maxChildSize: 0.93, //set this as you want
                        minChildSize: 0.93,
                        expand: false,
                        builder: (context, scrollController) {
                          return Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(25),
                              ),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: Text(
                                    'Категориялар',
                                    style: GoogleFonts.rubik(
                                        color: const Color(0xff1B434D),
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Divider(),
                                Expanded(
                                  child: ListView(
                                    controller: scrollController,
                                    children: [
                                      ListTile(
                                        onTap: () {
                                          // fetchBooksFromCategory()
                                        },
                                        leading: const Icon(
                                          Icons.bookmark,
                                          color: Color(0xff005558),
                                        ),
                                        title: Text(
                                          'Окугум келген китептер',
                                          style: GoogleFonts.rubik(
                                            color: const Color(0xff005558),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        onTap: () {
                                          // fetchBooksFromCategory()
                                        },
                                        leading: const Icon(
                                          Icons.check_circle,
                                          color: Color(0xff005558),
                                        ),
                                        title: Text(
                                          'Окуп бүтөн китептер',
                                          style: GoogleFonts.rubik(
                                            color: const Color(0xff005558),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        onTap: () {
                                          fetchBooksFromCategory('Фентези');
                                        },
                                        leading: const Icon(
                                          Icons.business,
                                          color: Color(0xff005558),
                                        ),
                                        title: Text(
                                          'Фентези',
                                          style: GoogleFonts.rubik(
                                            color: const Color(0xff005558),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        onTap: () {
                                          fetchBooksFromCategory('Психология');
                                        },
                                        leading: const Icon(
                                          Icons.self_improvement,
                                          color: Color(0xff005558),
                                        ),
                                        title: Text(
                                          'Психология',
                                          style: GoogleFonts.rubik(
                                            color: const Color(0xff005558),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        onTap: () {
                                          fetchBooksFromCategory('Поэзия');
                                        },
                                        leading: const Icon(
                                          Icons.school,
                                          color: Color(0xff005558),
                                        ),
                                        title: Text(
                                          'Поэзия',
                                          style: GoogleFonts.rubik(
                                            color: const Color(0xff005558),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        onTap: () {
                                          fetchBooksFromCategory(
                                              'Өспүрүмдөр адабияты');
                                        },
                                        leading: const Icon(
                                          Icons.psychology,
                                          color: Color(0xff005558),
                                        ),
                                        title: Text(
                                          'Өспүрүмдөр адабияты',
                                          style: GoogleFonts.rubik(
                                            color: const Color(0xff005558),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        onTap: () {
                                          fetchBooksFromCategory(
                                              'Кыргыз адабият');
                                        },
                                        leading: const Icon(
                                          Icons.star,
                                          color: Color(0xff005558),
                                        ),
                                        title: Text(
                                          'Кыргыз адабияты',
                                          style: GoogleFonts.rubik(
                                            color: const Color(0xff005558),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        onTap: () {
                                          fetchBooksFromCategory('Ислам Дини');
                                        },
                                        leading: const Icon(
                                          Icons.public,
                                          color: Color(0xff005558),
                                        ),
                                        title: Text(
                                          'Ислам Дини',
                                          style: GoogleFonts.rubik(
                                            color: const Color(0xff005558),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        onTap: () {
                                          fetchBooksFromCategory('Жеке өнүгүү');
                                        },
                                        leading: const Icon(
                                          Icons.child_friendly,
                                          color: Color(0xff005558),
                                        ),
                                        title: Text(
                                          'Жеке өнүгүү',
                                          style: GoogleFonts.rubik(
                                            color: const Color(0xff005558),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        onTap: () {
                                          fetchBooksFromCategory(
                                              'Бөбөктөр үчүн');
                                        },
                                        leading: const Icon(
                                          Icons.pets,
                                          color: Color(0xff005558),
                                        ),
                                        title: Text(
                                          'Бөбөктөр үчүн',
                                          style: GoogleFonts.rubik(
                                            color: const Color(0xff005558),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        onTap: () {
                                          fetchBooksFromCategory(
                                              'Дүйнөлүк адабият');
                                        },
                                        leading: const Icon(
                                          Icons.mark_as_unread,
                                          color: Color(0xff005558),
                                        ),
                                        title: Text(
                                          'Дүйнөлүк адабият',
                                          style: GoogleFonts.rubik(
                                            color: const Color(0xff005558),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        onTap: () {
                                          fetchBooksFromCategory(
                                              'Ата-энелер үчүн');
                                        },
                                        leading: const Icon(
                                          Icons.family_restroom,
                                          color: Color(0xff005558),
                                        ),
                                        title: Text(
                                          'Ата-энелер үчүн',
                                          style: GoogleFonts.rubik(
                                            color: const Color(0xff005558),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        onTap: () {
                                          fetchBooksFromCategory('Билим берүү');
                                        },
                                        leading: const Icon(
                                          Icons.family_restroom,
                                          color: Color(0xff005558),
                                        ),
                                        title: Text(
                                          'Билим берүү',
                                          style: GoogleFonts.rubik(
                                            color: const Color(0xff005558),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        onTap: () {
                                          fetchBooksFromCategory('Биография');
                                        },
                                        leading: const Icon(
                                          Icons.family_restroom,
                                          color: Color(0xff005558),
                                        ),
                                        title: Text(
                                          'Биография',
                                          style: GoogleFonts.rubik(
                                            color: const Color(0xff005558),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          if (_selectedIndex == 0) const SizedBox(height: 16),
          // Окуп жаткан китептер (Прочитанные книги)
          if (_selectedIndex == 0) ReadBooks(futureBooks: futureBooks),
        ],
      ),
    );
  }
}

// class BookCard extends StatelessWidget {
//   final String imageUrl;
//   final double progress;

//   const BookCard({
//     super.key,
//     required this.imageUrl,
//     required this.progress,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) => BookScreen(
//                   fileName:
//                       '1QVHYWmJETh_z9zdbBbSMHzTN-XqyyJbP', // Название файла для сохранения
// title: ,
//                   url:
//                       'https://drive.google.com/uc?export=download&id=1QVHYWmJETh_z9zdbBbSMHzTN-XqyyJbP')),
//         )
//       },
//       child: Column(
//         children: [
//           Container(
//             width: 100,
//             height: 150,
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: NetworkImage(imageUrl),
//                 fit: BoxFit.cover,
//               ),
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//           const SizedBox(height: 4),
//           // LinearProgressIndicator(
//           //   value: progress,
//           //   color: Colors.teal,
//           //   backgroundColor: Colors.grey[300],
//           // ),
//         ],
//       ),
//     );
//   }
// }
