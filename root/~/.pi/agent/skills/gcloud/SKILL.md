---
name: gcloud
description: Reference for common gcloud CLI patterns including logging queries, PubSub inspection, GCS operations, GKE cluster access, and IAP tunneling. Use when working with Google Cloud infrastructure.
---

# Google Cloud CLI (gcloud)

## GKE Cluster Access

Activate the context with:
```bash
kubectl ctx "${PROJECT_ID}-${CLUSTER_NAME}-${LOCATION}"
```

If it's not present, fetch it first with
```bash
gcloud container clusters get-credentials "${NAME}" \
  --zone "${REGION}" \
  --project "${PROJECT}"
kubectl config rename-context "gke_${PROJECT}_${REGION}_${NAME}" "${PROJECT}-${NAME}-${REGION}" >"${OUTPUT}"
```

### Private clusters via IAP tunnel (gluru-* projects)
For projects named `gluru-*`, GKE clusters are private and require an SSH tunnel:
```bash
endpoint=$(gcloud container clusters describe kube-dev \
  --location europe-west1 \
  --project gluru-qna-develop \
  --format json | jq -rc .privateClusterConfig.privateEndpoint) && \
gcloud compute ssh kube-master-proxy \
  --project gluru-qna-develop \
  --zone europe-west1-b \
  --tunnel-through-iap \
  -- -L 8443:${endpoint}:443 -N
```

Then in another terminal:
```bash
kubectl --insecure-skip-tls-verify --server=https://127.0.0.1:8443 get nodes
```

**Instance names vary by project.** If `kube-master-proxy` fails, try:
- `kube-proxy`
- `k8s-master-proxy`
- `squid-proxy`

Or list instances: `gcloud compute instances list --project PROJECT_ID`

#### Connect Gateway (newer clusters)
```bash
gcloud container fleet memberships get-credentials CLUSTER_NAME \
  --project PROJECT_ID
```

## Cloud Logging

### Read logs
```bash
gcloud logging read 'FILTER' \
  --project=PROJECT_ID \
  --freshness=DURATION \
  --format=json \
  --limit=N
```

### Common filters
```bash
# Cloud Run service logs
'resource.type="cloud_run_revision" resource.labels.service_name="SERVICE"'

# GKE container logs
'resource.type="k8s_container" resource.labels.cluster_name="CLUSTER" resource.labels.namespace_name="NAMESPACE"'

# Severity filter
'severity>=ERROR'

# Combined
'resource.type="k8s_container" resource.labels.cluster_name="realtime" severity>=ERROR'
```

**Important:** `--freshness` is relative to the current time. Do not assume the current time — verify with `date -u` if unsure.

## Pub/Sub

### Inspect subscription state
```bash
# Check backlog and delivery stats
gcloud pubsub subscriptions describe SUBSCRIPTION_NAME \
  --project=PROJECT_ID \
  --format=json

# Check unacked message count and oldest unacked age
gcloud monitoring time-series list \
  --project=PROJECT_ID \
  --filter='metric.type="pubsub.googleapis.com/subscription/num_undelivered_messages" AND resource.labels.subscription_id="SUBSCRIPTION"' \
  --interval-start-time=$(date -u -v-5M +%Y-%m-%dT%H:%M:%SZ) \
  --format=json
```

### Pull messages (debugging)
```bash
# Pull without acking (peek)
gcloud pubsub subscriptions pull SUBSCRIPTION_NAME \
  --project=PROJECT_ID \
  --limit=5 \
  --format=json
```

### Seek past bad messages
```bash
gcloud pubsub subscriptions seek SUBSCRIPTION_NAME \
  --time=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --project=PROJECT_ID
```

## GCS Operations

### List objects by storage class
```bash
gcloud storage ls --long gs://BUCKET/ | grep COLDLINE
```

### Rewrite storage class
```bash
gcloud storage objects update gs://BUCKET/** --storage-class=REGIONAL
```

### Check bucket config
```bash
gcloud storage buckets describe gs://BUCKET/ --format=json
```

## Authentication

### Check current auth
```bash
gcloud auth list
gcloud config get-value project
```

### Re-authenticate
Requires human intervention -- always ask them to reauthenticate and continue after they've confirmed.

### Service account impersonation
```bash
gcloud auth print-access-token --impersonate-service-account=SA@PROJECT.iam.gserviceaccount.com
```

## Tips
- Always verify current time with `date -u` before using time-relative filters
- Do not fabricate theories about system state — use `gcloud` commands to verify
- When debugging GCP services, check both the service logs AND the infrastructure logs (e.g., Cloud Run logs vs. application logs)
- For rate-limited APIs (like GCS), avoid reading data from GCS in hot paths
