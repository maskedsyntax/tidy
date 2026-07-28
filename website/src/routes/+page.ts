import { site } from '$lib/seo';
import type { PageLoad } from './$types';

export const load: PageLoad = () => {
	return {
		title: site.title,
		description: site.description,
		canonicalPath: '/'
	};
};
