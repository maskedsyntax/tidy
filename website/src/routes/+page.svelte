<script lang="ts">
	import Header from '$lib/components/Header.svelte';
	import Footer from '$lib/components/Footer.svelte';
	import AppMock from '$lib/components/AppMock.svelte';
	import Spectrum from '$lib/components/Spectrum.svelte';
	import JsonLd from '$lib/components/JsonLd.svelte';
	import { site } from '$lib/seo';

	const prompts = [
		'Plan a Travel list: pack, flights, hotel.',
		'Move gym tasks to Personal and put legs first.',
		'Mark design polish done and delete the spike.',
		'What’s on my plate across all lists?',
		'Create Learning with Rust and a side project.',
		'Clean up completed tasks in Work.'
	];

	const features = [
		{
			title: 'Multiple lists',
			body: 'Work, Personal, Learning, or whatever you name. Soft colored dots keep context obvious.',
			dot: 'var(--dot-blue)'
		},
		{
			title: 'Nested subtasks',
			body: 'Tab to indent, Shift+Tab to outdent. Break big work into steps without leaving the keyboard.',
			dot: 'var(--dot-sage)'
		},
		{
			title: 'All Tasks view',
			body: 'See everything in one place with list badges so you always know where a task belongs.',
			dot: 'var(--dot-lilac)'
		},
		{
			title: 'Command palette',
			body: '⌘K / Ctrl+K switches themes, jumps lists, creates lists, and opens settings instantly.',
			dot: 'var(--dot-blue)'
		},
		{
			title: 'Adaptive layout',
			body: 'Focus mode for pen-and-paper calm, or full mode with lists + assistant. Layout is remembered.',
			dot: 'var(--dot-sage)'
		},
		{
			title: 'Local-first',
			body: 'JSON on disk. No signup for core use. Your notebook stays on your machine.',
			dot: 'var(--dot-lilac)'
		}
	];

	const shortcuts = [
		{ keys: ['⌘/Ctrl', 'K'], action: 'Command palette' },
		{ keys: ['⌘/Ctrl', 'B'], action: 'Toggle lists sidebar' },
		{ keys: ['⌘/Ctrl', 'J'], action: 'Toggle AI assistant' },
		{ keys: ['⌘/Ctrl', '.'], action: 'Focus mode (tasks only)' },
		{ keys: ['⌘/Ctrl', '⇧', '.'], action: 'Full mode (all panes)' },
		{ keys: ['⌘/Ctrl', 'N'], action: 'New list' },
		{ keys: ['⌘/Ctrl', '1…9'], action: 'Switch list' },
		{ keys: ['Tab'], action: 'Indent subtask' },
		{ keys: ['Shift', 'Tab'], action: 'Outdent' }
	];

	const providers = ['Groq', 'xAI (Grok)', 'OpenAI', 'OpenRouter', 'Custom endpoint'];

	const faqs = [
		{
			q: 'Do I need an API key to use Tidy?',
			a: 'No. Tidy works fully as a local desktop todo app without AI. Add a key only when you want the assistant.'
		},
		{
			q: 'Where is my data stored?',
			a: 'Lists and tasks live as local JSON on your device. They survive restarts and do not require an account.'
		},
		{
			q: 'Which AI providers work?',
			a: 'Bring your own key for Groq, xAI (Grok), OpenAI, OpenRouter, or any OpenAI-compatible base URL and model.'
		},
		{
			q: 'Does AI change real tasks, or only chat?',
			a: 'Real changes. The assistant can create and update lists and tasks, nest subtasks, move, reorder, complete, and delete. Then it confirms in plain language.'
		},
		{
			q: 'Which platforms are supported?',
			a: 'macOS and Linux, powered by Flutter. Desktop builds are coming soon.'
		},
		{
			q: 'Is Tidy open source?',
			a: 'Yes. MIT licensed. Inspect the code, fork it, ship your own builds.'
		}
	];
</script>

<JsonLd />

<Header />

<main id="main">
	<!-- Hero: centered copy sitting above the live app mock -->
	<section class="hero section" aria-labelledby="hero-heading">
		<div class="container hero-inner">
			<div class="hero-copy">
				<p class="kicker">Desktop todos for macOS &amp; Linux</p>
				<h1 id="hero-heading">
					As minimal as pen and paper.<br />
					As maximal as AI can go.
				</h1>
				<p class="lead hero-lead">
					A quiet, local-first todo app. Use it like a notebook, or plug in your own AI key and
					manage lists in plain language.
				</p>
				<div class="hero-cta">
					<a class="btn btn-primary" href="#download">Get Tidy</a>
					<a class="btn btn-secondary" href="#spectrum">See the spectrum</a>
				</div>
				<p class="hero-meta">
					<span class="dot" style:background="var(--dot-blue)"></span>
					Local-first
					<span class="sep">·</span>
					<span class="dot" style:background="var(--dot-sage)"></span>
					BYOK AI
					<span class="sep">·</span>
					<span class="dot" style:background="var(--dot-lilac)"></span>
					MIT open source
				</p>
			</div>

			<div class="hero-visual">
				<AppMock mode="ai" />
			</div>
		</div>
	</section>

	<Spectrum />

	<!-- AI -->
	<section id="ai" class="section" aria-labelledby="ai-heading">
		<div class="container">
			<div class="ai-head">
				<img class="ai-mark" src="/ai-mark.png" alt="" width="52" height="52" />
				<h2 id="ai-heading">Not just chat. Real workspace control.</h2>
				<p class="lead">
					Most “AI todos” answer questions. Tidy’s assistant reads your workspace and makes real
					changes: create lists, nest subtasks, reorder, complete, and clean up.
				</p>
			</div>

			<div class="ai-grid">
				<div class="prompts card">
					<h3>Try saying…</h3>
					<ul>
						{#each prompts as prompt}
							<li>
								<span class="quote">“{prompt}”</span>
							</li>
						{/each}
					</ul>
				</div>
				<div class="providers card">
					<h3>Your model. Your keys.</h3>
					<p class="muted">
						No Tidy AI subscription. Bring any OpenAI-compatible provider.
					</p>
					<ul class="provider-list">
						{#each providers as p, i}
							<li>
								<span
									class="dot"
									style:background={i % 3 === 0
										? 'var(--dot-blue)'
										: i % 3 === 1
											? 'var(--dot-sage)'
											: 'var(--dot-lilac)'}
								></span>
								{p}
							</li>
						{/each}
					</ul>
					<p class="privacy">
						<strong>Privacy.</strong> Lists stay on your device. When AI is on, only the conversation
						and workspace context you send go to the provider you chose.
					</p>
				</div>
			</div>
		</div>
	</section>

	<!-- Features -->
	<section id="features" class="section features" aria-labelledby="features-heading">
		<div class="container">
			<div class="section-head">
				<h2 id="features-heading">Still a real desktop app</h2>
				<p class="lead">
					AI is optional depth. Underneath is a calm, fast todo surface that holds up without it.
				</p>
			</div>

			<ul class="feature-list">
				{#each features as feature}
					<li>
						<span class="dot" style:background={feature.dot}></span>
						<div>
							<h3>{feature.title}</h3>
							<p>{feature.body}</p>
						</div>
					</li>
				{/each}
			</ul>

			<div class="shortcuts card">
				<div>
					<h3>Keyboard shortcuts</h3>
					<p class="muted">Power-user defaults from day one.</p>
				</div>
				<table>
					<caption class="sr-only">Tidy keyboard shortcuts</caption>
					<thead>
						<tr>
							<th scope="col">Shortcut</th>
							<th scope="col">Action</th>
						</tr>
					</thead>
					<tbody>
						{#each shortcuts as row}
							<tr>
								<td>
									{#each row.keys as key, i}
										{#if i > 0}<span class="plus">+</span>{/if}
										<kbd class="kbd">{key}</kbd>
									{/each}
								</td>
								<td>{row.action}</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		</div>
	</section>

	<!-- Download -->
	<section id="download" class="section download" aria-labelledby="download-heading">
		<div class="container download-card card">
			<div class="download-copy">
				<p class="soon">Coming soon</p>
				<h2 id="download-heading">macOS and Linux</h2>
				<p class="lead">
					Desktop builds are on the way. Flutter desktop, polished for the platforms that live on
					your desk.
				</p>

				<div class="download-actions">
					<a class="btn btn-primary" href={site.github} rel="noopener noreferrer" target="_blank">
						View on GitHub
					</a>
				</div>
			</div>
		</div>
	</section>

	<!-- FAQ -->
	<section id="faq" class="section section-tight" aria-labelledby="faq-heading">
		<div class="container faq-wrap">
			<h2 id="faq-heading">FAQ</h2>
			<div class="faq-list">
				{#each faqs as item}
					<details class="faq card">
						<summary>{item.q}</summary>
						<p>{item.a}</p>
					</details>
				{/each}
			</div>
		</div>
	</section>
</main>

<Footer />

<style>
	.hero {
		padding-top: clamp(2rem, 5vw, 3.25rem);
		padding-bottom: clamp(2.5rem, 6vw, 4rem);
	}

	.hero-inner {
		display: grid;
		gap: 2rem;
		justify-items: center;
		text-align: center;
	}

	.hero-copy {
		max-width: 42rem;
	}

	.kicker {
		margin: 0 0 0.75rem;
		font-size: 0.92rem;
		font-weight: 500;
		color: var(--text-muted);
	}

	.hero-copy h1 {
		margin: 0 0 1rem;
	}

	.hero-lead {
		margin: 0 auto 1.4rem;
	}

	.hero-cta {
		display: flex;
		flex-wrap: wrap;
		justify-content: center;
		gap: 0.65rem;
		margin-bottom: 1.25rem;
	}

	.hero-meta {
		display: flex;
		flex-wrap: wrap;
		align-items: center;
		justify-content: center;
		gap: 0.4rem 0.55rem;
		margin: 0;
		font-size: 0.88rem;
		font-weight: 500;
		color: var(--text-muted);
	}

	.hero-meta .dot {
		width: 0.45rem;
		height: 0.45rem;
	}

	.sep {
		color: var(--text-faint);
		margin-inline: 0.1rem;
	}

	.hero-visual {
		width: min(100%, 720px);
		margin-top: 0.5rem;
		text-align: left;
	}

	@media (min-width: 960px) {
		.hero-visual {
			width: 100%;
			max-width: none;
			margin-top: 1.25rem;
		}
	}

	.ai-head {
		max-width: 34rem;
		margin-bottom: 1.75rem;
	}

	.ai-mark {
		width: 3.1rem;
		height: 3.1rem;
		border-radius: 50%;
		margin-bottom: 0.9rem;
		box-shadow: 0 4px 14px rgba(91, 138, 196, 0.24);
	}

	.ai-head h2 {
		margin: 0 0 0.7rem;
	}

	.ai-head .lead {
		margin: 0;
	}

	.ai-grid {
		display: grid;
		gap: 1rem;
	}

	@media (min-width: 800px) {
		.ai-grid {
			grid-template-columns: 1.15fr 0.85fr;
			gap: 1.15rem;
		}
	}

	.prompts,
	.providers {
		padding: 1.3rem 1.35rem;
	}

	.prompts h3,
	.providers h3 {
		margin: 0 0 0.85rem;
	}

	.prompts ul {
		list-style: none;
		margin: 0;
		padding: 0;
		display: grid;
		gap: 0.5rem;
	}

	.prompts li {
		padding: 0.7rem 0.85rem;
		border-radius: 14px;
		background: var(--clay);
		border: 1px solid color-mix(in srgb, var(--sand-deep) 30%, transparent);
	}

	.quote {
		font-size: 0.92rem;
		color: var(--text);
	}

	.providers .muted {
		margin: 0 0 1rem;
	}

	.provider-list {
		list-style: none;
		margin: 0 0 1.15rem;
		padding: 0;
		display: grid;
		gap: 0.5rem;
	}

	.provider-list li {
		display: flex;
		align-items: center;
		gap: 0.55rem;
		font-weight: 500;
	}

	.privacy {
		margin: 0;
		padding-top: 1rem;
		border-top: 1px solid color-mix(in srgb, var(--sand-deep) 35%, transparent);
		font-size: 0.88rem;
		color: var(--text-muted);
		line-height: 1.5;
	}

	.features {
		background: color-mix(in srgb, var(--sand) 28%, transparent);
		border-block: 1px solid color-mix(in srgb, var(--sand-deep) 32%, transparent);
	}

	.section-head {
		max-width: 34rem;
		margin-bottom: 1.75rem;
	}

	.section-head h2 {
		margin: 0 0 0.7rem;
	}

	.section-head .lead {
		margin: 0;
	}

	/* List of features, not a generic 3×2 SaaS card grid */
	.feature-list {
		list-style: none;
		margin: 0 0 1.5rem;
		padding: 0;
		display: grid;
		gap: 0.85rem;
	}

	@media (min-width: 720px) {
		.feature-list {
			grid-template-columns: 1fr 1fr;
			gap: 1rem 1.75rem;
		}
	}

	.feature-list li {
		display: flex;
		gap: 0.75rem;
		align-items: flex-start;
		padding: 0.35rem 0;
	}

	.feature-list .dot {
		width: 0.55rem;
		height: 0.55rem;
		margin-top: 0.45rem;
	}

	.feature-list h3 {
		margin: 0 0 0.25rem;
	}

	.feature-list p {
		margin: 0;
		color: var(--text-muted);
		font-size: 0.95rem;
		line-height: 1.5;
	}

	.shortcuts {
		padding: 1.3rem 1.35rem;
		display: grid;
		gap: 1.15rem;
	}

	@media (min-width: 800px) {
		.shortcuts {
			grid-template-columns: 0.75fr 1.25fr;
			align-items: start;
		}
	}

	.shortcuts h3 {
		margin: 0 0 0.3rem;
	}

	.shortcuts .muted {
		margin: 0;
	}

	table {
		width: 100%;
		border-collapse: collapse;
		font-size: 0.9rem;
	}

	th,
	td {
		text-align: left;
		padding: 0.5rem 0.3rem;
		border-bottom: 1px solid color-mix(in srgb, var(--sand-deep) 30%, transparent);
	}

	th {
		font-size: 0.75rem;
		font-weight: 600;
		color: var(--text-faint);
	}

	.plus {
		margin: 0 0.22rem;
		color: var(--text-faint);
	}

	.download-card {
		max-width: 44rem;
		padding: clamp(2rem, 4.5vw, 2.9rem) clamp(1.5rem, 4vw, 2.5rem);
		text-align: center;
	}

	.download-copy {
		max-width: 30rem;
		margin-inline: auto;
	}

	.download-copy h2 {
		margin: 0 0 0.65rem;
	}

	.download-copy .lead {
		margin: 0 auto 1.45rem;
	}

	.soon {
		display: inline-flex;
		align-items: center;
		gap: 0.4rem;
		margin: 0 0 0.9rem;
		padding: 0.3rem 0.7rem;
		border-radius: var(--radius-pill);
		background: color-mix(in srgb, var(--dot-blue) 14%, transparent);
		border: 1px solid color-mix(in srgb, var(--dot-blue) 30%, transparent);
		font-size: 0.78rem;
		font-weight: 600;
		letter-spacing: 0.01em;
		color: var(--accent-ink);
	}

	.soon::before {
		content: '';
		width: 0.4rem;
		height: 0.4rem;
		border-radius: 50%;
		background: var(--dot-blue);
	}

	.download-actions {
		display: flex;
		flex-wrap: wrap;
		justify-content: center;
		gap: 0.65rem;
	}

	.faq-wrap h2 {
		margin: 0 0 1.3rem;
		text-align: center;
	}

	.faq-list {
		display: grid;
		gap: 0.55rem;
		max-width: 44rem;
		margin-inline: auto;
	}

	.faq {
		padding: 0;
		overflow: hidden;
	}

	.faq summary {
		cursor: pointer;
		padding: 0.95rem 1.1rem;
		font-weight: 600;
		list-style: none;
	}

	.faq summary::-webkit-details-marker {
		display: none;
	}

	.faq summary::after {
		content: '+';
		float: right;
		color: var(--text-faint);
		font-weight: 500;
	}

	.faq[open] summary::after {
		content: '–';
	}

	.faq p {
		margin: 0;
		padding: 0 1.1rem 1.05rem;
		color: var(--text-muted);
	}
</style>
