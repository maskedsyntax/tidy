<script lang="ts">
	import { untrack } from 'svelte';

	/* A working recreation of the Tidy desktop UI — same three-pane shell,
	   same rows, badges and toolbar as the app, tinted to the site's warm palette
	   so it sits on the page instead of punching a white hole in it. */

	type Mode = 'paper' | 'power' | 'ai';
	type ListKey = 'work' | 'personal' | 'learning' | 'travel';

	let { mode = 'ai' }: { mode?: Mode } = $props();

	type MockList = { id: ListKey; name: string; icon: string; color: string };
	type MockTask = { id: number; list: ListKey; title: string; done: boolean; depth: number };

	const baseLists: MockList[] = [
		{ id: 'work', name: 'Work', icon: 'briefcase', color: 'var(--m-blue)' },
		{ id: 'personal', name: 'Personal', icon: 'home', color: 'var(--m-green)' },
		{ id: 'learning', name: 'Learning', icon: 'cap', color: 'var(--m-purple)' }
	];

	const baseTasks: MockTask[] = [
		{ id: 1, list: 'work', title: 'Build Todo app', done: false, depth: 0 },
		{ id: 2, list: 'work', title: 'Design app UI', done: true, depth: 0 },
		{ id: 3, list: 'work', title: 'Implement task CRUD', done: false, depth: 0 },
		{ id: 4, list: 'work', title: 'Add keyboard shortcuts', done: false, depth: 0 },
		{ id: 5, list: 'work', title: 'Tab to indent', done: false, depth: 1 },
		{ id: 6, list: 'work', title: 'Enter to add', done: true, depth: 1 },
		{ id: 7, list: 'work', title: 'Cmd+K for command palette', done: false, depth: 1 },
		{ id: 8, list: 'personal', title: 'Read a book', done: false, depth: 0 },
		{ id: 9, list: 'personal', title: 'Workout', done: true, depth: 0 },
		{ id: 10, list: 'learning', title: 'Learn Rust', done: false, depth: 0 },
		{ id: 11, list: 'learning', title: 'Build a side project', done: false, depth: 0 }
	];

	let lists = $state<MockList[]>([...baseLists]);
	let tasks = $state<MockTask[]>(baseTasks.map((t) => ({ ...t })));
	let active = $state<'all' | ListKey>('all');
	let search = $state('');
	let listsOpen = $state(untrack(() => mode !== 'paper'));
	let chatOpen = $state(untrack(() => mode === 'ai'));

	type Msg = { role: 'user' | 'assistant' | 'note'; text: string };
	let messages = $state<Msg[]>([]);
	let thinking = $state(false);
	let ran = $state(false);

	$effect(() => {
		listsOpen = mode !== 'paper';
		chatOpen = mode === 'ai';
	});

	const listById = (id: ListKey) => lists.find((l) => l.id === id);

	const visible = $derived(
		tasks.filter((t) => {
			if (active !== 'all' && t.list !== active) return false;
			if (search.trim() && !t.title.toLowerCase().includes(search.trim().toLowerCase()))
				return false;
			return true;
		})
	);

	const countFor = (id: 'all' | ListKey) =>
		tasks.filter((t) => t.depth === 0 && (id === 'all' || t.list === id)).length;

	const bothHidden = $derived(!listsOpen && !chatOpen);
	const bothOpen = $derived(listsOpen && chatOpen);
	const activeList = $derived(active === 'all' ? null : listById(active));
	const title = $derived(activeList?.name ?? 'All Tasks');

	function toggle(id: number) {
		const t = tasks.find((x) => x.id === id);
		if (t) t.done = !t.done;
	}

	function focusMode() {
		if (bothHidden) {
			listsOpen = true;
			chatOpen = true;
		} else {
			listsOpen = false;
			chatOpen = false;
		}
	}

	/* The assistant demo: a canned prompt that really rewrites the workspace,
	   the way the shipped tool-calling assistant does. */
	async function runDemo() {
		if (ran || thinking) return;
		ran = true;
		messages = [{ role: 'user', text: 'Plan a Travel list — pack, flights, hotel.' }];
		thinking = true;
		await new Promise((r) => setTimeout(r, 900));
		thinking = false;

		lists = [...lists, { id: 'travel', name: 'Travel', icon: 'plane', color: 'var(--m-teal)' }];
		messages = [...messages, { role: 'note', text: 'Created list “Travel”' }];

		const added: MockTask[] = [
			{ id: 101, list: 'travel', title: 'Book flights', done: false, depth: 0 },
			{ id: 102, list: 'travel', title: 'Reserve hotel', done: false, depth: 0 },
			{ id: 103, list: 'travel', title: 'Packing', done: false, depth: 0 },
			{ id: 104, list: 'travel', title: 'Passport & adapters', done: false, depth: 1 },
			{ id: 105, list: 'travel', title: 'Chargers', done: false, depth: 1 }
		];
		for (const t of added) {
			tasks = [...tasks, t];
			await new Promise((r) => setTimeout(r, 130));
		}
		active = 'travel';
		messages = [
			...messages,
			{ role: 'note', text: 'Added 5 tasks · nested 2 subtasks' },
			{
				role: 'assistant',
				text: 'Created Travel with flights, hotel and a Packing group — passport, adapters and chargers nested underneath.'
			}
		];
	}

	function reset() {
		lists = [...baseLists];
		tasks = baseTasks.map((t) => ({ ...t }));
		active = 'all';
		search = '';
		messages = [];
		ran = false;
	}

	const ICONS: Record<string, string> = {
		briefcase: '<path d="M4 8.5h16v10.5H4z"/><path d="M9 8.5V6h6v2.5"/>',
		home: '<path d="M4 11l8-6 8 6v8H4z"/>',
		cap: '<path d="M3 9.5l9-4 9 4-9 4z"/><path d="M7.5 12v3.5c0 1 2 1.8 4.5 1.8s4.5-.8 4.5-1.8V12"/>',
		plane: '<path d="M4 13.5l16-6-5.5 12-2.5-4.5z"/><path d="M11.8 15l-3.3 3.2v-4"/>',
		infinity:
			'<path d="M8.2 9.4c1.6 0 2.3 1.1 2.6 2.6.3 1.5 1 2.6 2.6 2.6a2.6 2.6 0 0 0 0-5.2c-1.6 0-2.3 1.1-2.6 2.6-.3 1.5-1 2.6-2.6 2.6a2.6 2.6 0 0 1 0-5.2z"/>',
		sidebar: '<path d="M4 5.5h16v13H4z"/><path d="M10 5.5v13"/>',
		focus:
			'<path d="M4.5 8.5V5h3.5"/><path d="M16 5h3.5v3.5"/><path d="M19.5 15.5V19H16"/><path d="M8 19H4.5v-3.5"/><circle cx="12" cy="12" r="2.2"/>',
		sparkle: '<path d="M12 5.2l1.7 4.6 4.6 1.7-4.6 1.7-1.7 4.6-1.7-4.6-4.6-1.7 4.6-1.7z"/>',
		search: '<circle cx="11" cy="11" r="5.8"/><path d="M19.5 19.5l-4.2-4.2"/>',
		trash: '<path d="M5.5 7.5h13"/><path d="M9.5 7.5V5.5h5v2"/><path d="M7.5 7.5l.9 11h7.2l.9-11"/>',
		tune: '<path d="M4 8h16"/><path d="M4 16h16"/><circle cx="9.5" cy="8" r="1.9"/><circle cx="15" cy="16" r="1.9"/>',
		plus: '<path d="M12 5.5v13"/><path d="M5.5 12h13"/>',
		up: '<path d="M12 19V6"/><path d="M6.5 11.5L12 6l5.5 5.5"/>',
		gear: '<circle cx="12" cy="12" r="3"/><path d="M12 4v2.2M12 17.8V20M4 12h2.2M17.8 12H20M6.3 6.3l1.6 1.6M16.1 16.1l1.6 1.6M17.7 6.3l-1.6 1.6M7.9 16.1l-1.6 1.6"/>',
		sun: '<circle cx="12" cy="12" r="3.5"/><path d="M12 4.5v1.8M12 17.7v1.8M4.5 12h1.8M17.7 12h1.8M6.6 6.6l1.3 1.3M16.1 16.1l1.3 1.3M17.4 6.6l-1.3 1.3M7.9 16.1l-1.3 1.3"/>'
	};
</script>

<div class="app" class:no-lists={!listsOpen} class:no-chat={!chatOpen}>
	{#if listsOpen}
		<aside class="pane sidebar">
			<div class="pane-head">
				<span class="pane-title">Lists</span>
				<span class="spacer"></span>
				<span class="kbd">⌘K</span>
				<button class="icon-btn" title="Hide lists" onclick={() => (listsOpen = false)}>
					<svg viewBox="0 0 24 24">{@html ICONS.sidebar}</svg>
				</button>
			</div>
			<div class="rule"></div>
			<div class="side-label">LISTS</div>
			<div class="side-scroll">
				<button class="nav" class:sel={active === 'all'} onclick={() => (active = 'all')}>
					<svg class="ico" viewBox="0 0 24 24">{@html ICONS.infinity}</svg>
					<span class="nav-name">All Tasks</span>
					<span class="count">{countFor('all')}</span>
				</button>
				{#each lists as l (l.id)}
					<button class="nav" class:sel={active === l.id} onclick={() => (active = l.id)}>
						<svg class="ico" viewBox="0 0 24 24" style:color={l.color}>{@html ICONS[l.icon]}</svg>
						<span class="nav-name">{l.name}</span>
						<span class="count">{countFor(l.id)}</span>
					</button>
				{/each}
				<div class="nav muted-row">
					<svg class="ico" viewBox="0 0 24 24">{@html ICONS.plus}</svg>
					<span class="nav-name">New List</span>
				</div>
			</div>
			<div class="pane-foot">
				<span class="icon-btn"><svg viewBox="0 0 24 24">{@html ICONS.gear}</svg></span>
				<span class="icon-btn"><svg viewBox="0 0 24 24">{@html ICONS.sun}</svg></span>
				<span class="spacer"></span>
				<button
					class="icon-btn"
					title={chatOpen ? 'Hide assistant' : 'Show assistant'}
					onclick={() => (chatOpen = !chatOpen)}
				>
					<svg viewBox="0 0 24 24">{@html ICONS.sparkle}</svg>
				</button>
			</div>
		</aside>
	{/if}

	<section class="pane main">
		<div class="toolbar">
			<button
				class="icon-btn"
				class:on={listsOpen}
				title="Toggle lists"
				onclick={() => (listsOpen = !listsOpen)}
			>
				<svg viewBox="0 0 24 24">{@html ICONS.sidebar}</svg>
			</button>
			<button class="icon-btn" class:on={bothHidden} title="Focus mode" onclick={focusMode}>
				<svg viewBox="0 0 24 24">{@html ICONS.focus}</svg>
			</button>
			<button
				class="icon-btn"
				class:on={chatOpen}
				title="Toggle assistant"
				onclick={() => (chatOpen = !chatOpen)}
			>
				<svg viewBox="0 0 24 24">{@html ICONS.sparkle}</svg>
			</button>

			<svg class="ico title-ico" viewBox="0 0 24 24" style:color={activeList?.color ?? 'currentColor'}
				>{@html activeList ? ICONS[activeList.icon] : ICONS.infinity}</svg
			>
			<span class="view-title">{title}</span>
			{#if bothHidden}<span class="tag">Focus</span>{/if}
			{#if bothOpen}<span class="tag">Full</span>{/if}

			<span class="spacer"></span>
			<label class="search">
				<svg class="ico" viewBox="0 0 24 24">{@html ICONS.search}</svg>
				<input bind:value={search} placeholder="Search" aria-label="Search tasks" />
			</label>
		</div>

		<div class="rows">
			{#each visible as t, i (t.id)}
				{@const prev = visible[i - 1]}
				{#if active === 'all' && t.depth === 0 && prev && prev.list !== t.list}
					<div class="row-rule"></div>
				{/if}
				<div class="row" class:done={t.done} style:padding-left="{0.9 + t.depth * 1.5}rem">
					<button
						class="check"
						class:on={t.done}
						aria-pressed={t.done}
						aria-label={t.title}
						onclick={() => toggle(t.id)}
					>
						<svg viewBox="0 0 24 24"><path d="M5.5 12.5l4 4 9-9" /></svg>
					</button>
					<span class="row-title">{t.title}</span>
					{#if active === 'all'}
						{@const l = listById(t.list)}
						{#if l}
							<span class="badge" style:color={l.color}>
								<svg class="ico" viewBox="0 0 24 24">{@html ICONS[l.icon]}</svg>
								{l.name}
							</span>
						{/if}
					{/if}
				</div>
			{:else}
				<div class="empty">No matches</div>
			{/each}
		</div>

		<div class="composer">
			<svg class="ico" viewBox="0 0 24 24">{@html ICONS.plus}</svg>
			<span>Add a new task…</span>
		</div>
	</section>

	{#if chatOpen}
		<aside class="pane chat">
			<div class="pane-head">
				<svg class="ico accent" viewBox="0 0 24 24">{@html ICONS.sparkle}</svg>
				<span class="pane-title">Assistant</span>
				<span class="spacer"></span>
				<button class="icon-btn" title="Clear chat" onclick={reset}>
					<svg viewBox="0 0 24 24">{@html ICONS.trash}</svg>
				</button>
				<span class="icon-btn"><svg viewBox="0 0 24 24">{@html ICONS.tune}</svg></span>
				<button class="icon-btn" title="Hide assistant" onclick={() => (chatOpen = false)}>
					<svg viewBox="0 0 24 24">{@html ICONS.sidebar}</svg>
				</button>
			</div>
			<div class="rule"></div>

			<div class="msgs">
				{#if messages.length === 0}
					<div class="chat-empty">
						<svg class="ico big" viewBox="0 0 24 24">{@html ICONS.sparkle}</svg>
						<p class="ce-title">Control Tidy with natural language</p>
						<p class="ce-body">Try the prompt below — it really edits this workspace.</p>
					</div>
				{:else}
					{#each messages as m}
						{#if m.role === 'note'}
							<div class="note">{m.text}</div>
						{:else}
							<div class="bubble" data-role={m.role}>{m.text}</div>
						{/if}
					{/each}
				{/if}
				{#if thinking}<div class="note">Thinking…</div>{/if}
			</div>

			{#if !ran}
				<button class="prompt-chip" onclick={runDemo}>
					“Plan a Travel list — pack, flights, hotel.”
				</button>
			{/if}

			<div class="chat-composer">
				<span class="fake-input">Ask to manage lists &amp; tasks…</span>
				<button class="send" onclick={ran ? reset : runDemo} title={ran ? 'Reset' : 'Send'}>
					<svg viewBox="0 0 24 24">{@html ICONS.up}</svg>
				</button>
			</div>
		</aside>
	{/if}
</div>

<style>
	.app {
		/* Warm-shifted mirror of the app's own tokens */
		--m-surface: var(--clay-bright);
		--m-app: color-mix(in srgb, var(--sand) 42%, var(--clay));
		--m-hover: color-mix(in srgb, var(--sand) 30%, var(--clay-bright));
		--m-sel: color-mix(in srgb, var(--sand) 52%, var(--clay-bright));
		--m-border: color-mix(in srgb, var(--sand-deep) 42%, transparent);
		--m-input: color-mix(in srgb, var(--sand) 26%, var(--clay-bright));
		--m-blue: #5b8ac4;
		--m-green: #5f9e73;
		--m-purple: #8f76ba;
		--m-teal: #5c9aa6;

		display: flex;
		gap: 0.45rem;
		padding: 0.45rem;
		background: var(--m-app);
		border: 1px solid color-mix(in srgb, var(--sand-deep) 50%, transparent);
		border-radius: var(--radius-lg);
		box-shadow: var(--shadow-lg), var(--shadow-inset);
		font-size: 0.8125rem;
		color: var(--text);
		overflow: hidden;
	}

	@media (min-width: 700px) {
		.app {
			aspect-ratio: 1100 / 700;
		}
	}

	.pane {
		background: var(--m-surface);
		border: 1px solid var(--m-border);
		border-radius: 14px;
		display: flex;
		flex-direction: column;
		min-width: 0;
		overflow: hidden;
	}

	.main {
		flex: 1;
	}

	.sidebar {
		width: 12.5rem;
		flex-shrink: 0;
	}

	.chat {
		width: 14.5rem;
		flex-shrink: 0;
	}

	@media (max-width: 700px) {
		.sidebar,
		.chat {
			display: none;
		}
	}

	.pane-head {
		display: flex;
		align-items: center;
		gap: 0.3rem;
		padding: 0.55rem 0.5rem 0.5rem 0.7rem;
	}

	.pane-title {
		font-weight: 600;
		font-size: 0.82rem;
	}

	.spacer {
		flex: 1;
	}

	.rule {
		height: 1px;
		background: var(--m-border);
	}

	.side-label {
		padding: 0.6rem 0.85rem 0.35rem;
		font-size: 0.6rem;
		font-weight: 600;
		letter-spacing: 0.06em;
		color: var(--text-faint);
	}

	.side-scroll {
		flex: 1;
		padding: 0 0.45rem;
		overflow: hidden;
	}

	.nav {
		display: flex;
		align-items: center;
		gap: 0.45rem;
		width: 100%;
		padding: 0.4rem 0.5rem;
		margin-bottom: 0.1rem;
		border: 0;
		border-radius: 8px;
		background: transparent;
		font: inherit;
		font-size: 0.78rem;
		font-weight: 500;
		color: var(--text);
		text-align: left;
		cursor: pointer;
		transition: background 0.12s ease;
	}

	.nav:hover {
		background: var(--m-hover);
	}

	.nav.sel {
		background: var(--m-sel);
		font-weight: 600;
	}

	.nav-name {
		flex: 1;
		min-width: 0;
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}

	.muted-row {
		color: var(--text-muted);
		cursor: default;
	}

	.muted-row:hover {
		background: transparent;
	}

	.count {
		font-size: 0.7rem;
		color: var(--text-muted);
	}

	.pane-foot {
		display: flex;
		align-items: center;
		gap: 0.15rem;
		padding: 0.5rem 0.55rem 0.6rem;
	}

	/* Icons */
	svg {
		width: 1.05rem;
		height: 1.05rem;
		fill: none;
		stroke: currentColor;
		stroke-width: 1.7;
		stroke-linecap: round;
		stroke-linejoin: round;
	}

	.ico {
		color: var(--text-muted);
		flex-shrink: 0;
	}

	.ico.accent {
		color: var(--m-blue);
	}

	.icon-btn {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		padding: 0.25rem;
		border: 0;
		border-radius: 7px;
		background: transparent;
		color: var(--text-muted);
		cursor: pointer;
		transition: background 0.12s ease, color 0.12s ease;
	}

	button.icon-btn:hover {
		background: var(--m-hover);
		color: var(--text);
	}

	.icon-btn.on {
		background: var(--m-sel);
		color: var(--text);
	}

	.kbd {
		font-family: var(--font-mono);
		font-size: 0.62rem;
		font-weight: 600;
		color: var(--text-muted);
		padding: 0.1rem 0.25rem;
	}

	/* Toolbar */
	.toolbar {
		display: flex;
		align-items: center;
		gap: 0.2rem;
		padding: 0.5rem 0.65rem 0.45rem;
	}

	.title-ico {
		margin-left: 0.45rem;
		color: var(--text);
	}

	.view-title {
		margin-left: 0.35rem;
		font-size: 0.88rem;
		font-weight: 600;
		letter-spacing: -0.01em;
	}

	.tag {
		margin-left: 0.4rem;
		padding: 0.1rem 0.35rem;
		border-radius: 5px;
		background: var(--m-hover);
		font-size: 0.62rem;
		font-weight: 600;
		color: var(--text-muted);
	}

	.search {
		display: flex;
		align-items: center;
		gap: 0.35rem;
		width: 9.5rem;
		padding: 0.32rem 0.5rem;
		border-radius: 8px;
		background: var(--m-input);
	}

	.search svg {
		width: 0.9rem;
		height: 0.9rem;
	}

	.search input {
		width: 100%;
		min-width: 0;
		border: 0;
		background: none;
		font: inherit;
		font-size: 0.76rem;
		color: var(--text);
		outline: none;
	}

	.search input::placeholder {
		color: var(--text-faint);
	}

	/* Task rows — plain rows with hover, exactly like the app */
	.rows {
		flex: 1;
		padding: 0.2rem 0.5rem;
		overflow: hidden;
	}

	.row {
		display: flex;
		align-items: center;
		gap: 0.45rem;
		padding: 0.3rem 0.55rem;
		border-radius: 8px;
		transition: background 0.12s ease;
	}

	.row:hover {
		background: var(--m-hover);
	}

	.row-rule {
		height: 1px;
		margin: 0.4rem 0.75rem;
		background: var(--m-border);
	}

	.row-title {
		flex: 1;
		min-width: 0;
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
		font-size: 0.82rem;
	}

	.row.done .row-title {
		text-decoration: line-through;
		color: var(--text-muted);
	}

	.check {
		display: grid;
		place-items: center;
		width: 1.05rem;
		height: 1.05rem;
		flex-shrink: 0;
		padding: 0;
		border: 1.5px solid color-mix(in srgb, var(--text-muted) 55%, transparent);
		border-radius: 5px;
		background: transparent;
		cursor: pointer;
		transition: background 0.12s ease, border-color 0.12s ease;
	}

	.check svg {
		width: 0.72rem;
		height: 0.72rem;
		stroke: #fff;
		stroke-width: 2.6;
		opacity: 0;
		transform: scale(0.7);
		transition: opacity 0.12s ease, transform 0.12s ease;
	}

	.check.on {
		background: var(--m-blue);
		border-color: var(--m-blue);
	}

	.check.on svg {
		opacity: 1;
		transform: scale(1);
	}

	.badge {
		display: inline-flex;
		align-items: center;
		gap: 0.28rem;
		font-size: 0.72rem;
		font-weight: 500;
		flex-shrink: 0;
	}

	.badge svg {
		width: 0.85rem;
		height: 0.85rem;
	}

	.empty {
		padding: 2rem 0;
		text-align: center;
		font-size: 0.8rem;
		color: var(--text-faint);
	}

	.composer {
		display: flex;
		align-items: center;
		gap: 0.45rem;
		padding: 0.55rem 1rem 0.65rem;
		border-top: 1px solid var(--m-border);
		font-size: 0.8rem;
		color: var(--text-faint);
	}

	/* Chat */
	.msgs {
		flex: 1;
		display: flex;
		flex-direction: column;
		gap: 0.3rem;
		padding: 0.6rem;
		overflow: hidden;
	}

	.chat-empty {
		margin: auto;
		text-align: center;
		padding: 0.5rem;
	}

	.ico.big {
		width: 1.6rem;
		height: 1.6rem;
		margin: 0 auto 0.5rem;
		opacity: 0.55;
	}

	.ce-title {
		margin: 0 0 0.3rem;
		font-size: 0.78rem;
		font-weight: 600;
	}

	.ce-body {
		margin: 0;
		font-size: 0.72rem;
		line-height: 1.45;
		color: var(--text-muted);
	}

	.bubble {
		max-width: 88%;
		padding: 0.4rem 0.55rem;
		border-radius: 10px;
		font-size: 0.75rem;
		line-height: 1.4;
	}

	.bubble[data-role='user'] {
		align-self: flex-end;
		border-bottom-right-radius: 4px;
		background: color-mix(in srgb, var(--m-blue) 18%, var(--clay-bright));
	}

	.bubble[data-role='assistant'] {
		align-self: flex-start;
		border-bottom-left-radius: 4px;
		background: var(--m-hover);
		color: var(--text-muted);
	}

	.note {
		align-self: center;
		padding: 0.18rem 0.5rem;
		border-radius: 20px;
		background: var(--m-hover);
		font-size: 0.66rem;
		color: var(--text-muted);
	}

	.prompt-chip {
		margin: 0 0.6rem 0.5rem;
		padding: 0.45rem 0.6rem;
		border: 1px dashed color-mix(in srgb, var(--m-blue) 45%, transparent);
		border-radius: 10px;
		background: color-mix(in srgb, var(--m-blue) 9%, transparent);
		font: inherit;
		font-size: 0.72rem;
		line-height: 1.35;
		color: var(--accent-ink);
		text-align: left;
		cursor: pointer;
		transition: background 0.15s ease;
	}

	.prompt-chip:hover {
		background: color-mix(in srgb, var(--m-blue) 16%, transparent);
	}

	.chat-composer {
		display: flex;
		align-items: center;
		gap: 0.4rem;
		padding: 0 0.6rem 0.6rem;
	}

	.fake-input {
		flex: 1;
		min-width: 0;
		padding: 0.45rem 0.55rem;
		border-radius: 9px;
		background: var(--m-input);
		font-size: 0.72rem;
		color: var(--text-faint);
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}

	.send {
		display: grid;
		place-items: center;
		width: 1.85rem;
		height: 1.85rem;
		flex-shrink: 0;
		border: 0;
		border-radius: 8px;
		background: var(--m-blue);
		color: #fff;
		cursor: pointer;
	}

	.send svg {
		width: 0.95rem;
		height: 0.95rem;
		stroke-width: 2.2;
	}
</style>
