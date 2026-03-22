/// Defines how messages should behave when multiple messages are shown.
///
/// - [replace]: New message replaces the current one (default behavior)
/// - [queue]: New message waits until the current one is dismissed
enum MessageBehavior {
  /// Replace the current message with the new one.
  replace,

  /// Queue the new message to show after the current one disappears.
  queue,
}
