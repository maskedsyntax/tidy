<script lang="ts">
	import Footer from '$lib/components/Footer.svelte';
	import Header from '$lib/components/Header.svelte';
	import { site } from '$lib/seo';
</script>

<Header />

<main id="main" class="section legal">
	<div class="container legal-card card">
		<p class="eyebrow">Support</p>
		<h1>Tidy Support</h1>
		<p>
			Need help with Tidy? Open a GitHub issue and include your macOS version, Tidy version,
			what you expected to happen, and what happened instead.
		</p>
		<p>
			<a href="{site.github}/issues" rel="noopener noreferrer" target="_blank">Open a support issue</a>
		</p>
		<p>
			For App Store billing, refund, or download issues, use Apple’s purchase support from your
			Apple account.
		</p>
	</div>
</main>

<Footer />

<style>
	.legal-card {
		max-width: 46rem;
		padding: clamp(1.5rem, 4vw, 2.5rem);
	}

	.eyebrow {
		margin: 0 0 0.7rem;
		font-size: 0.82rem;
		font-weight: 600;
		color: var(--text-faint);
	}

	h1 {
		margin: 0 0 1rem;
	}

	p {
		color: var(--text-muted);
		line-height: 1.6;
	}

	a {
		color: var(--accent-ink);
		font-weight: 600;
	}
</style>
