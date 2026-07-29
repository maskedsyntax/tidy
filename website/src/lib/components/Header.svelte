<script lang="ts">
	import { site } from '$lib/seo';

	let open = $state(false);

	function close() {
		open = false;
	}
</script>

<header class="header">
	<div class="container bar">
		<a class="brand" href="/" aria-label="Tidy home">
			<img src="/icon.png" width="36" height="36" alt="" class="logo" />
			<span class="name">Tidy</span>
		</a>

		<nav class="nav" aria-label="Primary">
			<a href="#spectrum" onclick={close}>Spectrum</a>
			<a href="#ai" onclick={close}>AI</a>
			<a href="#features" onclick={close}>Features</a>
			<a href="#faq" onclick={close}>FAQ</a>
			<a href={site.github} rel="noopener noreferrer" target="_blank" onclick={close}>GitHub</a>
		</nav>

		<div class="actions">
			<a class="btn btn-primary btn-sm" href="#download">Get Tidy</a>
			<button
				type="button"
				class="menu-btn"
				aria-expanded={open}
				aria-controls="mobile-nav"
				aria-label={open ? 'Close menu' : 'Open menu'}
				onclick={() => (open = !open)}
			>
				<span class="menu-icon" class:open></span>
			</button>
		</div>
	</div>

	{#if open}
		<nav id="mobile-nav" class="mobile" aria-label="Mobile">
			<a href="#spectrum" onclick={close}>Spectrum</a>
			<a href="#ai" onclick={close}>AI</a>
			<a href="#features" onclick={close}>Features</a>
			<a href="#download" onclick={close}>Download</a>
			<a href="#faq" onclick={close}>FAQ</a>
			<a href={site.github} rel="noopener noreferrer" target="_blank" onclick={close}>GitHub</a>
		</nav>
	{/if}
</header>

<style>
	.header {
		position: sticky;
		top: 0;
		z-index: 50;
		height: var(--header-h);
		/* Soft frosted sand, not glassmorphism chrome */
		background: color-mix(in srgb, var(--sand-light) 88%, transparent);
		backdrop-filter: blur(14px) saturate(1.05);
		border-bottom: 1px solid color-mix(in srgb, var(--sand-deep) 40%, transparent);
	}

	.bar {
		display: flex;
		align-items: center;
		justify-content: space-between;
		height: var(--header-h);
		gap: 1rem;
	}

	.brand {
		display: inline-flex;
		align-items: center;
		gap: 0.65rem;
		text-decoration: none;
		font-weight: 600;
		letter-spacing: -0.02em;
	}

	.brand:hover {
		color: var(--text);
	}

	.logo {
		/* icon.png ships with its own squircle alpha */
		filter: drop-shadow(0 1px 2px rgba(74, 64, 52, 0.16));
	}

	.name {
		font-size: 1.05rem;
	}

	.nav {
		display: none;
		align-items: center;
		gap: 1.65rem;
		font-size: 0.92rem;
		font-weight: 500;
		color: var(--text-muted);
	}

	.nav a {
		text-decoration: none;
	}

	.nav a:hover {
		color: var(--text);
	}

	.actions {
		display: flex;
		align-items: center;
		gap: 0.5rem;
	}

	:global(.btn-sm) {
		padding: 0.55rem 1.05rem !important;
		font-size: 0.875rem !important;
	}

	.menu-btn {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		width: 2.55rem;
		height: 2.55rem;
		border: 1px solid var(--border);
		border-radius: 14px;
		background: var(--clay-bright);
		box-shadow: var(--shadow-sm);
		cursor: pointer;
	}

	.menu-icon {
		position: relative;
		width: 1rem;
		height: 1.5px;
		background: var(--text);
		border-radius: 1px;
	}

	.menu-icon::before,
	.menu-icon::after {
		content: '';
		position: absolute;
		left: 0;
		width: 1rem;
		height: 1.5px;
		background: var(--text);
		border-radius: 1px;
		transition: transform 0.15s ease;
	}

	.menu-icon::before {
		top: -5px;
	}

	.menu-icon::after {
		top: 5px;
	}

	.menu-icon.open {
		background: transparent;
	}

	.menu-icon.open::before {
		top: 0;
		transform: rotate(45deg);
	}

	.menu-icon.open::after {
		top: 0;
		transform: rotate(-45deg);
	}

	.mobile {
		display: flex;
		flex-direction: column;
		gap: 0.15rem;
		padding: 0.5rem 1.15rem 1.15rem;
		background: color-mix(in srgb, var(--clay-bright) 92%, transparent);
		border-bottom: 1px solid var(--border);
	}

	.mobile a {
		padding: 0.7rem 0.55rem;
		text-decoration: none;
		font-weight: 500;
		border-radius: 12px;
		color: var(--text-muted);
	}

	.mobile a:hover {
		background: var(--clay);
		color: var(--text);
	}

	@media (min-width: 900px) {
		.nav {
			display: flex;
		}

		.menu-btn,
		.mobile {
			display: none;
		}
	}
</style>
