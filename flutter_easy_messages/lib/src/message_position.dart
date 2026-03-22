/// Defines where a message should appear on the screen.
///
/// Provides 9 position options arranged in a 3x3 grid:
/// - Top row: [topLeft], [topCenter], [topRight]
/// - Middle row: [centerLeft], [center], [centerRight]
/// - Bottom row: [bottomLeft], [bottomCenter], [bottomRight]
enum MessagePosition {
  /// Top-left corner of the screen
  topLeft,

  /// Top-center of the screen
  topCenter,

  /// Top-right corner of the screen
  topRight,

  /// Center-left of the screen (vertically centered)
  centerLeft,

  /// Center of the screen (both axes)
  center,

  /// Center-right of the screen (vertically centered)
  centerRight,

  /// Bottom-left corner of the screen
  bottomLeft,

  /// Bottom-center of the screen (horizontally centered)
  bottomCenter,

  /// Bottom-right corner of the screen
  bottomRight,
}
