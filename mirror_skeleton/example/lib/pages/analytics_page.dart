import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mirror_skeleton/mirror_skeleton.dart';

/// Stresses CustomPaint detection: a sparkline chart, a bar chart, and a
/// donut chart all become bones during loading. Also covers stat cards in
/// a grid and a horizontal stat-chip row.
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool _loading = true;

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
      appBar: AppBar(title: const Text('Analytics')),
      body: MirrorSkeleton(
        isLoading: _loading,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Stat row.
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Revenue',
                    value: '\$24.8k',
                    delta: '+12%',
                    deltaColor: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Sessions',
                    value: '8,124',
                    delta: '+3.2%',
                    deltaColor: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Bounce',
                    value: '32.1%',
                    delta: '-1.4%',
                    deltaColor: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Conv.',
                    value: '4.7%',
                    delta: '+0.8%',
                    deltaColor: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Sparkline / line chart.
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue · last 14 days',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: CustomPaint(
                        size: const Size(double.infinity, 140),
                        painter: _SparklinePainter(theme.colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Bar chart.
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sessions by source',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 160,
                      child: CustomPaint(
                        size: const Size(double.infinity, 160),
                        painter: _BarChartPainter(theme.colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Donut + legend row.
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CustomPaint(
                        painter: _DonutPainter([
                          (0.45, theme.colorScheme.primary),
                          (0.30, theme.colorScheme.tertiary),
                          (0.15, theme.colorScheme.secondary),
                          (0.10, theme.colorScheme.outline),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LegendRow(
                            color: theme.colorScheme.primary,
                            label: 'Direct',
                            value: '45%',
                          ),
                          const SizedBox(height: 6),
                          _LegendRow(
                            color: theme.colorScheme.tertiary,
                            label: 'Search',
                            value: '30%',
                          ),
                          const SizedBox(height: 6),
                          _LegendRow(
                            color: theme.colorScheme.secondary,
                            label: 'Social',
                            value: '15%',
                          ),
                          const SizedBox(height: 6),
                          _LegendRow(
                            color: theme.colorScheme.outline,
                            label: 'Other',
                            value: '10%',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String delta;
  final Color deltaColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.delta,
    required this.deltaColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              delta,
              style: theme.textTheme.labelSmall?.copyWith(
                color: deltaColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final Color color;
  _SparklinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final pts = [
      0.3,
      0.5,
      0.4,
      0.65,
      0.55,
      0.7,
      0.6,
      0.75,
      0.7,
      0.8,
      0.72,
      0.85,
      0.83,
      0.9,
    ];
    final stroke = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final fill = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    final path = Path();
    final fillPath = Path();
    for (var i = 0; i < pts.length; i++) {
      final x = (i / (pts.length - 1)) * size.width;
      final y = size.height - pts[i] * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) => old.color != color;
}

class _BarChartPainter extends CustomPainter {
  final Color color;
  _BarChartPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final values = [0.55, 0.85, 0.40, 0.70, 0.60, 0.92, 0.48];
    final barWidth = size.width / (values.length * 1.5);
    final paint = Paint()..color = color;
    for (var i = 0; i < values.length; i++) {
      final x = i * (size.width / values.length) + barWidth * 0.25;
      final h = values[i] * size.height;
      final rect = Rect.fromLTWH(x, size.height - h, barWidth, h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) => old.color != color;
}

class _DonutPainter extends CustomPainter {
  final List<(double, Color)> slices;
  _DonutPainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final center = Offset(size.width / 2, size.height / 2);
    var start = -pi / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;
    for (final (frac, color) in slices) {
      paint.color = color;
      final sweep = frac * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r - 12),
        start,
        sweep - 0.04, // tiny gap between slices
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.slices != slices;
}
