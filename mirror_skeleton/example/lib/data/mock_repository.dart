import 'package:flutter/material.dart';
import '../models/article.dart';
import '../models/message.dart';
import '../models/product.dart';
import '../models/user.dart';

/// Pretends to be a backend. Every call returns mock data after a delay so
/// the example pages can flip between loading and loaded states.
class MockRepository {
  static const _delay = Duration(seconds: 2);

  static Future<User> fetchUser() async {
    await Future.delayed(_delay);
    return const User(
      name: 'Sakar Chaulagain',
      handle: '@sakar',
      bio:
          'Flutter developer focused on rendering, animations, and developer '
          'tooling. Building MirrorSkeleton in the open and shipping packages '
          'every weekend.',
      avatarColor: Color(0xFF1976D2),
      followers: 12480,
      following: 312,
      posts: 87,
    );
  }

  static Future<List<Article>> fetchFeed() async {
    await Future.delayed(_delay);
    return const [
      Article(
        title: 'Mirroring Render Trees For Pixel-Perfect Skeletons',
        excerpt:
            'A walkthrough of how MirrorSkeleton inspects RenderObjects to '
            'produce zero-shift loading states for any Flutter widget tree.',
        body: '',
        author: 'Sakar Chaulagain',
        date: 'Mon, 14 Apr',
        heroColor: Color(0xFFE3F2FD),
      ),
      Article(
        title: 'Adaptive Shimmer: Slowing Down When Frames Drop',
        excerpt:
            'Why a fixed 1.5s shimmer feels janky on older devices, and how '
            'to read FrameTiming to scale the animation gracefully.',
        body: '',
        author: 'Sakar Chaulagain',
        date: 'Sun, 13 Apr',
        heroColor: Color(0xFFFFF3E0),
      ),
      Article(
        title: 'SkeletonIgnore: Keeping Brand Elements Visible',
        excerpt:
            'Loading states do not have to erase your identity. Mark logos '
            'and key visuals as ignored so users still see your brand.',
        body: '',
        author: 'Sakar Chaulagain',
        date: 'Sat, 12 Apr',
        heroColor: Color(0xFFE8F5E9),
      ),
      Article(
        title: 'Rendering Multi-Line Text Bones From RenderParagraph',
        excerpt:
            'Using getBoxesForSelection to find the exact rectangles of every '
            'wrapped line so the skeleton mirrors text alignment perfectly.',
        body: '',
        author: 'Sakar Chaulagain',
        date: 'Fri, 11 Apr',
        heroColor: Color(0xFFF3E5F5),
      ),
      Article(
        title: 'Why Localized Coordinates Matter In Sliver Layouts',
        excerpt:
            'Sliver children use SliverMultiBoxAdaptorParentData, not '
            'BoxParentData. Use localToGlobal to stay layout-agnostic.',
        body: '',
        author: 'Sakar Chaulagain',
        date: 'Thu, 10 Apr',
        heroColor: Color(0xFFFCE4EC),
      ),
    ];
  }

  static Future<Article> fetchArticle() async {
    await Future.delayed(_delay);
    return const Article(
      title: 'Building MirrorSkeleton: A Render-Tree Aware Shimmer',
      excerpt:
          'How a one-line wrapper can produce pixel-perfect loading states '
          'by walking the actual RenderObject tree.',
      body:
          'Most skeleton libraries ask you to hand-craft a parallel widget '
          'tree that mirrors your UI, doubling the maintenance cost every '
          'time the design shifts. MirrorSkeleton takes a different angle: '
          'it inspects the laid-out render tree at paint time and projects a '
          'shape for every Text, Image, and decorated Container it finds.\n\n'
          'The result is zero layout shift when the data arrives, native '
          'feeling shimmer color derived from your theme, and a single line '
          'of code at the call-site. Wrap any widget tree in MirrorSkeleton '
          'with the loading flag and you are done.\n\n'
          'For elements that should never be hidden during loading, like a '
          'brand logo, wrap them in SkeletonIgnore. The shimmer skips that '
          'subtree and renders the real content on top.',
      author: 'Sakar Chaulagain',
      date: 'Wed, 16 Apr',
      heroColor: Color(0xFFE3F2FD),
    );
  }

  static Future<List<Product>> fetchProducts() async {
    await Future.delayed(_delay);
    return const [
      Product(
        name: 'Aurora Headphones',
        price: '\$129',
        rating: 4.8,
        thumbColor: Color(0xFFE3F2FD),
      ),
      Product(
        name: 'Nimbus Smart Lamp',
        price: '\$79',
        rating: 4.6,
        thumbColor: Color(0xFFFFF3E0),
      ),
      Product(
        name: 'Sage Yoga Mat',
        price: '\$45',
        rating: 4.7,
        thumbColor: Color(0xFFE8F5E9),
      ),
      Product(
        name: 'Lumen Desk Pad',
        price: '\$32',
        rating: 4.5,
        thumbColor: Color(0xFFF3E5F5),
      ),
      Product(
        name: 'Drift Bluetooth Speaker',
        price: '\$89',
        rating: 4.4,
        thumbColor: Color(0xFFFCE4EC),
      ),
      Product(
        name: 'Atlas Travel Mug',
        price: '\$24',
        rating: 4.3,
        thumbColor: Color(0xFFE0F7FA),
      ),
    ];
  }

  static Future<List<Message>> fetchMessages() async {
    await Future.delayed(_delay);
    return const [
      Message(
        sender: 'Alice Johnson',
        preview: 'Hey! Did you see the new build came through this morning?',
        time: '09:41',
        avatarColor: Color(0xFFEF5350),
        unread: 2,
      ),
      Message(
        sender: 'Bob Smith',
        preview: 'Pushed the migration. Tests are green.',
        time: '09:12',
        avatarColor: Color(0xFF42A5F5),
        unread: 0,
      ),
      Message(
        sender: 'Carol White',
        preview: 'Reviewing the design tokens now, will leave notes shortly.',
        time: '08:55',
        avatarColor: Color(0xFF66BB6A),
        unread: 1,
      ),
      Message(
        sender: 'David Brown',
        preview: 'Standup moved to 10:30. New calendar invite incoming.',
        time: 'Yesterday',
        avatarColor: Color(0xFFAB47BC),
        unread: 0,
      ),
      Message(
        sender: 'Eve Davis',
        preview: 'Released v2.4 to TestFlight. Crash-free sessions at 99.7%.',
        time: 'Yesterday',
        avatarColor: Color(0xFFFFA726),
        unread: 0,
      ),
      Message(
        sender: 'Frank Miller',
        preview: 'Can you take another look at the API contract?',
        time: 'Mon',
        avatarColor: Color(0xFF26A69A),
        unread: 0,
      ),
    ];
  }
}
