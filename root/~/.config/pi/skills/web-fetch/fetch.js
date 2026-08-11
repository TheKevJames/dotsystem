#!/usr/bin/env node

// Primary: Jina Reader (r.jina.ai) returns LLM-ready content. Fallback: direct
// fetch + naive tag-strip, used when Jina rate-limits (HTTP 429) or is otherwise
// unavailable, so the skill degrades instead of failing. JINA_API_KEY is
// required; the skill fails fast when it is unset.

const args = process.argv.slice(2);
const raw = args.includes('--raw');
const url = args.find(a => !a.startsWith('--'));

if (!url) { console.error('Usage: fetch.js <url> [--raw]'); process.exit(1); }
if (!process.env.JINA_API_KEY) { console.error('[web-fetch] JINA_API_KEY is not set.'); process.exit(1); }

function stripHtml(html) {
  return html
    .replace(/<script[\s\S]*?<\/script>/gi, '')
    .replace(/<style[\s\S]*?<\/style>/gi, '')
    .replace(/<[^>]+>/g, ' ')
    .replace(/&nbsp;/g, ' ')
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&#(\d+);/g, (_, n) => String.fromCharCode(n))
    .replace(/[ \t]+/g, ' ')
    .replace(/\n\s*\n/g, '\n')
    .trim();
}

async function jinaFetch() {
  const headers = { 'Authorization': `Bearer ${process.env.JINA_API_KEY}` };
  if (raw) headers['X-Return-Format'] = 'html';
  const res = await fetch(`https://r.jina.ai/${url}`, { headers });
  if (!res.ok) {
    const err = new Error(`Jina reader HTTP ${res.status}`);
    err.status = res.status;
    throw err;
  }
  return await res.text();
}

async function directFetch() {
  process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';
  const res = await fetch(url);
  const html = await res.text();
  return raw ? html : stripHtml(html);
}

try {
  console.log(await jinaFetch());
} catch (e) {
  const reason = e.status === 429 ? 'rate limit exceeded' : `unavailable (${e.message})`;
  console.error(`[web-fetch] Jina reader ${reason}; falling back to direct fetch.`);
  console.log(await directFetch());
}
