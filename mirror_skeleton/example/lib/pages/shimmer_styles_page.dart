import 'package:flutter/material.dart';
import 'package:mirror_skeleton/mirror_skeleton.dart';

/// Live playground for the shimmer customization knobs:
///
/// - [MirrorSkeletonStyle] (shimmer vs pulse)
/// - [ShimmerDirection]
/// - shimmer color tint, highlight color and intensity
/// - shimmer + transition durations
///
/// The same sample card is rendered through `MirrorSkeleton` and the
/// controls below mutate its parameters in real time. `isLoading` is
/// toggled by the floating button so you can also feel the crossfade.
class ShimmerStylesPage extends StatefulWidget {
  const ShimmerStylesPage({super.key});

  @override
  State<ShimmerStylesPage> createState() => _ShimmerStylesPageState();
}

class _ShimmerStylesPageState extends State<ShimmerStylesPage> {
  bool _loading = true;
  MirrorSkeletonStyle _style = MirrorSkeletonStyle.shimmer;
  ShimmerDirection _direction = ShimmerDirection.leftToRight;
  Color? _shimmerColor;
  double _intensity = 0.35;
  Duration _shimmerDuration = const Duration(milliseconds: 1500);

  Future<void> _reload() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Shimmer Styles')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // The "specimen" we shimmer.
          MirrorSkeleton(
            isLoading: _loading,
            style: _style,
            shimmerDirection: _direction,
            shimmerColor: _shimmerColor,
            shimmerHighlightIntensity: _intensity,
            shimmerDuration: _shimmerDuration,
            child: const _SampleCard(),
          ),
          const SizedBox(height: 24),
          Text('Style', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<MirrorSkeletonStyle>(
            segments: const [
              ButtonSegment(
                value: MirrorSkeletonStyle.shimmer,
                label: Text('Shimmer'),
                icon: Icon(Icons.auto_awesome),
              ),
              ButtonSegment(
                value: MirrorSkeletonStyle.pulse,
                label: Text('Pulse'),
                icon: Icon(Icons.bolt_outlined),
              ),
            ],
            selected: {_style},
            onSelectionChanged: (s) => setState(() => _style = s.first),
          ),
          const SizedBox(height: 24),
          Text('Direction', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final d in ShimmerDirection.values)
                ChoiceChip(
                  label: Text(_directionLabel(d)),
                  selected: _direction == d,
                  onSelected: (_) => setState(() => _direction = d),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Bone color', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _ColorChip(
                label: 'Theme',
                color: null,
                selected: _shimmerColor == null,
                onSelected: () => setState(() => _shimmerColor = null),
              ),
              for (final c in const [
                Color(0xFFE0E0E0),
                Color(0xFFE3F2FD),
                Color(0xFFFFF3E0),
                Color(0xFFE8F5E9),
                Color(0xFFFCE4EC),
              ])
                _ColorChip(
                  label: '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                  color: c,
                  selected: _shimmerColor == c,
                  onSelected: () => setState(() => _shimmerColor = c),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Highlight intensity · ${(_intensity * 100).round()}%',
            style: theme.textTheme.titleSmall,
          ),
          Slider(
            value: _intensity,
            min: 0.1,
            max: 0.8,
            divisions: 14,
            onChanged: (v) => setState(() => _intensity = v),
          ),
          const SizedBox(height: 8),
          Text(
            'Sweep duration · ${_shimmerDuration.inMilliseconds} ms',
            style: theme.textTheme.titleSmall,
          ),
          Slider(
            value: _shimmerDuration.inMilliseconds.toDouble(),
            min: 400,
            max: 4000,
            divisions: 36,
            onChanged: (v) => setState(
              () => _shimmerDuration = Duration(milliseconds: v.round()),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            label: const Text('Replay loading'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

String _directionLabel(ShimmerDirection d) {
  switch (d) {
    case ShimmerDirection.leftToRight:
      return 'L → R';
    case ShimmerDirection.rightToLeft:
      return 'R → L';
    case ShimmerDirection.topToBottom:
      return 'T → B';
    case ShimmerDirection.bottomToTop:
      return 'B → T';
  }
}

class _ColorChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool selected;
  final VoidCallback onSelected;

  const _ColorChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      avatar: color == null
          ? const Icon(Icons.palette_outlined, size: 18)
          : Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _SampleCard extends StatelessWidget {
  const _SampleCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFF42A5F5),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aurora Lights',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        'Released 2 hours ago',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'A demo card with a circular avatar, two text lines, a hero '
              'image area, body text that wraps over multiple lines so the '
              'shimmer can show line-by-line bones, and a row of buttons.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton(onPressed: () {}, child: const Text('Play')),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Save'),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
