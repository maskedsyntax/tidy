import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tidy/domain/models/todo_list.dart';

/// Currently selected list id (`all` or a real list id).
final activeListIdProvider = StateProvider<String>((ref) => kAllTasksListId);

/// Search query for the main task list.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Whether the command palette overlay is open.
final commandPaletteOpenProvider = StateProvider<bool>((ref) => false);

/// Task id that should receive text focus (e.g. after create).
final focusTaskIdProvider = StateProvider<String?>((ref) => null);
