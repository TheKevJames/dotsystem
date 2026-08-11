#!/usr/bin/env node

// Primary: Jina Search (s.jina.ai) returns LLM-ready SERP results and requires an
// API key (JINA_API_KEY); the skill fails fast when it is unset. When Jina
// rate-limits (HTTP 429), it falls back to scraping DuckDuckGo with a warning.

const args = process.argv.slice(2);
let n = 5, query;

for (let i = 0; i < args.length; i++) {
  if (args[i] === '-n' && args[i + 1]) { n = parseInt(args[++i], 10); }
  else { query = args[i]; }
}

if (!query) { console.error('Usage: search.js [-n count] "query"'); process.exit(1); }
if (!process.env.JINA_API_KEY) { console.error('[web-search] JINA_API_KEY is not set.'); process.exit(1); }

async function jinaSearch() {
  const res = await fetch(`https://s.jina.ai/?q=${encodeURIComponent(query)}`, {
    headers: {
      'Accept': 'application/json',
      'Authorization': `Bearer ${process.env.JINA_API_KEY}`,
      'X-Respond-With': 'no-content',
    },
  });
  if (!res.ok) { const e = new Error(`Jina search HTTP ${res.status}`); e.status = res.status; throw e; }
  const json = await res.json();
  return (json.data || []).slice(0, n).map(r => ({
    title: (r.title || '').trim(),
    url: r.url,
    snippet: (r.description || r.content || '').replace(/\s+/g, ' ').trim().slice(0, 300),
  }));
}

async function duckDuckGoSearch() {
  const res = await fetch(`https://html.duckduckgo.com/html/?q=${encodeURIComponent(query)}`, {
    headers: { 'User-Agent': 'Mozilla/5.0' },
  });
  const html = await res.text();
  const results = [];
  const blockRe = /<a rel="nofollow" class="result__a" href="([^"]*)"[^>]*>([\s\S]*?)<\/a>[\s\S]*?<a class="result__snippet"[^>]*>([\s\S]*?)<\/a>/g;
  let m;
  while ((m = blockRe.exec(html)) && results.length < n) {
    const url = decodeURIComponent(m[1].replace(/^\/\/duckduckgo\.com\/l\/\?uddg=/, '').replace(/&amp;rut=.*$/, '').replace(/&rut=.*$/, ''));
    const title = m[2].replace(/<[^>]*>/g, '').trim();
    const snippet = m[3].replace(/<[^>]*>/g, '').trim();
    results.push({ title, url, snippet });
  }
  return results;
}

let results;
try {
  results = await jinaSearch();
} catch (e) {
  const reason = e.status === 429 ? 'rate limit exceeded' : `unavailable (${e.message})`;
  console.error(`[web-search] Jina search ${reason}; falling back to DuckDuckGo scraping.`);
  results = await duckDuckGoSearch();
}

if (!results.length) { console.log('No results found.'); }
else { results.forEach((r, i) => console.log(`${i + 1}. ${r.title}\n   ${r.url}\n   ${r.snippet}\n`)); }
