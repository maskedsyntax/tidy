import 'package:tidy/core/persistence/json_store.dart';
import 'package:tidy/domain/models/task.dart';
import 'package:tidy/domain/models/todo_list.dart';

class TodoSnapshot {
  const TodoSnapshot({required this.lists, required this.tasks});

  final List<TodoList> lists;
  final List<Task> tasks;
}

class TodoRepository {
  TodoRepository({JsonStore? store})
      : _store = store ?? JsonStore(fileName: 'todos.json');

  final JsonStore _store;

  Future<TodoSnapshot> load() async {
    final data = await _store.read();
    if (data == null) {
      // Fresh install: empty workspace (no seed/demo data).
      return const TodoSnapshot(lists: [], tasks: []);
    }
    try {
      final lists = (data['lists'] as List<dynamic>)
          .map((e) => TodoList.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      final tasks = (data['tasks'] as List<dynamic>)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
      return TodoSnapshot(lists: lists, tasks: tasks);
    } catch (_) {
      // Corrupt file: start empty rather than re-seeding demo content.
      return const TodoSnapshot(lists: [], tasks: []);
    }
  }

  Future<void> save({
    required List<TodoList> lists,
    required List<Task> tasks,
  }) async {
    await _store.write({
      'lists': lists.map((e) => e.toJson()).toList(),
      'tasks': tasks.map((e) => e.toJson()).toList(),
    });
  }
}
