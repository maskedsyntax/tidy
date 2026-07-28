# Tidy

A polished desktop Todo app for **macOS** and **Linux**, built with Flutter.

## Features

- **Multiple lists** with colored icons (Work, Personal, Learning, …)
- **All Tasks** aggregate view with list badges so you can see which list each task belongs to
- **Nested subtasks** — press **Tab** to indent, **Shift+Tab** to outdent
- **Themes**: System (default), Light, Dark
- **Command palette** (`⌘K` / `Ctrl+K`) to switch theme, navigate lists, create lists, and more
- Local JSON persistence (survives restarts)
- Smooth desktop interactions and animations

## Keyboard shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘/Ctrl+K` | Command palette |
| `⌘/Ctrl+1…9` | Switch list (1 = All Tasks) |
| `⌘/Ctrl+N` | New list |
| `Tab` | Indent task → subtask |
| `Shift+Tab` | Outdent |
| `Enter` | New sibling task (while editing) |
| `Esc` | Close palette |

## Run

Requirements: Flutter 3.22+ with desktop enabled.

```bash
# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

Release builds:

```bash
flutter build macos
flutter build linux
```

## Project layout

```
lib/
  main.dart / app.dart
  core/          theme, icons, persistence, shortcuts
  domain/        Task, TodoList, AppSettings
  data/          repositories
  state/         Riverpod controllers
  ui/            shell, sidebar, tasks, palette, dialogs
  seed/          first-launch demo data
```

## License

See [LICENSE](LICENSE).
