import 'package:flutter/material.dart';

class Product {
  final String name;
  final String price;
  final double rating;
  final Color thumbColor;

  const Product({
    required this.name,
    required this.price,
    required this.rating,
    required this.thumbColor,
  });

  factory Product.placeholder() => const Product(
    name: 'Loading product',
    price: '\$00.00',
    rating: 0,
    thumbColor: Color(0xFFCFD8DC),
  );
}
