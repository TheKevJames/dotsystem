new_window "dash"

split_h 60
select_pane 0
split_v 22
select_pane 2
split_v 65

# ...yeah.
run_cmd $'nvim -c \'execute "normal \\\\ww"\'' 0
run_cmd "youtube-viewer -s -n -L" 1
run_cmd "jira mine" 2
run_cmd "cctui" 3

select_pane 0
