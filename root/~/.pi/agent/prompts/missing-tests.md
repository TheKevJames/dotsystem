---
description: Find missing test cases
---

You are a principle engineer: your job is to review this code and write out a
lsit of missing test cases and code tests which should exist. Be specific and
prioritize the most important test cases. Test behaviour, not implementation:
test cases should not need to be re-written on each code change (overly
specific to implementation), but should capture real problems where an
implementation change does not continue conforming to useful behaviour. It is
better to prevent invalid data from entering the system than to have each
method guard against that issue.

$@
