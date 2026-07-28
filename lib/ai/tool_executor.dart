import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tidy/ai/openai_client.dart';
import 'package:tidy/core/icons/list_icons.dart';
import 'package:tidy/core/theme/app_theme.dart';
import 'package:tidy/domain/models/todo_list.dart';
import 'package:tidy/state/todo_controller.dart';
import 'package:tidy/state/ui_controllers.dart';

/// Executes model tool calls against app state.
class ToolExecutor {
  ToolExecutor(this.ref);

  final Ref ref;

  TodoController get _todos => ref.read(todoControllerProvider.notifier);
  TodoState get _state => ref.read(todoControllerProvider);

  Future<String> execute(ToolCall call) async {
    try {
      final args = call.parseArgs();
      final result = await _dispatch(call.name, args);
      return jsonEncode(result);
    } catch (e) {
      return jsonEncode({'ok': false, 'error': e.toString()});
    }
  }

  Future<Map<String, dynamic>> _dispatch(
    String name,
    Map<String, dynamic> args,
  ) async {
    switch (name) {
      case 'get_workspace':
        final active = ref.read(activeListIdProvider);
        return {
          'ok': true,
          'workspace': _todos.snapshotForAi(activeListId: active),
        };

      case 'create_list':
        final nameArg = (args['name'] as String?)?.trim() ?? '';
        if (nameArg.isEmpty) {
          return {'ok': false, 'error': 'name is required'};
        }
        final iconKey = (args['iconKey'] as String?)?.trim();
        final color = _parseColor(
          args['colorHex'] as String?,
          fallback: AppColors.work.toARGB32(),
        );
        final list = await _todos.createList(
          name: nameArg,
          iconKey: (iconKey != null && kListIconKeys.contains(iconKey))
              ? iconKey
              : 'briefcase',
          colorValue: color,
        );
        return {
          'ok': true,
          'list': {'id': list.id, 'name': list.name},
        };

      case 'update_list':
        final listId = args['listId'] as String?;
        if (listId == null || _state.listById(listId) == null) {
          return {'ok': false, 'error': 'Unknown listId'};
        }
        await _todos.updateList(
          id: listId,
          name: args['name'] as String?,
          iconKey: args['iconKey'] as String?,
          colorValue: args['colorHex'] != null
              ? _parseColor(args['colorHex'] as String?)
              : null,
        );
        return {'ok': true, 'listId': listId};

      case 'delete_list':
        final listId = args['listId'] as String?;
        if (listId == null || _state.listById(listId) == null) {
          return {'ok': false, 'error': 'Unknown listId'};
        }
        await _todos.deleteList(listId);
        if (ref.read(activeListIdProvider) == listId) {
          ref.read(activeListIdProvider.notifier).state = kAllTasksListId;
        }
        return {'ok': true, 'deletedListId': listId};

      case 'create_task':
        final listId = args['listId'] as String?;
        final title = (args['title'] as String?)?.trim() ?? '';
        if (listId == null || listId == kAllTasksListId) {
          return {'ok': false, 'error': 'Valid listId required (not "all")'};
        }
        if (_state.listById(listId) == null) {
          return {'ok': false, 'error': 'Unknown listId'};
        }
        if (title.isEmpty) return {'ok': false, 'error': 'title is required'};
        final parentId = args['parentId'] as String?;
        if (parentId != null && _state.taskById(parentId) == null) {
          return {'ok': false, 'error': 'Unknown parentId'};
        }
        final task = await _todos.addTask(
          listId: listId,
          parentId: parentId,
          title: title,
          focus: false,
        );
        if (args['completed'] == true) {
          await _todos.setCompleted(task.id, true);
        }
        return {
          'ok': true,
          'task': {
            'id': task.id,
            'listId': task.listId,
            'title': title,
            'parentId': parentId,
          },
        };

      case 'update_task':
        final taskId = args['taskId'] as String?;
        final task = taskId == null ? null : _state.taskById(taskId);
        if (task == null) return {'ok': false, 'error': 'Unknown taskId'};
        if (args['title'] is String) {
          await _todos.updateTitle(taskId!, (args['title'] as String).trim());
        }
        if (args['completed'] is bool) {
          await _todos.setCompleted(taskId!, args['completed'] as bool);
        }
        return {'ok': true, 'taskId': taskId};

      case 'delete_task':
        final taskId = args['taskId'] as String?;
        if (taskId == null || _state.taskById(taskId) == null) {
          return {'ok': false, 'error': 'Unknown taskId'};
        }
        await _todos.deleteTask(taskId);
        return {'ok': true, 'deletedTaskId': taskId};

      case 'move_task':
        final taskId = args['taskId'] as String?;
        final listId = args['listId'] as String?;
        if (taskId == null || _state.taskById(taskId) == null) {
          return {'ok': false, 'error': 'Unknown taskId'};
        }
        if (listId == null ||
            listId == kAllTasksListId ||
            _state.listById(listId) == null) {
          return {'ok': false, 'error': 'Unknown destination listId'};
        }
        await _todos.moveTaskToList(taskId, listId);
        return {'ok': true, 'taskId': taskId, 'listId': listId};

      case 'reorder_tasks':
        final listId = args['listId'] as String?;
        final ordered = (args['orderedTaskIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList();
        if (listId == null || ordered == null || ordered.isEmpty) {
          return {
            'ok': false,
            'error': 'listId and orderedTaskIds are required',
          };
        }
        final parentRaw = args['parentId'];
        final parentId = parentRaw == null || parentRaw == ''
            ? null
            : parentRaw.toString();
        await _todos.reorderTasks(
          listId: listId,
          parentId: parentId,
          orderedIds: ordered,
        );
        return {
          'ok': true,
          'listId': listId,
          'parentId': parentId,
          'orderedTaskIds': ordered,
        };

      case 'set_active_list':
        final listId = args['listId'] as String?;
        if (listId == null) return {'ok': false, 'error': 'listId required'};
        if (listId != kAllTasksListId && _state.listById(listId) == null) {
          return {'ok': false, 'error': 'Unknown listId'};
        }
        ref.read(activeListIdProvider.notifier).state = listId;
        return {'ok': true, 'activeListId': listId};

      default:
        return {'ok': false, 'error': 'Unknown tool: $name'};
    }
  }

  int _parseColor(String? hex, {int fallback = 0xFF3B82F6}) {
    if (hex == null || hex.trim().isEmpty) return fallback;
    var s = hex.trim();
    if (s.startsWith('#')) s = s.substring(1);
    if (s.length == 6) s = 'FF$s';
    if (s.length != 8) return fallback;
    return int.tryParse(s, radix: 16) ?? fallback;
  }
}
