/** Site-wide SEO constants. Update siteUrl when the production domain is known. */
export const site = {
	name: 'Tidy',
	title: 'Tidy — As minimal as pen and paper. As maximal as AI can go.',
	description:
		'Tidy is a polished desktop todo app for macOS and Linux. Use it like a quiet notebook — or plug in your own AI key and manage lists, tasks, and priorities in plain language. Local-first. Keyboard-fast. BYOK.',
	// Replace with production domain (no trailing slash)
	url: 'https://tidy.app',
	locale: 'en_US',
	twitter: '',
	github: 'https://github.com/maskedsyntax/tidy',
	keywords: [
		'Tidy',
		'AI todo app',
		'desktop todo',
		'macOS todo',
		'Linux todo',
		'local-first',
		'BYOK',
		'command palette',
		'keyboard-first',
		'OpenAI-compatible',
		'task manager',
		'AI task assistant'
	].join(', ')
} as const;

export function absoluteUrl(path = ''): string {
	const base = site.url.replace(/\/$/, '');
	if (!path) return base;
	return `${base}${path.startsWith('/') ? path : `/${path}`}`;
}
