/// Defines the visual type/style of the message.
///
/// Each type has a predefined color and icon:
/// - [error]: Red background, error icon
/// - [success]: Green background, checkmark icon
/// - [info]: Blue background, info icon
/// - [warning]: Orange background, warning icon
enum MessageType {
  /// Error message (typically red)
  error,

  /// Success message (typically green)
  success,

  /// Informational message (typically blue)
  info,

  /// Warning message (typically orange)
  warning,
}
