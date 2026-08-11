---
name: web-search
description: Web search via Jina (with DuckDuckGo fallback). Use when the user needs to look up current information online.
---

# web-search

Web search that returns LLM-ready SERP results via Jina Search (`s.jina.ai`).

Requires `JINA_API_KEY` and fails fast when it is unset. When Jina is
rate-limited (HTTP 429), the skill falls back to scraping DuckDuckGo and prints a
warning to stderr.

## Usage

```bash
{baseDir}/search.js "query terms"
{baseDir}/search.js -n 10 "query terms"
```

- `-n <count>` — number of results to return (default: 5)
- Returns title, URL, and snippet for each result.
