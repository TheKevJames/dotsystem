alias slack-todo="slack reminder list | jq -r '.reminders[] | select(.complete_ts == 0) | \"* \(.text)\"'"
