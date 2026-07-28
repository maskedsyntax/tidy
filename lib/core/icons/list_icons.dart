import 'package:flutter/material.dart';

/// Maps string icon keys (persisted) to Material icons used in the UI.
IconData iconForKey(String key) {
  switch (key) {
    case 'all':
    case 'infinity':
      return Icons.all_inclusive_rounded;
    case 'work':
    case 'briefcase':
      return Icons.work_outline_rounded;
    case 'personal':
    case 'home':
      return Icons.home_outlined;
    case 'learning':
    case 'school':
      return Icons.school_outlined;
    case 'star':
      return Icons.star_outline_rounded;
    case 'heart':
      return Icons.favorite_border_rounded;
    case 'flag':
      return Icons.flag_outlined;
    case 'bolt':
      return Icons.bolt_outlined;
    case 'book':
      return Icons.menu_book_outlined;
    case 'code':
      return Icons.code_rounded;
    case 'music':
      return Icons.music_note_outlined;
    case 'fitness':
      return Icons.fitness_center_rounded;
    case 'cart':
      return Icons.shopping_cart_outlined;
    case 'plane':
      return Icons.flight_outlined;
    default:
      return Icons.list_alt_rounded;
  }
}

/// Icons available when creating a new list.
const List<String> kListIconKeys = [
  'briefcase',
  'home',
  'school',
  'star',
  'heart',
  'flag',
  'bolt',
  'book',
  'code',
  'music',
  'fitness',
  'cart',
  'plane',
];

/// Preset colors for new lists.
const List<Color> kListColorPresets = [
  Color(0xFF3B82F6), // blue
  Color(0xFF22C55E), // green
  Color(0xFFA855F7), // purple
  Color(0xFFEF4444), // red
  Color(0xFFF59E0B), // amber
  Color(0xFF06B6D4), // cyan
  Color(0xFFEC4899), // pink
  Color(0xFF8B5CF6), // violet
  Color(0xFF14B8A6), // teal
  Color(0xFFF97316), // orange
];
