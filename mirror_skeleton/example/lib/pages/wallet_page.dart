import 'package:flutter/material.dart';
import 'package:mirror_skeleton/mirror_skeleton.dart';

/// Stresses gradient cards, action chip rows, and a transaction list with
/// circular leading icons, two text rows, and right-aligned amount with
/// color-coded delta.
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool _loading = true;

  static const _txns = <_Txn>[
    _Txn('Spotify', 'Subscription', '-\$12.99', false, Icons.music_note),
    _Txn('Acme Inc.', 'Salary', '+\$3,200.00', true, Icons.work_outline),
    _Txn('Whole Foods', 'Groceries', '-\$84.20', false, Icons.shopping_basket),
    _Txn('Refund', 'Amazon', '+\$24.50', true, Icons.replay),
    _Txn('Uber', 'Ride home', '-\$11.40', false, Icons.local_taxi),
    _Txn('Netflix', 'Subscription', '-\$15.99', false, Icons.movie_outlined),
  ];

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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: MirrorSkeleton(
        isLoading: _loading,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Gradient balance card.
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.tertiary,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Balance',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary.withValues(
                        alpha: 0.85,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$12,480.50',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.credit_card,
                        size: 18,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '•••• 4421',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimary.withValues(
                            alpha: 0.85,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Visa',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Action chips row.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.send, size: 18),
                    label: const Text('Send'),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.savings_outlined, size: 18),
                    label: const Text('Deposit'),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.qr_code, size: 18),
                    label: const Text('Receive'),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.swap_horiz, size: 18),
                    label: const Text('Convert'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Recent activity', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < _txns.length; i++) ...[
                    _TxnTile(txn: _txns[i]),
                    if (i < _txns.length - 1)
                      const Divider(height: 1, indent: 72),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
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

class _Txn {
  final String title;
  final String subtitle;
  final String amount;
  final bool incoming;
  final IconData icon;
  const _Txn(this.title, this.subtitle, this.amount, this.incoming, this.icon);
}

class _TxnTile extends StatelessWidget {
  final _Txn txn;
  const _TxnTile({required this.txn});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: txn.incoming
            ? Colors.green.shade100
            : theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          txn.icon,
          color: txn.incoming ? Colors.green.shade800 : null,
        ),
      ),
      title: Text(txn.title),
      subtitle: Text(txn.subtitle),
      trailing: Text(
        txn.amount,
        style: theme.textTheme.titleSmall?.copyWith(
          color: txn.incoming ? Colors.green.shade700 : null,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
