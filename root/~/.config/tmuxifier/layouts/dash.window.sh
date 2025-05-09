new_window "dash"

split_h 60
select_pane 1
split_v 30
select_pane 3
split_v 65

# ...yeah.
run_cmd $'nvim -c \'execute "normal \\\\ww"\'' 1
run_cmd "task due" 3
run_cmd "cctui" 4

select_pane 3
