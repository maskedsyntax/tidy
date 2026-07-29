# Tidy website

Marketing site for [Tidy](https://github.com/maskedsyntax/tidy) built with **SvelteKit**, fully **prerendered** for SEO and static hosting.

## Positioning

> As minimal as pen and paper. As maximal as AI can go.

## Develop

```bash
cd website
npm install
npm run dev
```

## Build

```bash
npm run build
npm run preview
```

Output is static under `website/build/` (via `@sveltejs/adapter-static`).

## SEO checklist

| Item | Location |
|------|----------|
| Title / description / canonical | `src/routes/+layout.svelte`, `src/lib/seo.ts` |
| Open Graph + Twitter cards | `src/routes/+layout.svelte` |
| JSON-LD (`SoftwareApplication`, FAQ, WebSite) | `src/lib/components/JsonLd.svelte` |
| `robots.txt` | `static/robots.txt` |
| `sitemap.xml` | `static/sitemap.xml` |
| Web manifest | `static/site.webmanifest` |
| Semantic HTML, skip link, FAQ details | `+page.svelte` |

### Before production

1. Set the real domain in `src/lib/seo.ts` (`site.url`).
2. Update `static/robots.txt` and `static/sitemap.xml` to match.
3. Replace `static/og.png` with a 1200×630 branded image if desired.
4. Point download CTAs at real release assets when available.

## Deploy

Any static host works:

- **GitHub Pages**: publish `website/build`
- **Cloudflare Pages / Netlify / Vercel**: root `website`, build `npm run build`, output `build`
- **Custom**: serve `build/` over HTTPS with compression enabled (adapter also emits `.gz` / `.br` when supported)
