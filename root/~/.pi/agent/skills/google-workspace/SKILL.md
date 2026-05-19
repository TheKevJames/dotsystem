---
name: google-workspace
description: Read, write, and manage Google Docs, Sheets, and Drive files using the gog CLI tool. Use when the user asks to interact with Google Docs, Sheets, Drive, or shares a docs.google.com link.
---

# Google Workspace (via gog CLI)

**Always use the `gog` CLI tool** for Google Workspace interactions. Do not attempt to use web-fetch, curl, or browser-based access for Google Docs — they require authentication and will fail.

## Google Docs

### Read a document
```bash
# By URL
gog doc get "https://docs.google.com/document/d/DOC_ID/edit"

# By document ID
gog doc get DOC_ID
```

### Create a document
```bash
# From a file (converts to Google Doc)
gog doc create --title "My Document" --input ./document.md

# From stdin
echo "Content here" | gog doc create --title "My Document"
```

### Upload to Drive (with conversion to Google Docs format)
```bash
gog drive upload ./local-file.md --name "Document Title" --mime-type application/vnd.google-apps.document
```

### Update a document
```bash
gog doc update DOC_ID --input ./updated-content.md
```

## Google Sheets

### Read a spreadsheet
```bash
gog sheet get SHEET_ID
gog sheet get SHEET_ID --range "Sheet1!A1:D10"
```

### Create a spreadsheet
```bash
gog sheet create --title "My Spreadsheet"
```

## Google Drive

### List files
```bash
gog drive list
gog drive list --query "name contains 'PRD'"
```

### Upload a file
```bash
gog drive upload ./local-file.txt
gog drive upload ./local-file.txt --name "Custom Name"
```

### Download a file
```bash
gog drive download FILE_ID --output ./local-file.txt
```

## Common Workflows

### Read a Google Doc shared via URL
When the user shares a `docs.google.com` URL:
```bash
gog doc get "https://docs.google.com/document/d/1qYxMoOk85MHa5efGwoSXndVfdl8niNOKai6pTMhSLB8/edit"
```

### Save local documents to Google Drive as Google Docs
```bash
gog drive upload ./PRD.md --name "PRD - Project Name" --mime-type application/vnd.google-apps.document
```

### Read a doc, save locally, edit, and re-upload
```bash
gog doc get DOC_ID > /tmp/doc.md
# ... edit /tmp/doc.md ...
gog doc update DOC_ID --input /tmp/doc.md
```

## Tips
- When a user shares a Google Doc URL, **use `gog doc get`** — do not try web-fetch or ask them to download it
- The `gog` tool handles authentication automatically
- Google Doc IDs are the long alphanumeric string in the URL after `/d/`
- Use `gog drive upload` with `--mime-type application/vnd.google-apps.document` to convert markdown to Google Docs format on upload
- Do not try to write to `~/Library/CloudStorage/` or similar filesystem mount points — use `gog` instead
