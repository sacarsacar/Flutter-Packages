import 'package:flutter/material.dart';

class Article {
  final String title;
  final String excerpt;
  final String body;
  final String author;
  final String date;
  final Color heroColor;

  const Article({
    required this.title,
    required this.excerpt,
    required this.body,
    required this.author,
    required this.date,
    required this.heroColor,
  });

  factory Article.placeholder() => const Article(
    title: 'Loading article title that may span two lines',
    excerpt:
        'A two-line excerpt acts as a credible placeholder so the skeleton '
        'matches the real layout once data arrives.',
    body: '',
    author: 'Author Name',
    date: 'Mon, 1 Jan',
    heroColor: Color(0xFFCFD8DC),
  );
}
