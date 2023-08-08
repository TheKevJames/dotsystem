# Open 16 panes:
# $ xpanes {1..16}
#
# Connect to all redis nodes:
# $ xpanes -c "gcloud compute ssh {}" redis-node-{0..11}
#
# Open all subdirectories:
# $ fd -td -d1 . | xpanes -c "cd {}"
# $ fd --hidden -td -d1 . ~/src/personal | xpanes -c "cd {}"
# $ fd --no-ignore -td -d1 . ~/src/talkiq/algorithms | grep -vE '/(bin|mock|sample)/$' | xpanes -c "cd {}"
# $ fd --no-ignore -td -d1 . ~/src/talkiq/gcloud-aio | grep -vE '/(bin|build|docs)/$' | xpanes -c "cd {}"

export PATH="${XDG_SRC_HOME}/tmux-xpanes/bin:${PATH}"
