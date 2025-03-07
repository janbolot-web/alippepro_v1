class Book {
  final String title;
  final String author;
  final String category;
  final String href;
  final int pages;
  final String description;
  final String previewImg;
  final String id;

  Book({
    required this.title,
    required this.author,
    required this.category,
    required this.href,
    required this.pages,
    required this.description,
    required this.previewImg,
    required this.id,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'],
      author: json['author'],
      category: json['category'],
      href: json['href'],
      pages: json['pages'],
      description: json['description'],
      previewImg: json['previewImg'],
      id: json['_id'],
    );
  }
}
