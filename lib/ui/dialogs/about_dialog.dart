import 'package:flutter/material.dart';
import 'package:tidy/core/theme/app_theme.dart';

Future<void> showTidyAboutDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Tidy'),
      content: const SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A polished desktop todo app for macOS and Linux.',
              style: TextStyle(height: 1.4),
            ),
            SizedBox(height: 12),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: AppColors.lightTextMuted),
            ),
            SizedBox(height: 8),
            Text(
              'Tab to indent · Enter to add · ⌘K for command palette',
              style: TextStyle(fontSize: 12, color: AppColors.lightTextMuted),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
