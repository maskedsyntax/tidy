<script lang="ts">
	import { site } from '$lib/seo';

	const year = new Date().getFullYear();
</script>

<footer class="footer">
	<div class="container inner">
		<div class="brand-block">
			<div class="brand">
				<img src="/icon.png" width="40" height="40" alt="" class="logo" />
				<span>Tidy</span>
			</div>
			<p class="tagline">
				As minimal as pen and paper.<br />
				As maximal as AI can go.
			</p>
		</div>

		<nav class="cols" aria-label="Footer">
			<div>
				<p class="col-title">Product</p>
				<ul>
					<li><a href="#spectrum">Spectrum</a></li>
					<li><a href="#ai">AI assistant</a></li>
					<li><a href="#features">Features</a></li>
					<li><a href="#download">Download</a></li>
				</ul>
			</div>
			<div>
				<p class="col-title">Resources</p>
				<ul>
					<li><a href={site.support}>Support</a></li>
					<li><a href={site.privacy}>Privacy Policy</a></li>
					<li><a href={site.terms}>Terms of Use</a></li>
					<li>
						<a href={site.github} rel="noopener noreferrer" target="_blank">GitHub</a>
					</li>
					<li><a href="#faq">FAQ</a></li>
					<li>
						<a href="{site.github}/blob/master/LICENSE" rel="noopener noreferrer" target="_blank"
							>MIT License</a
						>
					</li>
				</ul>
			</div>
			<div>
				<p class="col-title">Platforms</p>
				<ul>
					<li>macOS <span class="soon">soon</span></li>
					<li>Linux <span class="soon">soon</span></li>
				</ul>
			</div>
		</nav>
	</div>

	<div class="container bottom">
		<p>© {year} Tidy</p>
		<p class="fine">
			Lists stay on your device. When you use AI, only the conversation and workspace context you
			send go to the provider you choose.
		</p>
	</div>
</footer>

<style>
	.footer {
		margin-top: 1rem;
		padding-block: 3.25rem 2rem;
		border-top: 1px solid color-mix(in srgb, var(--sand-deep) 45%, transparent);
		background: color-mix(in srgb, var(--sand) 40%, var(--clay));
	}

	.inner {
		display: grid;
		gap: 2.5rem;
		padding-bottom: 2.25rem;
	}

	@media (min-width: 800px) {
		.inner {
			grid-template-columns: 1.25fr 1.75fr;
			gap: 3rem;
		}
	}

	.brand {
		display: inline-flex;
		align-items: center;
		gap: 0.6rem;
		font-weight: 600;
		margin-bottom: 0.85rem;
	}

	.logo {
		/* icon.png ships with its own squircle alpha */
		filter: drop-shadow(0 1px 2px rgba(74, 64, 52, 0.16));
	}

	.tagline {
		margin: 0;
		color: var(--text-muted);
		font-size: 1.05rem;
		line-height: 1.45;
		font-weight: 500;
		letter-spacing: -0.015em;
	}

	.cols {
		display: grid;
		grid-template-columns: repeat(3, minmax(0, 1fr));
		gap: 1.5rem;
	}

	.col-title {
		margin: 0 0 0.7rem;
		font-size: 0.8rem;
		font-weight: 600;
		color: var(--text-faint);
	}

	ul {
		list-style: none;
		margin: 0;
		padding: 0;
		display: grid;
		gap: 0.45rem;
	}

	li,
	a {
		font-size: 0.92rem;
		color: var(--text-muted);
		text-decoration: none;
	}

	a:hover {
		color: var(--text);
	}

	.soon {
		margin-left: 0.15rem;
		padding: 0.05rem 0.35rem;
		border-radius: var(--radius-pill);
		background: color-mix(in srgb, var(--dot-blue) 14%, transparent);
		font-size: 0.7rem;
		font-weight: 600;
		color: var(--accent-ink);
	}

	.bottom {
		display: grid;
		gap: 0.45rem;
		padding-top: 1.35rem;
		border-top: 1px solid color-mix(in srgb, var(--sand-deep) 40%, transparent);
		font-size: 0.82rem;
		color: var(--text-faint);
	}

	.bottom p {
		margin: 0;
	}

	.fine {
		max-width: 36rem;
		line-height: 1.5;
	}

	@media (max-width: 600px) {
		.cols {
			grid-template-columns: 1fr 1fr;
		}
	}
</style>
