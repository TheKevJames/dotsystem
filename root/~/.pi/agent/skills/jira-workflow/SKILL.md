---
name: jira-workflow
description: Jira workflow assistant for finding outstanding work items and learning details about them.
---

# Jira Workflow

To find the list of tickets which I might want to work on, you can use the
following command. Do not attempt to modify this command.
```bash
jira issue list -pX -a$(jira me) -RUnresolved -q 'project IS NOT EMPTY AND project NOT IN (SEC, OUT)' --plain
```

Each line returned by that command should be treated as an individual work
item. The second column denotes a Key which can be used to get even more
information, by running the following command:
```bash
jira issue view KEY --plain
```
