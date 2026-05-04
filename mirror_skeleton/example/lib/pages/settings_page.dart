import 'package:flutter/material.dart';
import 'package:mirror_skeleton/mirror_skeleton.dart';

/// Stresses ListTile-heavy layouts: leading icons, trailing controls
/// (Switch, Checkbox, Slider, chevrons, badges), section headers,
/// dividers, and a destructive action button at the bottom.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loading = true;
  bool _push = true;
  bool _email = false;
  bool _twoFactor = true;
  bool _darkMode = false;
  double _fontScale = 1.0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: MirrorSkeleton(
        isLoading: _loading,
        child: ListView(
          children: [
            _Section(
              title: 'Account',
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF1976D2),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: const Text('Sakar Chaulagain'),
                    subtitle: const Text('sakar@example.com'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 72),
                  const ListTile(
                    leading: Icon(Icons.lock_outline),
                    title: Text('Two-factor authentication'),
                    subtitle: Text('SMS · ••• 4421'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            _Section(
              title: 'Notifications',
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_outlined),
                    title: const Text('Push notifications'),
                    subtitle: const Text('Alerts on this device'),
                    value: _push,
                    onChanged: (v) => setState(() => _push = v),
                  ),
                  const Divider(height: 1, indent: 72),
                  SwitchListTile(
                    secondary: const Icon(Icons.email_outlined),
                    title: const Text('Email digest'),
                    subtitle: const Text('Weekly summary'),
                    value: _email,
                    onChanged: (v) => setState(() => _email = v),
                  ),
                ],
              ),
            ),
            _Section(
              title: 'Security',
              child: Column(
                children: [
                  CheckboxListTile(
                    secondary: const Icon(Icons.shield_outlined),
                    title: const Text('Require 2FA on login'),
                    value: _twoFactor,
                    onChanged: (v) =>
                        setState(() => _twoFactor = v ?? false),
                  ),
                  const Divider(height: 1, indent: 72),
                  const ListTile(
                    leading: Icon(Icons.devices_outlined),
                    title: Text('Active sessions'),
                    trailing: _Badge(label: '3'),
                  ),
                ],
              ),
            ),
            _Section(
              title: 'Appearance',
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Dark mode'),
                    value: _darkMode,
                    onChanged: (v) => setState(() => _darkMode = v),
                  ),
                  const Divider(height: 1, indent: 72),
                  ListTile(
                    leading: const Icon(Icons.format_size),
                    title: const Text('Font size'),
                    subtitle: Slider(
                      value: _fontScale,
                      min: 0.8,
                      max: 1.4,
                      divisions: 6,
                      label: '${(_fontScale * 100).round()}%',
                      onChanged: (v) => setState(() => _fontScale = v),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _load,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Card(margin: EdgeInsets.zero, child: child),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
