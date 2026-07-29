<script lang="ts">
	import '../app.css';
	import { page } from '$app/stores';
	import { site, absoluteUrl } from '$lib/seo';

	let { children } = $props();

	const title = $derived($page.data.title ?? site.title);
	const description = $derived($page.data.description ?? site.description);
	const canonical = $derived(absoluteUrl($page.data.canonicalPath ?? $page.url.pathname));
	const ogImage = $derived(absoluteUrl($page.data.ogImage ?? '/og.png'));
	const noindex = $derived(Boolean($page.data.noindex));
</script>

<svelte:head>
	<title>{title}</title>
	<meta name="description" content={description} />
	<meta name="keywords" content={site.keywords} />
	<meta name="author" content="Tidy" />
	<meta
		name="robots"
		content={noindex
			? 'noindex, nofollow'
			: 'index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1'}
	/>
	<link rel="canonical" href={canonical} />

	<meta property="og:type" content="website" />
	<meta property="og:site_name" content={site.name} />
	<meta property="og:locale" content={site.locale} />
	<meta property="og:title" content={title} />
	<meta property="og:description" content={description} />
	<meta property="og:url" content={canonical} />
	<meta property="og:image" content={ogImage} />
	<meta property="og:image:width" content="1200" />
	<meta property="og:image:height" content="630" />
	<meta property="og:image:alt" content="Tidy: desktop todo app for macOS and Linux" />

	<meta name="twitter:card" content="summary_large_image" />
	<meta name="twitter:title" content={title} />
	<meta name="twitter:description" content={description} />
	<meta name="twitter:image" content={ogImage} />
	<meta name="twitter:image:alt" content="Tidy: desktop todo app for macOS and Linux" />

	<meta name="theme-color" content="#E8E2D8" />
</svelte:head>

<a class="skip-link" href="#main">Skip to content</a>

{@render children()}

<style>
	.skip-link {
		position: absolute;
		left: 1rem;
		top: -100px;
		z-index: 1000;
		padding: 0.6rem 1rem;
		background: var(--text);
		color: var(--clay-bright);
		border-radius: var(--radius-sm);
		font-weight: 600;
		text-decoration: none;
	}

	.skip-link:focus {
		top: 1rem;
	}
</style>
