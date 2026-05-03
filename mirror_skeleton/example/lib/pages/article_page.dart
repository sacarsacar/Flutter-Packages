import 'package:flutter/material.dart';
import 'package:mirror_skeleton/mirror_skeleton.dart';
import '../data/mock_repository.dart';
import '../models/article.dart';

class ArticlePage extends StatefulWidget {
  const ArticlePage({super.key});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  bool _loading = true;
  Article _article = Article.placeholder();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _article = Article.placeholder();
    });
    final article = await MockRepository.fetchArticle();
    if (!mounted) return;
    setState(() {
      _article = article;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Article')),
      body: MirrorSkeleton(
        isLoading: _loading,
        child: _ArticleBody(
          article: _article,
          loadingFallbackBody: _loading
              ? 'Body paragraphs render placeholder text while loading so '
                    'MirrorSkeleton can mirror the wrapped lines as bones. The '
                    'text length matters because each visual line gets its '
                    'own bone matched to the rendered width.\n\n'
                    'A second paragraph keeps the rhythm of the layout '
                    'consistent so there is no visual jump when the real '
                    'article body arrives.'
              : null,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _load,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _ArticleBody extends StatelessWidget {
  final Article article;
  final String? loadingFallbackBody;

  const _ArticleBody({required this.article, this.loadingFallbackBody});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = loadingFallbackBody ?? article.body;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 220,
            width: double.infinity,
            color: article.heroColor,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      child: Text(
                        article.author.isNotEmpty ? article.author[0] : '?',
                        style: TextStyle(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(article.author, style: theme.textTheme.titleSmall),
                        Text(
                          article.date,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  body,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
