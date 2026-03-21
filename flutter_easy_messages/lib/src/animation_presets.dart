/// Preset animation durations for toast notifications
class AnimationPresets {
  AnimationPresets._();

  /// Fast animation preset (200ms entry, 150ms exit)
  static const AnimationDuration fast = AnimationDuration(
    entry: Duration(milliseconds: 200),
    exit: Duration(milliseconds: 150),
    pulse: Duration(milliseconds: 300),
    pulseReverse: Duration(milliseconds: 300),
  );

  /// Normal animation preset (400ms entry, 300ms exit) - default
  static const AnimationDuration normal = AnimationDuration(
    entry: Duration(milliseconds: 400),
    exit: Duration(milliseconds: 300),
    pulse: Duration(milliseconds: 600),
    pulseReverse: Duration(milliseconds: 600),
  );

  /// Slow animation preset (600ms entry, 450ms exit)
  static const AnimationDuration slow = AnimationDuration(
    entry: Duration(milliseconds: 600),
    exit: Duration(milliseconds: 450),
    pulse: Duration(milliseconds: 900),
    pulseReverse: Duration(milliseconds: 900),
  );

  /// Extra slow animation preset (800ms entry, 600ms exit)
  static const AnimationDuration extraSlow = AnimationDuration(
    entry: Duration(milliseconds: 800),
    exit: Duration(milliseconds: 600),
    pulse: Duration(milliseconds: 1200),
    pulseReverse: Duration(milliseconds: 1200),
  );

  /// Instant animation preset (minimal delays)
  static const AnimationDuration instant = AnimationDuration(
    entry: Duration(milliseconds: 100),
    exit: Duration(milliseconds: 100),
    pulse: Duration(milliseconds: 200),
    pulseReverse: Duration(milliseconds: 200),
  );
}

/// Container for animation duration values
class AnimationDuration {
  final Duration entry;
  final Duration exit;
  final Duration pulse;
  final Duration pulseReverse;

  const AnimationDuration({
    required this.entry,
    required this.exit,
    required this.pulse,
    required this.pulseReverse,
  });
}

/// Preset scale values for animations
class ScalePresets {
  ScalePresets._();

  /// Subtle scale animation (1.02)
  static const double subtle = 1.02;

  /// Normal scale animation (1.05) - default
  static const double normal = 1.05;

  /// Medium scale animation (1.08)
  static const double medium = 1.08;

  /// Large scale animation (1.15)
  static const double large = 1.15;

  /// Extra large scale animation (1.25)
  static const double extraLarge = 1.25;
}
