<script lang="ts">
	import Footer from '$lib/components/Footer.svelte';
	import Header from '$lib/components/Header.svelte';
	import { site } from '$lib/seo';
</script>

<Header />

<main id="main" class="section legal">
	<div class="container legal-card card">
		<p class="eyebrow">Terms of Use</p>
		<h1>Terms of Use</h1>
		<p>Last updated: July 29, 2026</p>

		<h2>License</h2>
		<p>
			Tidy is provided through the Mac App Store under Apple’s Standard Licensed Application End
			User License Agreement unless a different agreement is shown by Apple at purchase.
		</p>

		<h2>Use of the app</h2>
		<p>
			You are responsible for the tasks, lists, API keys, and AI providers you configure in Tidy. The
			AI assistant is optional and depends on third-party providers you choose.
		</p>

		<h2>Third-party AI providers</h2>
		<p>
			When you use your own API key, your use of that AI provider is governed by that provider’s
			terms, pricing, and privacy policy. Tidy does not resell tokens or manage your AI provider
			billing.
		</p>

		<h2>Warranty</h2>
		<p>
			Tidy is provided as-is to the maximum extent permitted by law. Always review AI-generated task
			changes before relying on them.
		</p>

		<h2>Support</h2>
		<p>
			Support is available at <a href={site.support}>tidy.maskedsyntax.com/support</a>.
		</p>
	</div>
</main>

<Footer />

<style>
	.legal-card {
		max-width: 48rem;
		padding: clamp(1.5rem, 4vw, 2.5rem);
	}

	.eyebrow {
		margin: 0 0 0.7rem;
		font-size: 0.82rem;
		font-weight: 600;
		color: var(--text-faint);
	}

	h1,
	h2 {
		margin: 0 0 0.85rem;
	}

	h2 {
		padding-top: 1rem;
		font-size: 1.15rem;
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
