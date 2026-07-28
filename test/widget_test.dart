import 'package:flutter_test/flutter_test.dart';
import 'package:tidy/domain/models/task.dart';
import 'package:tidy/domain/models/todo_list.dart';
import 'package:tidy/state/todo_controller.dart';

void main() {
  group('TodoState.rowsFor', () {
    late TodoState state;

    setUp(() {
      final now = DateTime(2026, 1, 1);
      state = TodoState(
        loaded: true,
        lists: const [
          TodoList(
            id: 'w',
            name: 'Work',
            iconKey: 'briefcase',
            colorValue: 0xFF3B82F6,
            sortOrder: 0,
          ),
        ],
        tasks: [
          Task(
            id: '1',
            listId: 'w',
            title: 'Parent',
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
          Task(
            id: '2',
            listId: 'w',
            parentId: '1',
            title: 'Child',
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
          Task(
            id: '3',
            listId: 'w',
            title: 'Other',
            sortOrder: 1,
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );
    });

    test('builds nested rows for a list', () {
      final rows = state.rowsFor(listId: 'w');
      expect(rows.map((r) => r.task.title).toList(),
          ['Parent', 'Child', 'Other']);
      expect(rows.map((r) => r.depth).toList(), [0, 1, 0]);
    });

    test('filters by search including ancestors', () {
      final rows = state.rowsFor(listId: 'w', search: 'Child');
      expect(rows.map((r) => r.task.title).toList(), ['Parent', 'Child']);
    });

    test('counts root tasks only', () {
      expect(state.countForList('w'), 2);
      expect(state.countForList(kAllTasksListId), 2);
    });
  });
}
