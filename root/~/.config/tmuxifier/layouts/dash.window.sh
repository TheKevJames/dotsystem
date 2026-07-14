new_window "dash"

split_h 60
select_pane 2
split_v 65

# ...yeah.
run_cmd $'nvim -c \'execute "normal \\\\ww"\'' 1
run_cmd "task due" 2
run_cmd "cd ~/src/personal/scratch" 3
run_cmd "pi" 3

select_pane 2
