// lib/models/quote_model.dart

class QuoteModel {
  // 1. Changed from 'content' to 'quote' to match widget access (quoteData.quote)
  final String quote; 
  final String author;
  final bool isError;
  // 2. Added 'isLoading' field to match widget access (quoteData.isLoading)
  final bool isLoading; 

  QuoteModel({
    required this.quote,
    required this.author,
    this.isError = false,
    this.isLoading = false, 
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      // Maps 'content' from the API response to the local 'quote' field
      quote: json['content'] as String, 
      author: json['author'] as String,
      isLoading: false,
    );
  }

  static QuoteModel loading() {
    return QuoteModel(
      quote: 'Loading quote...',
      author: 'Loading...',
      isError: false,
      isLoading: true, // This constructor is for the loading state
    );
  }
  
  static QuoteModel error(String errorMessage) {
    return QuoteModel(
      quote: 'Error: $errorMessage',
      author: 'App System',
      isError: true,
      isLoading: false,
    );
  }
}