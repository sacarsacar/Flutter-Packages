import 'package:flutter/material.dart';

class User {
  final String name;
  final String handle;
  final String bio;
  final Color avatarColor;
  final int followers;
  final int following;
  final int posts;

  const User({
    required this.name,
    required this.handle,
    required this.bio,
    required this.avatarColor,
    required this.followers,
    required this.following,
    required this.posts,
  });

  /// Realistic-ish placeholder for the loading state. The text length matters:
  /// MirrorSkeleton mirrors the actual line count of the rendered text, so the
  /// bio length should approximate the real one.
  factory User.placeholder() => const User(
    name: 'Loading Username',
    handle: '@loading',
    bio:
        'A reasonably long placeholder bio so MirrorSkeleton can detect line '
        'wrapping and draw one bone per visual line of the rendered text.',
    avatarColor: Color(0xFFB0BEC5),
    followers: 0,
    following: 0,
    posts: 0,
  );
}
