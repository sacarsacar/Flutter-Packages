import 'package:flutter/material.dart';
import 'package:mirror_skeleton/mirror_skeleton.dart';
import '../data/mock_repository.dart';
import '../models/article.dart';
import '../widgets/article_tile.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  static const _placeholderCount = 6;
  bool _loading = true;
  List<Article> _articles = List.generate(
    _placeholderCount,
    (_) => Article.placeholder(),
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _articles = List.generate(_placeholderCount, (_) => Article.placeholder());
    });
    final articles = await MockRepository.fetchFeed();
    if (!mounted) return;
    setState(() {
      _articles = articles;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: MirrorSkeleton(
        isLoading: _loading,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _articles.length,
          itemBuilder: (_, i) => ArticleTile(article: _articles[i]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _load,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
