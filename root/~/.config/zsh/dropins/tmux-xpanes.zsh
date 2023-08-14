# Open 16 panes:
# $ xpanes {1..16}
#
# Connect to all redis nodes:
# $ xpanes-foreach -c "gcloud compute ssh {}" redis-node-{0..11}
#
# Open all subdirectories:
# $ fd -td -d1 . | xpanes -c "cd {}"
# $ fd --hidden -td -d1 . ~/src/personal | xpanes -c "cd {}"
# $ fd --no-ignore -td -d1 . ~/src/talkiq/algorithms | grep -vE '/(bin|mock|sample)/$' | xpanes -c "cd {}"
# $ fd --no-ignore -td -d1 . ~/src/talkiq/gcloud-aio | grep -vE '/(bin|build|docs)/$' | xpanes -c "cd {}"

export PATH="${XDG_SRC_HOME}/tmux-xpanes/bin:${PATH}"

# This magic ensures that anywhere I've overloaded commands to interact with
# tmux (such as setting the pane titles for ssh connections) can work with
# xpanes. Since it introduces a delay (0.1s per pane), I decided to set this as
# a new command rather than overwriting "xpanes".
# TODO: figure out if/how the "--interval" flag could be removed, then change
# this to "alias xpanes='...'".
alias xpanes-foreach='xpanes --interval=0.1 -B "tmux select-pane -t \${TMUX_PANE}"'
