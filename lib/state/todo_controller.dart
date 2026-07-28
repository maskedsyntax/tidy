import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tidy/data/todo_repository.dart';
import 'package:tidy/domain/models/task.dart';
import 'package:tidy/domain/models/todo_list.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class TodoState {
  const TodoState({
    this.lists = const [],
    this.tasks = const [],
    this.loaded = false,
  });

  final List<TodoList> lists;
  final List<Task> tasks;
  final bool loaded;

  TodoState copyWith({
    List<TodoList>? lists,
    List<Task>? tasks,
    bool? loaded,
  }) {
    return TodoState(
      lists: lists ?? this.lists,
      tasks: tasks ?? this.tasks,
      loaded: loaded ?? this.loaded,
    );
  }

  TodoList? listById(String id) {
    for (final l in lists) {
      if (l.id == id) return l;
    }
    return null;
  }

  Task? taskById(String id) {
    for (final t in tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  int countForList(String listId) {
    if (listId == kAllTasksListId) {
      return tasks.where((t) => t.parentId == null).length;
    }
    return tasks.where((t) => t.listId == listId && t.parentId == null).length;
  }

  /// Root tasks for a list (or all), sorted, with nested children as flat rows.
  List<TaskRowData> rowsFor({
    required String listId,
    String search = '',
  }) {
    final query = search.trim().toLowerCase();

    // For All Tasks, order by list sort then task sort so badges group nicely.
    final listOrder = {for (var i = 0; i < lists.length; i++) lists[i].id: i};

    final roots = tasks.where((t) {
      if (t.parentId != null) return false;
      if (listId != kAllTasksListId && t.listId != listId) return false;
      return true;
    }).toList()
      ..sort((a, b) {
        if (listId == kAllTasksListId) {
          final la = listOrder[a.listId] ?? 999;
          final lb = listOrder[b.listId] ?? 999;
          if (la != lb) return la.compareTo(lb);
        }
        return a.sortOrder.compareTo(b.sortOrder);
      });

    final result = <TaskRowData>[];

    void walk(Task task, int depth) {
      final children = tasks.where((t) => t.parentId == task.id).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      if (query.isEmpty) {
        result.add(TaskRowData(task: task, depth: depth));
        for (final c in children) {
          result.add(TaskRowData(task: c, depth: depth + 1));
        }
        return;
      }

      final selfMatches = task.title.toLowerCase().contains(query);
      final matchingChildren = children
          .where((c) => c.title.toLowerCase().contains(query))
          .toList();

      if (selfMatches || matchingChildren.isNotEmpty) {
        result.add(TaskRowData(task: task, depth: depth));
        final shown = selfMatches ? children : matchingChildren;
        for (final c in shown) {
          result.add(TaskRowData(task: c, depth: depth + 1));
        }
      }
    }

    for (final root in roots) {
      walk(root, 0);
    }
    return result;
  }

  List<Task> siblingsOf(Task task) {
    return tasks
        .where((t) => t.parentId == task.parentId && t.listId == task.listId)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}

class TodoController extends StateNotifier<TodoState> {
  TodoController(this._repo) : super(const TodoState()) {
    _init();
  }

  final TodoRepository _repo;
  Timer? _debounce;
  String? pendingFocusTaskId;

  Future<void> _init() async {
    final snap = await _repo.load();
    state = TodoState(lists: snap.lists, tasks: snap.tasks, loaded: true);
  }

  Future<void> _persist() async {
    await _repo.save(lists: state.lists, tasks: state.tasks);
  }

  void _persistDebounced() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _persist);
  }

  Future<void> _persistNow() async {
    _debounce?.cancel();
    await _persist();
  }

  // ── Lists ──────────────────────────────────────────────────────────────

  Future<TodoList> createList({
    required String name,
    required String iconKey,
    required int colorValue,
  }) async {
    final list = TodoList(
      id: _uuid.v4(),
      name: name.trim().isEmpty ? 'Untitled' : name.trim(),
      iconKey: iconKey,
      colorValue: colorValue,
      sortOrder: state.lists.length,
    );
    state = state.copyWith(lists: [...state.lists, list]);
    await _persistNow();
    return list;
  }

  Future<void> renameList(String id, String name) async {
    state = state.copyWith(
      lists: [
        for (final l in state.lists)
          if (l.id == id) l.copyWith(name: name.trim()) else l,
      ],
    );
    await _persistNow();
  }

  Future<void> deleteList(String id) async {
    state = state.copyWith(
      lists: state.lists.where((l) => l.id != id).toList(),
      tasks: state.tasks.where((t) => t.listId != id).toList(),
    );
    await _persistNow();
  }

  // ── Tasks ──────────────────────────────────────────────────────────────

  Future<Task> addTask({
    required String listId,
    String? parentId,
    String title = '',
    int? sortOrder,
    bool focus = true,
  }) async {
    final effectiveListId =
        listId == kAllTasksListId ? (state.lists.isNotEmpty ? state.lists.first.id : listId) : listId;

    // If All Tasks, default to first real list
    final resolvedListId = effectiveListId == kAllTasksListId
        ? state.lists.first.id
        : effectiveListId;

    final siblings = state.tasks
        .where((t) => t.parentId == parentId && t.listId == resolvedListId)
        .toList();
    final order = sortOrder ?? siblings.length;
    final now = DateTime.now();
    final task = Task(
      id: _uuid.v4(),
      listId: resolvedListId,
      parentId: parentId,
      title: title,
      sortOrder: order,
      createdAt: now,
      updatedAt: now,
    );

    // Shift siblings if inserting mid-list
    final updated = state.tasks.map((t) {
      if (t.parentId == parentId &&
          t.listId == resolvedListId &&
          t.sortOrder >= order) {
        return t.copyWith(sortOrder: t.sortOrder + 1, updatedAt: now);
      }
      return t;
    }).toList()
      ..add(task);

    state = state.copyWith(tasks: updated);
    if (focus) pendingFocusTaskId = task.id;
    await _persistNow();
    return task;
  }

  Future<void> updateTitle(String id, String title) async {
    final now = DateTime.now();
    state = state.copyWith(
      tasks: [
        for (final t in state.tasks)
          if (t.id == id)
            t.copyWith(title: title, updatedAt: now)
          else
            t,
      ],
    );
    _persistDebounced();
  }

  Future<void> toggleComplete(String id) async {
    final task = state.taskById(id);
    if (task == null) return;
    await setCompleted(id, !task.completed);
  }

  Future<void> setCompleted(String id, bool completed) async {
    final now = DateTime.now();
    state = state.copyWith(
      tasks: [
        for (final t in state.tasks)
          if (t.id == id)
            t.copyWith(completed: completed, updatedAt: now)
          else
            t,
      ],
    );
    await _persistNow();
  }

  Future<void> updateList({
    required String id,
    String? name,
    String? iconKey,
    int? colorValue,
  }) async {
    state = state.copyWith(
      lists: [
        for (final l in state.lists)
          if (l.id == id)
            l.copyWith(
              name: name?.trim().isNotEmpty == true ? name!.trim() : null,
              iconKey: iconKey,
              colorValue: colorValue,
            )
          else
            l,
      ],
    );
    await _persistNow();
  }

  /// Reorder root tasks (or siblings under [parentId]) to match [orderedIds].
  Future<void> reorderTasks({
    required String listId,
    String? parentId,
    required List<String> orderedIds,
  }) async {
    final now = DateTime.now();
    final orderMap = <String, int>{
      for (var i = 0; i < orderedIds.length; i++) orderedIds[i]: i,
    };
    state = state.copyWith(
      tasks: [
        for (final t in state.tasks)
          if (t.listId == listId &&
              t.parentId == parentId &&
              orderMap.containsKey(t.id))
            t.copyWith(sortOrder: orderMap[t.id]!, updatedAt: now)
          else
            t,
      ],
    );
    await _persistNow();
  }

  /// Snapshot for AI context (compact JSON-friendly map).
  Map<String, dynamic> snapshotForAi({String? activeListId}) {
    return {
      'activeListId': activeListId,
      'lists': [
        for (final l in state.lists)
          {
            'id': l.id,
            'name': l.name,
            'iconKey': l.iconKey,
            'color': '#${l.colorValue.toRadixString(16).padLeft(8, '0')}',
            'taskCount': state.countForList(l.id),
          },
      ],
      'tasks': [
        for (final t in state.tasks)
          {
            'id': t.id,
            'listId': t.listId,
            'parentId': t.parentId,
            'title': t.title,
            'completed': t.completed,
            'sortOrder': t.sortOrder,
          },
      ],
    };
  }

  Future<void> deleteTask(String id) async {
    // Also delete children
    final toRemove = <String>{id};
    bool grew = true;
    while (grew) {
      grew = false;
      for (final t in state.tasks) {
        if (t.parentId != null &&
            toRemove.contains(t.parentId) &&
            !toRemove.contains(t.id)) {
          toRemove.add(t.id);
          grew = true;
        }
      }
    }
    state = state.copyWith(
      tasks: state.tasks.where((t) => !toRemove.contains(t.id)).toList(),
    );
    await _persistNow();
  }

  /// Indent: make this task a child of the previous sibling.
  Future<bool> indent(String id) async {
    final task = state.taskById(id);
    if (task == null) return false;

    // Max depth 1 (root → subtask only)
    if (task.parentId != null) return false;

    final siblings = state.siblingsOf(task);
    final idx = siblings.indexWhere((t) => t.id == id);
    if (idx <= 0) return false;

    final newParent = siblings[idx - 1];
    final now = DateTime.now();
    final parentChildren = state.tasks
        .where((t) => t.parentId == newParent.id)
        .length;

    // Close gap among old siblings
    final updated = <Task>[];
    for (final t in state.tasks) {
      if (t.id == id) {
        updated.add(t.copyWith(
          parentId: newParent.id,
          sortOrder: parentChildren,
          updatedAt: now,
        ));
      } else if (t.parentId == task.parentId &&
          t.listId == task.listId &&
          t.sortOrder > task.sortOrder) {
        updated.add(t.copyWith(sortOrder: t.sortOrder - 1, updatedAt: now));
      } else {
        updated.add(t);
      }
    }
    state = state.copyWith(tasks: updated);
    await _persistNow();
    return true;
  }

  /// Outdent: promote to root (or parent of parent).
  Future<bool> outdent(String id) async {
    final task = state.taskById(id);
    if (task == null || task.parentId == null) return false;

    final parent = state.taskById(task.parentId!);
    if (parent == null) return false;

    final now = DateTime.now();
    final newParentId = parent.parentId; // null for our depth model
    final insertOrder = parent.sortOrder + 1;

    final updated = <Task>[];
    for (final t in state.tasks) {
      if (t.id == id) {
        updated.add(t.copyWith(
          clearParentId: newParentId == null,
          parentId: newParentId,
          sortOrder: insertOrder,
          updatedAt: now,
        ));
      } else if (t.parentId == task.parentId && t.sortOrder > task.sortOrder) {
        // Close gap under old parent
        updated.add(t.copyWith(sortOrder: t.sortOrder - 1, updatedAt: now));
      } else if (t.parentId == newParentId &&
          t.listId == task.listId &&
          t.sortOrder >= insertOrder &&
          t.id != id) {
        updated.add(t.copyWith(sortOrder: t.sortOrder + 1, updatedAt: now));
      } else {
        updated.add(t);
      }
    }

    state = state.copyWith(tasks: updated);
    await _persistNow();
    return true;
  }

  /// Create a sibling after [afterId] (or at end of roots).
  Future<Task> addSiblingAfter(String afterId) async {
    final after = state.taskById(afterId);
    if (after == null) {
      return addTask(listId: state.lists.first.id);
    }
    return addTask(
      listId: after.listId,
      parentId: after.parentId,
      sortOrder: after.sortOrder + 1,
    );
  }

  Future<void> moveTaskToList(String taskId, String listId) async {
    final task = state.taskById(taskId);
    if (task == null || task.listId == listId) return;
    final now = DateTime.now();

    // Move task + descendants
    final ids = <String>{taskId};
    bool grew = true;
    while (grew) {
      grew = false;
      for (final t in state.tasks) {
        if (t.parentId != null &&
            ids.contains(t.parentId) &&
            !ids.contains(t.id)) {
          ids.add(t.id);
          grew = true;
        }
      }
    }

    final rootOrder =
        state.tasks.where((t) => t.listId == listId && t.parentId == null).length;

    state = state.copyWith(
      tasks: [
        for (final t in state.tasks)
          if (ids.contains(t.id))
            t.copyWith(
              listId: listId,
              // Keep hierarchy; only root gets new sort at end if it was root
              sortOrder: t.id == taskId && t.parentId == null
                  ? rootOrder
                  : t.sortOrder,
              updatedAt: now,
            )
          else
            t,
      ],
    );
    await _persistNow();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final todoRepositoryProvider = Provider((ref) => TodoRepository());

final todoControllerProvider =
    StateNotifierProvider<TodoController, TodoState>((ref) {
  return TodoController(ref.watch(todoRepositoryProvider));
});
