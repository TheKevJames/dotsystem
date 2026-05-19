---
name: grafana-alloy
description: Reference for Grafana Alloy config syntax, pipeline stages, relabeling behavior, LogQL selectors, and Go RE2 regex limitations. Use when editing or debugging Alloy config files (*.alloy).
---

# Grafana Alloy

## Key Concepts

### Label Stripping
All labels starting with `__` (double underscore) are **removed prior to forwarding** log entries between components. This means:
- `loki.source.gcplog` strips `__gcp_*` labels before forwarding
- `loki.source.kubernetes` strips `__meta_kubernetes_*` labels before forwarding
- `loki.relabel` rules referencing `__`-prefixed labels **only work when inline** in the source component or as part of `discovery.relabel`
- If all labels are stripped and no labels remain, **the entry is silently dropped**

**Common mistake:** Creating a `loki.relabel` component that references `__gcp_*` or `__meta_*` labels — these are already gone by the time entries reach a separate relabel component. Extract the data you need during discovery relabeling or from the JSON log body in `loki.process`.

### Pipeline Stages

#### stage.json
Extracts fields from JSON log lines or from previously extracted keys:
```alloy
stage.json {
  source      = "__resource_labels"   // optional: extract from a named key
  expressions = { kind = "database_id", level = "severity" }
}
```

#### stage.labels
**Promotes extracted data into actual Loki labels.** Without this, `stage.json` only populates the extracted-data map — values are NOT automatically labels.
```alloy
stage.labels {
  values = { kind = "", level = "", region = "" }
}
```

#### stage.template
Sets or defaults extracted-data values using Go templates:
```alloy
stage.template {
  source   = "level"
  template = "{{ if .level }}{{ .level }}{{ else }}ERROR{{ end }}"
}
```

#### stage.truncate
**Purpose-built for limiting log line size.** Always prefer this over regex for truncation.
```alloy
stage.truncate {
  limit           = 250000
  suffix          = "...TRUNCATED"
  drop_on_failure = false
}
```

#### stage.replace
Uses RE2 regex for pattern replacement on the log line:
```alloy
stage.replace {
  expression = "(?P<content>.*)"
  replace    = "{{ .content }}"
}
```

#### stage.match
Conditionally applies stages based on a LogQL selector:
```alloy
stage.match {
  selector = "{container=\"my-app\"}"
  // nested stages here
}
```

#### stage.drop
Drops entries matching conditions. Be careful — silent data loss.

### Go RE2 Regex Limitations
Alloy uses Go's `regexp` package (RE2 syntax):
- **Max repeat count:** 1000 (e.g., `{999}` is OK, `{1001}` fails)
- **Total compiled size matters:** `(?:.{500}){500}` compiles to 250,000 internal elements and will fail even though individual counts are under 1000
- **No backreferences** (`\1` etc.)
- **No lookahead/lookbehind**
- When truncation is needed, **use `stage.truncate`** — do not use regex

### LogQL Selector Escaping in Alloy Config
Alloy strings use their own escaping layer. When a LogQL selector inside a `stage.match` contains a regex with backslashes (e.g., `\d`), you must **quadruple-escape**:
```alloy
// To get the regex \d in LogQL:
selector = "{container=~\"my-app-\\\\d+\"}"
// Alloy string: \" → "  and \\\\ → \\
// LogQL sees: {container=~"my-app-\\d+"}
// Regex sees: my-app-\d+
```

**Simple rule:** For each level of escaping (Alloy string → LogQL string → regex), double the backslashes.

### Go Template Functions
Used in `stage.template` and `stage.output`:
- `TrimSpace` — strips leading/trailing whitespace
- `TrimSuffix .Entry "}"` — strips a **suffix string** (not a character set)
- `TrimRight` — strips a **character set** from the right; will strip ALL matching chars including nested `}}`
- `regexReplaceAll "pattern" .Value "replacement"` — RE2 regex replacement

**Common mistake:** Using `TrimRight .Entry "}"` to strip a closing brace — this strips a *character set*, not a suffix. Use `TrimSuffix` instead. Also, Kubernetes log lines end with `\n`, so `TrimSpace` first.

### Relabeling Behavior
- `loki.relabel` rules apply in order; if all labels are removed, the entry is dropped
- `discovery.relabel` rules apply during target discovery, before scraping
- `keep` action: drop targets that don't match the regex
- `drop` action: drop targets that match the regex
- `labeldrop` action: remove labels matching the regex — can collapse distinct series if labels that distinguish them are dropped

### Common Patterns

#### Extract labels from GCP JSON log body
When `__gcp_*` labels are unavailable (stripped before forwarding):
```alloy
stage.json {
  expressions = {
    resource_type = "resource.type"
    project       = "resource.labels.project_id"
    log_name      = "logName"
  }
}
stage.replace {
  source     = "log_name"
  expression = ".*/([^/]+)$"
  replace    = "${1}"
}
stage.labels {
  values = { resource_type = "", project = "", log_name = "" }
}
```

#### Conditional label override (prefer non-empty value)
```alloy
stage.json {
  source      = "__resource_labels"
  expressions = { kind = "forwarding_rule_name", __backend = "backend_service_name" }
}
stage.template {
  source   = "kind"
  template = "{{ if .__backend }}{{ .__backend }}{{ else }}{{ .kind }}{{ end }}"
}
```

#### Filter pods by phase and container state
```alloy
discovery.relabel "pods" {
  rule {
    source_labels = ["__meta_kubernetes_pod_phase"]
    regex         = "Running"
    action        = "keep"
  }
  rule {
    source_labels = ["__meta_kubernetes_pod_container_id"]
    regex         = "^$"
    action        = "drop"
  }
}
```

## Debugging Tips
1. Set `logging { level = "debug" }` temporarily to see what components are doing
2. Check for "dropping entry after relabeling" messages — indicates empty label sets
3. Verify Prometheus scrape annotation meta-labels use `__meta_kubernetes_pod_annotation_*` (not `service`)
4. After making changes, always verify by checking the Alloy pod logs for config errors
