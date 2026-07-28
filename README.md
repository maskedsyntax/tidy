# Tidy

A polished desktop Todo app for **macOS** and **Linux**, built with Flutter.

## Features

- **Multiple lists** with colored icons (Work, Personal, Learning, …)
- **All Tasks** aggregate view with list badges so you can see which list each task belongs to
- **Nested subtasks** — press **Tab** to indent, **Shift+Tab** to outdent
- **Themes**: System (default), Light, Dark
- **Command palette** (`⌘K` / `Ctrl+K`) to switch theme, navigate lists, create lists, and more
- **AI assistant pane** (BYOK) — control lists/tasks with natural language via Groq, xAI, OpenAI, or any OpenAI-compatible API
- **Adaptive layout** — hide lists and/or assistant for a pen-and-paper focus mode, or open both for a full AI workspace (layout is remembered)
- Local JSON persistence (survives restarts)
- Smooth desktop interactions and animations

## Keyboard shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘/Ctrl+K` | Command palette |
| `⌘/Ctrl+B` | Toggle lists sidebar |
| `⌘/Ctrl+J` | Toggle AI assistant pane |
| `⌘/Ctrl+.` | Focus mode (tasks only) |
| `⌘/Ctrl+⇧.` | Full mode (all panes) |
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

## AI assistant (BYOK)

1. Open **Settings** (gear) → **AI**.
2. Pick a provider (Groq is default) or set a custom base URL + model.
3. Paste your API key (stored only on this machine in app support data).
4. Ask things like:
   - “Move Workout to Work”
   - “Create a list called Errands”
   - “Reorder Learning tasks by importance”
   - “Mark Design app UI incomplete”

The model uses tool calls against your local workspace (create/update/delete lists & tasks, move, reorder, switch list).

## Project layout

```
lib/
  main.dart / app.dart
  core/          theme, icons, persistence, shortcuts
  domain/        Task, TodoList, AppSettings, AiSettings
  data/          repositories
  state/         Riverpod controllers
  ai/            OpenAI-compatible client, tools, executor
  ui/            shell, sidebar, tasks, chat, palette, dialogs
  seed/          first-launch demo data
website/         SvelteKit marketing site (static, SEO-ready)
```

## Website

Marketing site lives in [`website/`](website/) (SvelteKit + static adapter).

```bash
cd website
npm install
npm run dev      # local preview
npm run build    # writes website/build
```

Tagline: *As minimal as pen and paper. As maximal as AI can go.*

See [website/README.md](website/README.md) for SEO notes and deploy tips. Set `site.url` in `website/src/lib/seo.ts` before production.

## License

See [LICENSE](LICENSE).
