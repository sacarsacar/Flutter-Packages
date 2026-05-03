import 'package:flutter/material.dart';
import 'package:mirror_skeleton/mirror_skeleton.dart';
import '../data/mock_repository.dart';
import '../models/user.dart';
import '../widgets/stat_chip.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;
  User _user = User.placeholder();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _user = User.placeholder();
    });
    final user = await MockRepository.fetchUser();
    if (!mounted) return;
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: MirrorSkeleton(
        isLoading: _loading,
        child: _ProfileBody(user: _user),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _load,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final User user;
  const _ProfileBody({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 56,
            backgroundColor: user.avatarColor,
            child: Text(
              user.name.isNotEmpty ? user.name[0] : '?',
              style: const TextStyle(color: Colors.white, fontSize: 36),
            ),
          ),
          const SizedBox(height: 16),
          Text(user.name, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            user.handle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.bio,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatChip(label: 'Posts', value: '${user.posts}'),
              StatChip(label: 'Followers', value: '${user.followers}'),
              StatChip(label: 'Following', value: '${user.following}'),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {},
              child: const Text('Edit profile'),
            ),
          ),
        ],
      ),
    );
  }
}
