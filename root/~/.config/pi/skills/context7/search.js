#!/usr/bin/env node

const [libraryName, query = libraryName] = process.argv.slice(2);
if (!libraryName) { console.error("Usage: search.js <libraryName> [query]"); process.exit(1); }

const res = await fetch("https://mcp.context7.com/mcp", {
  method: "POST",
  headers: { "Content-Type": "application/json", "Accept": "application/json, text/event-stream" },
  body: JSON.stringify({ jsonrpc: "2.0", id: 1, method: "tools/call", params: { name: "resolve-library-id", arguments: { query, libraryName } } })
});
const data = parseMcpResponse(await res.text(), res.headers.get("content-type"));
if (data.error) { console.error("Error:", data.error.message); process.exit(1); }
console.log(data.result.content[0].text);

// Context7's MCP endpoint replies with an SSE stream (text/event-stream) whose
// body is `event: message\ndata: {json}`, so res.json() cannot parse it directly.
function parseMcpResponse(raw, contentType) {
  if (!contentType || !contentType.includes("text/event-stream")) return JSON.parse(raw);
  for (const block of raw.split("\n\n")) {
    const payload = block.split("\n").filter(l => l.startsWith("data:")).map(l => l.slice(5).trimStart());
    if (payload.length) return JSON.parse(payload.join("\n"));
  }
  throw new Error("no data payload in SSE response");
}
