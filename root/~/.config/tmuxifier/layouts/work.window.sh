new_window "work"

split_v 74
select_pane 0
split_h 50

run_cmd "task next +work" 0
run_cmd "youtube-viewer -s -n -L" 1

send_keys "task next +work" 0
# send_keys ":anp 1.." 1

select_pane 2
