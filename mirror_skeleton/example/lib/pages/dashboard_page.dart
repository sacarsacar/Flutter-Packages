import 'package:flutter/material.dart';
import 'package:mirror_skeleton/mirror_skeleton.dart';
import '../data/mock_repository.dart';
import '../models/article.dart';
import '../models/user.dart';
import '../widgets/article_tile.dart';
import '../widgets/stat_chip.dart';

/// Demonstrates [SkeletonIgnore]: the brand header and refresh button stay
/// fully visible while the rest of the page shows a shimmer.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _loading = true;
  User _user = User.placeholder();
  List<Article> _articles = List.generate(3, (_) => Article.placeholder());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _user = User.placeholder();
      _articles = List.generate(3, (_) => Article.placeholder());
    });
    final results = await Future.wait([
      MockRepository.fetchUser(),
      MockRepository.fetchFeed(),
    ]);
    if (!mounted) return;
    setState(() {
      _user = results[0] as User;
      _articles = (results[1] as List<Article>).take(3).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // SkeletonIgnore inside the AppBar is unnecessary because the
          // AppBar is outside the MirrorSkeleton, but the brand banner and
          // refresh button INSIDE the body are wrapped below.
        ],
      ),
      body: MirrorSkeleton(
        isLoading: _loading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The brand banner stays visible during loading.
              SkeletonIgnore(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.tertiary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: theme.colorScheme.onPrimary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MirrorSkeleton',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            Text(
                              'Brand stays visible while data loads',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Hello, ${_user.name}', style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Here is what is happening today.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatChip(label: 'Posts', value: '${_user.posts}'),
                  StatChip(label: 'Followers', value: '${_user.followers}'),
                  StatChip(label: 'Following', value: '${_user.following}'),
                ],
              ),
              const SizedBox(height: 24),
              Text('Latest articles', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ..._articles.map(
                (a) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ArticleTile(article: a),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _load,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
