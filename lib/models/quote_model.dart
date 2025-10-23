// lib/models/quote_model.dart

class QuoteModel {
  final String content;
  final String author;
  final bool isError;

  QuoteModel({
    required this.content,
    required this.author,
    this.isError = false,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      content: json['content'] as String,
      author: json['author'] as String,
    );
  }

  static QuoteModel loading() {
    return QuoteModel(
      content: 'Loading quote...',
      author: 'Loading...',
      isError: false,
    );
  }
}
