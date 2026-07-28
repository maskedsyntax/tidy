import 'package:tidy/core/theme/app_theme.dart';
import 'package:tidy/domain/models/task.dart';
import 'package:tidy/domain/models/todo_list.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class DemoData {
  static List<TodoList> lists() {
    return [
      TodoList(
        id: 'list-work',
        name: 'Work',
        iconKey: 'briefcase',
        colorValue: AppColors.work.toARGB32(),
        sortOrder: 0,
      ),
      TodoList(
        id: 'list-personal',
        name: 'Personal',
        iconKey: 'home',
        colorValue: AppColors.personal.toARGB32(),
        sortOrder: 1,
      ),
      TodoList(
        id: 'list-learning',
        name: 'Learning',
        iconKey: 'school',
        colorValue: AppColors.learning.toARGB32(),
        sortOrder: 2,
      ),
    ];
  }

  static List<Task> tasks() {
    final now = DateTime.now();
    String id() => _uuid.v4();

    // Work
    final buildTodo = id();
    final designUi = id();
    final implementCrud = id();
    final keyboard = id();
    final tabIndent = id();
    final enterAdd = id();
    final cmdK = id();

    // Personal
    final readBook = id();
    final workout = id();

    // Learning
    final learnRust = id();
    final sideProject = id();

    return [
      Task(
        id: buildTodo,
        listId: 'list-work',
        title: 'Build Todo app',
        completed: false,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: designUi,
        listId: 'list-work',
        title: 'Design app UI',
        completed: true,
        sortOrder: 1,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: implementCrud,
        listId: 'list-work',
        title: 'Implement task CRUD',
        completed: false,
        sortOrder: 2,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: keyboard,
        listId: 'list-work',
        title: 'Add keyboard shortcuts',
        completed: false,
        sortOrder: 3,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: tabIndent,
        listId: 'list-work',
        parentId: keyboard,
        title: 'Tab to indent',
        completed: false,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: enterAdd,
        listId: 'list-work',
        parentId: keyboard,
        title: 'Enter to add',
        completed: true,
        sortOrder: 1,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: cmdK,
        listId: 'list-work',
        parentId: keyboard,
        title: 'Cmd+K for command palette',
        completed: false,
        sortOrder: 2,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: readBook,
        listId: 'list-personal',
        title: 'Read a book',
        completed: false,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: workout,
        listId: 'list-personal',
        title: 'Workout',
        completed: true,
        sortOrder: 1,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: learnRust,
        listId: 'list-learning',
        title: 'Learn Rust',
        completed: false,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        id: sideProject,
        listId: 'list-learning',
        title: 'Build a side project',
        completed: false,
        sortOrder: 1,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
