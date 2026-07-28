import 'dart:convert';

/// OpenAI-format tool definitions for list/task control.
List<Map<String, dynamic>> tidyToolDefinitions() {
  Map<String, dynamic> fn(
    String name,
    String description,
    Map<String, dynamic> properties, {
    List<String> required = const [],
  }) {
    return {
      'type': 'function',
      'function': {
        'name': name,
        'description': description,
        'parameters': {
          'type': 'object',
          'properties': properties,
          'required': required,
        },
      },
    };
  }

  return [
    fn(
      'get_workspace',
      'Get the current lists and tasks (ids, titles, list membership, completion, order). Call this before bulk edits if you need fresh data.',
      {},
    ),
    fn(
      'create_list',
      'Create a new todo list.',
      {
        'name': {'type': 'string', 'description': 'List name'},
        'iconKey': {
          'type': 'string',
          'description':
              'Optional icon key: briefcase, home, school, star, heart, flag, bolt, book, code, music, fitness, cart, plane',
        },
        'colorHex': {
          'type': 'string',
          'description': 'Optional ARGB or RGB hex like #3B82F6',
        },
      },
      required: ['name'],
    ),
    fn(
      'update_list',
      'Rename a list and/or change its icon or color.',
      {
        'listId': {'type': 'string'},
        'name': {'type': 'string'},
        'iconKey': {'type': 'string'},
        'colorHex': {'type': 'string'},
      },
      required: ['listId'],
    ),
    fn(
      'delete_list',
      'Delete a list and all of its tasks. Irreversible.',
      {
        'listId': {'type': 'string'},
      },
      required: ['listId'],
    ),
    fn(
      'create_task',
      'Create a task (optionally as a subtask via parentId).',
      {
        'listId': {
          'type': 'string',
          'description': 'Owning list id (not "all")',
        },
        'title': {'type': 'string'},
        'parentId': {
          'type': 'string',
          'description': 'Optional parent task id for a subtask',
        },
        'completed': {'type': 'boolean'},
      },
      required: ['listId', 'title'],
    ),
    fn(
      'update_task',
      'Update a task title and/or completed state.',
      {
        'taskId': {'type': 'string'},
        'title': {'type': 'string'},
        'completed': {'type': 'boolean'},
      },
      required: ['taskId'],
    ),
    fn(
      'delete_task',
      'Delete a task and its subtasks.',
      {
        'taskId': {'type': 'string'},
      },
      required: ['taskId'],
    ),
    fn(
      'move_task',
      'Move a task (and its subtasks) to another list.',
      {
        'taskId': {'type': 'string'},
        'listId': {'type': 'string', 'description': 'Destination list id'},
      },
      required: ['taskId', 'listId'],
    ),
    fn(
      'reorder_tasks',
      'Set the order of sibling tasks. Pass task ids highest-priority / top-first.',
      {
        'listId': {'type': 'string'},
        'parentId': {
          'type': 'string',
          'description':
              'Omit or null for root tasks; set to parent task id for subtasks',
        },
        'orderedTaskIds': {
          'type': 'array',
          'items': {'type': 'string'},
          'description': 'Task ids in desired order (first = top)',
        },
      },
      required: ['listId', 'orderedTaskIds'],
    ),
    fn(
      'set_active_list',
      'Switch the UI to show a list (or all tasks).',
      {
        'listId': {
          'type': 'string',
          'description': 'List id, or "all" for All Tasks',
        },
      },
      required: ['listId'],
    ),
  ];
}

String tidySystemPrompt(Map<String, dynamic> snapshot) {
  final pretty = const JsonEncoder.withIndent('  ').convert(snapshot);
  return '''
You are Tidy Assistant — you help the user manage their todo lists and tasks inside the Tidy desktop app.

You can call tools to read and mutate workspace state. Prefer tools over guessing. After changes, briefly confirm what you did in plain language.

Rules:
- Use real list/task ids from get_workspace or the snapshot below.
- "all" is a virtual view, not a list you can create tasks in — pick a real listId.
- Subtasks: at most one level (parent root → child). Use parentId only for roots.
- For priority: use reorder_tasks (first id = highest priority / top of list).
- Do not invent ids. If something is ambiguous, ask a short clarifying question.
- Be concise.

Current workspace snapshot (may be slightly stale; call get_workspace if needed):
$pretty
''';
}
