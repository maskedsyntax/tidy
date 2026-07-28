<script lang="ts">
	import { site, absoluteUrl } from '$lib/seo';

	const software = {
		'@context': 'https://schema.org',
		'@type': 'SoftwareApplication',
		name: site.name,
		applicationCategory: 'ProductivityApplication',
		operatingSystem: 'macOS, Linux',
		description: site.description,
		url: site.url,
		image: absoluteUrl('/og.png'),
		offers: {
			'@type': 'Offer',
			price: '0',
			priceCurrency: 'USD'
		},
		softwareVersion: '1.0.0',
		license: 'https://opensource.org/licenses/MIT',
		downloadUrl: absoluteUrl('/#download'),
		featureList: [
			'Multiple todo lists with colored icons',
			'Nested subtasks',
			'Command palette',
			'Adaptive layout (focus mode to full AI workspace)',
			'Local-first JSON storage',
			'AI assistant with bring-your-own-key',
			'Light and dark themes'
		]
	};

	const org = {
		'@context': 'https://schema.org',
		'@type': 'Organization',
		name: site.name,
		url: site.url,
		logo: absoluteUrl('/icon.png')
	};

	const website = {
		'@context': 'https://schema.org',
		'@type': 'WebSite',
		name: site.name,
		url: site.url,
		description: site.description,
		inLanguage: 'en'
	};

	const faq = {
		'@context': 'https://schema.org',
		'@type': 'FAQPage',
		mainEntity: [
			{
				'@type': 'Question',
				name: 'Do I need an API key to use Tidy?',
				acceptedAnswer: {
					'@type': 'Answer',
					text: 'No. Tidy works fully as a local desktop todo app without AI. Add an API key only if you want the assistant.'
				}
			},
			{
				'@type': 'Question',
				name: 'Where is my data stored?',
				acceptedAnswer: {
					'@type': 'Answer',
					text: 'Your lists and tasks are stored locally as JSON on your device. They survive restarts and do not require an account.'
				}
			},
			{
				'@type': 'Question',
				name: 'Which AI providers does Tidy support?',
				acceptedAnswer: {
					'@type': 'Answer',
					text: 'Tidy supports bring-your-own-key with Groq, xAI (Grok), OpenAI, OpenRouter, or any OpenAI-compatible endpoint.'
				}
			},
			{
				'@type': 'Question',
				name: 'Which platforms are supported?',
				acceptedAnswer: {
					'@type': 'Answer',
					text: 'Tidy is a desktop app for macOS and Linux, built with Flutter.'
				}
			},
			{
				'@type': 'Question',
				name: 'Is Tidy open source?',
				acceptedAnswer: {
					'@type': 'Answer',
					text: 'Yes. Tidy is released under the MIT License.'
				}
			}
		]
	};

	const graph = {
		'@context': 'https://schema.org',
		'@graph': [software, org, website, faq]
	};
</script>

<svelte:head>
	{@html `<script type="application/ld+json">${JSON.stringify(graph)}</script>`}
</svelte:head>
