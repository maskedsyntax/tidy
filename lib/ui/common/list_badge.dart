import 'package:flutter/material.dart';
import 'package:tidy/core/icons/list_icons.dart';
import 'package:tidy/core/theme/app_theme.dart';
import 'package:tidy/domain/models/todo_list.dart';

class ListBadge extends StatelessWidget {
  const ListBadge({
    super.key,
    required this.list,
    this.compact = false,
  });

  final TodoList list;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = list.color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconForKey(list.iconKey), size: 14, color: color),
        if (!compact) ...[
          const SizedBox(width: 5),
          Text(
            list.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ],
    );
  }
}

class ListIconLabel extends StatelessWidget {
  const ListIconLabel({
    super.key,
    required this.iconKey,
    required this.label,
    this.color,
    this.size = 16,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
  });

  final String iconKey;
  final String label;
  final Color? color;
  final double size;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).textPrimary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconForKey(iconKey), size: size, color: c),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: c,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}
