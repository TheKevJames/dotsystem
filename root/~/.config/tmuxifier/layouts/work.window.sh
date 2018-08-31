new_window "work"

split_v 74
select_pane 0
split_h 50

run_cmd "bugwarrior-pull" 0
run_cmd "youtube-viewer -n \":playlist=LLRvXhm62yMVj8sJOJQYpRGg\"" 1

send_keys "task next" 0
send_keys "1.." 1

select_pane 2
