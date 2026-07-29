<script lang="ts">
	import Footer from '$lib/components/Footer.svelte';
	import Header from '$lib/components/Header.svelte';
	import { site } from '$lib/seo';
</script>

<Header />

<main id="main" class="section legal">
	<div class="container legal-card card">
		<p class="eyebrow">Privacy Policy</p>
		<h1>Privacy Policy</h1>
		<p>Last updated: July 29, 2026</p>

		<h2>Data collection</h2>
		<p>
			Tidy does not collect personal data, analytics, crash reports, usage data, or tracking data.
			There is no Tidy account and no Tidy cloud service.
		</p>

		<h2>Local data</h2>
		<p>
			Your lists, tasks, and app settings are stored locally on your device. API keys are stored in
			macOS Keychain.
		</p>

		<h2>AI assistant</h2>
		<p>
			The AI assistant is optional and does nothing until you provide your own API key. When you use
			the assistant, Tidy sends the conversation and relevant workspace context to the AI provider
			you configured. That provider processes the request under its own privacy policy and terms.
		</p>

		<h2>Third parties</h2>
		<p>
			Tidy does not sell data and does not share data for advertising. Network requests are made only
			when you use the AI assistant with the provider you choose.
		</p>

		<h2>Support</h2>
		<p>
			If you contact support through GitHub, the information you provide is handled by GitHub under
			GitHub’s policies. Support is available at <a href={site.support}>tidy.maskedsyntax.com/support</a>.
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
