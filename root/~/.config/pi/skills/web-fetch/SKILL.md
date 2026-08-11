---
name: web-fetch
description: Fetch a web page and extract readable text content. Use when user needs to retrieve or read a web page.
---

# web-fetch

Fetch a web page and extract readable, LLM-ready content via the Jina Reader
(`r.jina.ai`), which handles JS rendering and cleanup. Requires `JINA_API_KEY`
and fails fast when it is unset. If Jina is rate-limited (HTTP 429) or
unavailable, it falls back to a direct fetch with naive HTML tag-stripping and
prints a warning to stderr.

## Usage

```bash
{baseDir}/fetch.js <url> [--raw]
```

- `<url>` — URL to fetch
- `--raw` — Output raw HTML instead of extracted content

## Examples

```bash
{baseDir}/fetch.js https://example.com
{baseDir}/fetch.js https://example.com --raw
```
