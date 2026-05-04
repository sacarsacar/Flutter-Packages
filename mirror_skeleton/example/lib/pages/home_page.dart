import 'package:example/pages/chat_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/nav_card.dart';
import 'analytics_page.dart';
import 'article_page.dart';
import 'chat_page.dart';
import 'controls_page.dart';
import 'dashboard_page.dart';
import 'feed_page.dart';
import 'login_page.dart';
import 'music_player_page.dart';
import 'product_grid_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'shimmer_styles_page.dart';
import 'wallet_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final demos = <_Demo>[
      _Demo(
        title: 'Profile',
        subtitle: 'Avatar, multi-line bio, stat row',
        icon: Icons.person_outline,
        builder: (_) => const ProfilePage(),
      ),
      _Demo(
        title: 'Feed',
        subtitle: 'ListView of article tiles with images',
        icon: Icons.article_outlined,
        builder: (_) => const FeedPage(),
      ),
      _Demo(
        title: 'Product Grid',
        subtitle: 'GridView with cards, prices, ratings',
        icon: Icons.grid_view_outlined,
        builder: (_) => const ProductGridPage(),
      ),
      _Demo(
        title: 'Article',
        subtitle: 'Hero image, paragraphs, author row',
        icon: Icons.menu_book_outlined,
        builder: (_) => const ArticlePage(),
      ),
      _Demo(
        title: 'Messages',
        subtitle: 'Chat list with avatars and unread badges',
        icon: Icons.chat_bubble_outline,
        builder: (_) => const ChatPage(),
      ),
      _Demo(
        title: 'conversations',
        subtitle: 'Chat list with avatars and unread badges',
        icon: Icons.chat_bubble_outline,
        builder: (_) => const ChatScreen(),
      ),
      _Demo(
        title: 'Dashboard',
        subtitle: 'Mixed layout with SkeletonIgnore brand banner',
        icon: Icons.space_dashboard_outlined,
        builder: (_) => const DashboardPage(),
      ),
      _Demo(
        title: 'Controls Gallery',
        subtitle: 'Buttons, chips, switches, sliders, progress, text fields',
        icon: Icons.tune,
        builder: (_) => const ControlsPage(),
      ),
      _Demo(
        title: 'Login',
        subtitle: 'TextFields, password toggle, Checkbox, social buttons',
        icon: Icons.login,
        builder: (_) => const LoginPage(),
      ),
      _Demo(
        title: 'Settings',
        subtitle: 'Sectioned ListTiles with Switch, Checkbox, Slider, Divider',
        icon: Icons.settings_outlined,
        builder: (_) => const SettingsPage(),
      ),
      _Demo(
        title: 'Music Player',
        subtitle: 'Hero artwork, sliders, transport row, queue list',
        icon: Icons.music_note_outlined,
        builder: (_) => const MusicPlayerPage(),
      ),
      _Demo(
        title: 'Wallet',
        subtitle: 'Gradient balance card, action chips, transaction list',
        icon: Icons.account_balance_wallet_outlined,
        builder: (_) => const WalletPage(),
      ),
      _Demo(
        title: 'Analytics',
        subtitle: 'Sparkline + bar + donut CustomPaint charts and stats',
        icon: Icons.bar_chart,
        builder: (_) => const AnalyticsPage(),
      ),
      _Demo(
        title: 'Shimmer Styles',
        subtitle: 'Live playground for direction, pulse, color, intensity',
        icon: Icons.palette_outlined,
        builder: (_) => const ShimmerStylesPage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('MirrorSkeleton')),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: demos.length,
        itemBuilder: (context, i) {
          final d = demos[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: NavCard(
              title: d.title,
              subtitle: d.subtitle,
              icon: d.icon,
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: d.builder)),
            ),
          );
        },
      ),
    );
  }
}

class _Demo {
  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;

  const _Demo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });
}
