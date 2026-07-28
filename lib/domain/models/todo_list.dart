import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Virtual id for the aggregate "All Tasks" view (not persisted as a list).
const String kAllTasksListId = 'all';

class TodoList extends Equatable {
  const TodoList({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorValue,
    required this.sortOrder,
    this.isSystem = false,
  });

  final String id;
  final String name;
  final String iconKey;
  final int colorValue;
  final int sortOrder;
  final bool isSystem;

  Color get color => Color(colorValue);

  TodoList copyWith({
    String? id,
    String? name,
    String? iconKey,
    int? colorValue,
    int? sortOrder,
    bool? isSystem,
  }) {
    return TodoList(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      sortOrder: sortOrder ?? this.sortOrder,
      isSystem: isSystem ?? this.isSystem,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconKey': iconKey,
        'colorValue': colorValue,
        'sortOrder': sortOrder,
        'isSystem': isSystem,
      };

  factory TodoList.fromJson(Map<String, dynamic> json) {
    return TodoList(
      id: json['id'] as String,
      name: json['name'] as String,
      iconKey: json['iconKey'] as String,
      colorValue: json['colorValue'] as int,
      sortOrder: json['sortOrder'] as int,
      isSystem: json['isSystem'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, iconKey, colorValue, sortOrder, isSystem];
}
