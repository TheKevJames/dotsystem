new_window "redis-cluster"

split_v 50

select_pane 0
split_h 66
split_h 50

select_pane 3
split_h 66
split_h 50

select_pane 0

run_cmd "gcloud compute ssh --zone us-central1-a redis-node-0" 0
run_cmd "gcloud compute ssh --zone us-central1-b redis-node-1" 1
run_cmd "gcloud compute ssh --zone us-central1-c redis-node-2" 2
run_cmd "gcloud compute ssh --zone us-central1-f redis-node-3" 3
run_cmd "gcloud compute ssh --zone us-central1-a redis-node-4" 4
run_cmd "gcloud compute ssh --zone us-central1-b redis-node-5" 5
