---
name: terraform
description: Reference for Terraform lifecycle meta-arguments, provider migration patterns, state management, and validation. Use when editing Terraform files (.tf) or planning infrastructure changes.
---

# Terraform

## Lifecycle Meta-Arguments

### ignore_changes
Controls which attributes Terraform ignores during plan/apply.

**Limitations with dynamic blocks and lists:**
- `ignore_changes` does **not** support splat syntax (`[*]`) for list indices
- You can only use literal indices: `guest_accelerator[0].gpu_driver_installation_config`
- For dynamically generated lists (via `for_each` / `count`), you **cannot** target a specific sub-attribute across all list elements
- The only option is to ignore the entire list attribute (e.g., `guest_accelerator`), which also ignores changes to all nested attributes

```hcl
lifecycle {
  # OK: specific index
  ignore_changes = [node_config[0].guest_accelerator[0].gpu_driver_installation_config]

  # OK: entire list (but ignores ALL changes within)
  ignore_changes = [node_config[0].guest_accelerator]

  # INVALID: splat syntax
  # ignore_changes = [node_config[0].guest_accelerator[*].gpu_driver_installation_config]
}
```

**Always explain the trade-off** when suggesting `ignore_changes` on an entire list — be explicit about what else will be ignored. Ask the user before broadening scope.

### create_before_destroy
```hcl
lifecycle {
  create_before_destroy = true
}
```

### prevent_destroy
```hcl
lifecycle {
  prevent_destroy = true
}
```

## Provider Migration Patterns

### Zero-downtime provider migration (removed + import blocks)
When migrating resources from one provider to another (e.g., `mrolla/circleci` → `CircleCI-Public/circleci`), `moved` blocks do not work across providers. Use `removed` + `import` blocks instead:

```hcl
# Remove from old provider's state (without destroying the resource)
removed {
  from = circleci_environment_variable.my_var
  lifecycle {
    destroy = false
  }
}

# Import into new provider's state
import {
  to = circleci_project_environment_variable.my_var
  id = "gh/org/repo/MY_VAR"
}
```

**Key considerations:**
- `removed` blocks tell Terraform to forget the resource without destroying it
- `import` blocks tell Terraform to adopt the existing resource into new state
- Some resources don't implement `ImportState` — check the provider source
- Sensitive attributes (e.g., secret values) may be null after import if the API only returns masked values
- Always run `terraform plan` in a non-production environment first

### Data sources for dynamic values
Prefer data sources over hardcoded values:
```hcl
data "circleci_organization" "current" {}
local {
  project_slug = "${data.circleci_organization.current.slug}/${var.repo_name}"
}
```

## Validation

The below validation should normally run with `pre-commit run -a`, or can be
run individually for specific checks.

### terraform validate
Checks syntax and internal consistency but does NOT check:
- Provider-specific resource validation
- State consistency
- Actual API compatibility

### terraform fmt
Canonical formatting — always run after changes:
```bash
terraform fmt -recursive
```

### tflint (if available)
Catches issues `validate` misses:
```bash
tflint --recursive
```

## State Management

### terraform state list
List all resources in state.

### terraform state show
Show attributes of a specific resource.

### terraform import (CLI)
One-off import of an existing resource:
```bash
terraform import 'resource_type.name' 'resource-id'
```

### Import blocks (declarative, preferred)
```hcl
import {
  to = aws_instance.example
  id = "i-1234567890"
}
```

## Common Patterns

### Local variables for cross-cutting values
Use locals to avoid threading variables through the entire module hierarchy:
```hcl
locals {
  organization_id = "3792eae7-6591-4c15-bfac-5ab988ef162c"
}
```

### Module versioning
Pin module sources:
```hcl
module "gke" {
  source  = "../../libs/gke"
  # ...
}
```

## Tips
- Always apply the **minimal targeted fix** — do not broaden `ignore_changes` or add extra resources without asking
- When suggesting changes to `ignore_changes`, explicitly list what will and won't be ignored
- Run `pre-commit run -a` if the project uses pre-commit hooks
- For large provider migrations, plan the approach (removed/import vs moved) before writing code
