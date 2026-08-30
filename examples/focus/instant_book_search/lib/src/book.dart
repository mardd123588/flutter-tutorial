class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.year,
    required this.shelf,
    required this.note,
  });

  // #region hand-written-book-json
  factory Book.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final title = json['title'];
    final author = json['author'];
    final year = json['year'];
    final shelf = json['shelf'];
    final note = json['note'];

    if (id is! String || id.isEmpty) {
      throw const FormatException('Book.id 必须是非空字符串');
    }
    if (title is! String || title.isEmpty) {
      throw const FormatException('Book.title 必须是非空字符串');
    }
    if (author is! String || author.isEmpty) {
      throw const FormatException('Book.author 必须是非空字符串');
    }
    if (year is! int) {
      throw const FormatException('Book.year 必须是整数');
    }
    if (shelf is! String || shelf.isEmpty) {
      throw const FormatException('Book.shelf 必须是非空字符串');
    }
    if (note is! String || note.isEmpty) {
      throw const FormatException('Book.note 必须是非空字符串');
    }

    return Book(
      id: id,
      title: title,
      author: author,
      year: year,
      shelf: shelf,
      note: note,
    );
  }
  // #endregion hand-written-book-json

  final String id;
  final String title;
  final String author;
  final int year;
  final String shelf;
  final String note;
}
