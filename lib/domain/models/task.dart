import 'package:equatable/equatable.dart';

class Task extends Equatable {
  const Task({
    required this.id,
    required this.listId,
    this.parentId,
    required this.title,
    this.completed = false,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String listId;
  final String? parentId;
  final String title;
  final bool completed;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isRoot => parentId == null;

  Task copyWith({
    String? id,
    String? listId,
    String? parentId,
    bool clearParentId = false,
    String? title,
    bool? completed,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      parentId: clearParentId ? null : (parentId ?? this.parentId),
      title: title ?? this.title,
      completed: completed ?? this.completed,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'listId': listId,
        'parentId': parentId,
        'title': title,
        'completed': completed,
        'sortOrder': sortOrder,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      listId: json['listId'] as String,
      parentId: json['parentId'] as String?,
      title: json['title'] as String,
      completed: json['completed'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props =>
      [id, listId, parentId, title, completed, sortOrder, createdAt, updatedAt];
}

/// A task node with resolved children for tree rendering.
class TaskNode {
  TaskNode({required this.task, List<TaskNode>? children})
      : children = children ?? [];

  final Task task;
  final List<TaskNode> children;

  int get depth => 0; // set by builder when needed
}

/// Flattened row for list rendering with depth.
class TaskRowData {
  const TaskRowData({
    required this.task,
    required this.depth,
  });

  final Task task;
  final int depth;
}
