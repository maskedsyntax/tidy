<script lang="ts">
	import AppMock from './AppMock.svelte';

	type Level = {
		id: 'paper' | 'power' | 'ai';
		label: string;
		title: string;
		body: string;
		points: string[];
		dot: string;
	};

	const levels: Level[] = [
		{
			id: 'paper',
			label: 'Pen & paper',
			title: 'Quiet by default',
			body: 'Open Tidy and write. No account, no feed, just a calm list on your machine. Collapse into focus mode when you want silence.',
			points: ['Type a task, check it off', 'Focus mode (⌘/Ctrl+.)', 'Local JSON · no signup'],
			dot: 'var(--dot-sage)'
		},
		{
			id: 'power',
			label: 'Desktop power',
			title: 'Structure when you need it',
			body: 'Colored lists, nested subtasks, and a command palette so your hands never leave the keyboard.',
			points: ['⌘K command palette', 'Tab indent · list badges', 'Toggle lists (⌘/Ctrl+B)'],
			dot: 'var(--dot-blue)'
		},
		{
			id: 'ai',
			label: 'Full AI',
			title: 'Maximal on demand',
			body: 'Bring your own key. Ask in plain language and Tidy creates lists, nests subtasks, reorders, and cleans up for real.',
			points: [
				'Assistant pane (⌘/Ctrl+J)',
				'Full mode (⌘/Ctrl+⇧.)',
				'Groq · xAI · OpenAI · OpenRouter'
			],
			dot: 'var(--dot-lilac)'
		}
	];

	let active = $state(0);
	const current = $derived(levels[active]);
</script>

<section id="spectrum" class="section spectrum" aria-labelledby="spectrum-heading">
	<div class="container">
		<div class="intro">
			<h2 id="spectrum-heading">Your intensity. Same app.</h2>
			<p class="lead">
				Tidy scales from pen-and-paper simplicity to full AI control, without forcing you into
				either.
			</p>
		</div>

		<div class="levels" role="tablist" aria-label="Capability levels">
			{#each levels as level, i}
				<button
					type="button"
					role="tab"
					id="tab-{level.id}"
					aria-selected={active === i}
					aria-controls="panel-{level.id}"
					class="level"
					class:active={active === i}
					onclick={() => (active = i)}
				>
					<span class="dot" style:background={level.dot}></span>
					<span class="level-label">{level.label}</span>
				</button>
			{/each}
		</div>

		<div
			class="panel"
			role="tabpanel"
			id="panel-{current.id}"
			aria-labelledby="tab-{current.id}"
		>
			<div class="copy">
				<h3 class="level-title">{current.title}</h3>
				<p class="level-body">{current.body}</p>
				<ul>
					{#each current.points as point}
						<li>
							<span class="dot" style:background={current.dot}></span>
							{point}
						</li>
					{/each}
				</ul>
			</div>
			<div class="preview">
				<AppMock mode={current.id} />
			</div>
		</div>
	</div>
</section>

<style>
	.spectrum {
		/* Slightly deeper sand band, still part of the table */
		background: color-mix(in srgb, var(--sand) 35%, transparent);
		border-block: 1px solid color-mix(in srgb, var(--sand-deep) 35%, transparent);
	}

	.intro {
		max-width: 32rem;
		margin-bottom: 1.75rem;
	}

	.intro h2 {
		margin: 0 0 0.7rem;
	}

	.intro .lead {
		margin: 0;
	}

	.levels {
		display: flex;
		flex-wrap: wrap;
		gap: 0.55rem;
		margin-bottom: 1.75rem;
	}

	.level {
		display: inline-flex;
		align-items: center;
		gap: 0.5rem;
		padding: 0.55rem 0.95rem;
		border-radius: var(--radius-pill);
		border: 1px solid color-mix(in srgb, var(--sand-deep) 40%, transparent);
		background: var(--clay-bright);
		color: var(--text-muted);
		font: inherit;
		font-size: 0.92rem;
		font-weight: 550;
		cursor: pointer;
		box-shadow: var(--shadow-sm);
		transition:
			box-shadow 0.15s ease,
			border-color 0.15s ease,
			color 0.15s ease;
	}

	.level:hover {
		color: var(--text);
		border-color: color-mix(in srgb, var(--sand-deep) 60%, transparent);
	}

	.level.active {
		color: var(--text);
		border-color: color-mix(in srgb, var(--slate) 55%, transparent);
		box-shadow: var(--shadow-md);
		background: color-mix(in srgb, var(--clay-bright) 75%, var(--clay));
	}

	.level .dot {
		width: 0.55rem;
		height: 0.55rem;
	}

	.panel {
		display: grid;
		gap: 1.75rem;
		align-items: center;
	}

	@media (min-width: 860px) {
		.panel {
			grid-template-columns: 0.9fr 1.1fr;
			gap: 2.5rem;
		}
	}

	.level-title {
		margin: 0 0 0.65rem;
		font-size: clamp(1.35rem, 2.5vw, 1.65rem);
	}

	.level-body {
		margin: 0 0 1.15rem;
		color: var(--text-muted);
		max-width: 28rem;
		line-height: 1.55;
	}

	ul {
		margin: 0;
		padding: 0;
		list-style: none;
		display: grid;
		gap: 0.55rem;
	}

	li {
		display: flex;
		align-items: center;
		gap: 0.55rem;
		font-weight: 500;
		font-size: 0.95rem;
	}

	li .dot {
		width: 0.5rem;
		height: 0.5rem;
	}
</style>
