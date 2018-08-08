# https://bugwarrior.readthedocs.io/en/latest/common_configuration.html
[general]
targets = github_prs_assigned,github_prs_created,github_prs_reviewer,github_thekevjames,github_coveralls_clients,github_talkiq_prs_assigned,github_talkiq_prs_created,github_talkiq_prs_reviewer,jira_dialpad
taskrc = ~/.config/taskwarrior/taskrc

[github_prs_assigned]
service = github
github.login = thekevjames
github.token = M4_BUGWARRIOR_GITHUB_API_TOKEN

github.query = is:open is:pr assignee:thekevjames -user:thekevjames -user:coveralls-clients -user:talkiq
github.include_user_issues = False
github.include_user_repos = False
github.username = foo
github.description_template = {{githubtitle}}
github.add_tags = personal

[github_prs_created]
service = github
github.login = thekevjames
github.token = M4_BUGWARRIOR_GITHUB_API_TOKEN

github.query = is:open is:pr author:thekevjames -user:thekevjames -user:coveralls-clients -user:talkiq
github.include_user_issues = False
github.include_user_repos = False
github.username = foo
github.description_template = {{githubtitle}}
github.add_tags = personal

[github_prs_reviewer]
service = github
github.login = thekevjames
github.token = M4_BUGWARRIOR_GITHUB_API_TOKEN

github.query = is:open is:pr review-requested:thekevjames -user:thekevjames -user:coveralls-clients -user:talkiq
github.include_user_issues = False
github.include_user_repos = False
github.username = foo
github.description_template = {{githubtitle}}
github.add_tags = personal

[github_thekevjames]
service = github
github.login = thekevjames
github.token = M4_BUGWARRIOR_GITHUB_API_TOKEN

github.query = is:open user:thekevjames
github.include_user_issues = False
github.include_user_repos = False
github.username = foo
github.description_template = {{githubtitle}}
github.add_tags = personal

[github_coveralls_clients]
service = github
github.login = thekevjames
github.token = M4_BUGWARRIOR_GITHUB_API_TOKEN

github.query = is:open user:coveralls-clients
github.include_user_issues = False
github.include_user_repos = False
github.username = foo
github.description_template = {{githubtitle}}
github.add_tags = personal

[github_talkiq_prs_assigned]
service = github
github.login = thekevjames
github.token = M4_BUGWARRIOR_GITHUB_API_TOKEN

github.query = is:pr is:open user:talkiq assignee:thekevjames
github.include_user_issues = False
github.include_user_repos = False
github.username = foo
github.description_template = {{githubtitle}}
github.add_tags = work

[github_talkiq_prs_created]
service = github
github.login = thekevjames
github.token = M4_BUGWARRIOR_GITHUB_API_TOKEN

github.query = is:pr is:open user:talkiq author:thekevjames
github.include_user_issues = False
github.include_user_repos = False
github.username = foo
github.description_template = {{githubtitle}}
github.add_tags = work

[github_talkiq_prs_reviewer]
service = github
github.login = thekevjames
github.token = M4_BUGWARRIOR_GITHUB_API_TOKEN

github.query = is:pr is:open user:talkiq review-requested:thekevjames
github.include_user_issues = False
github.include_user_repos = False
github.username = foo
github.description_template = {{githubtitle}}
github.add_tags = work

[jira_dialpad]
service = jira
jira.base_uri = https://switchcomm.atlassian.net
jira.version = 5

jira.username = kjames@dialpad.com
jira.password = M4_JIRA_TOKEN
jira.query = assignee = kjames AND resolution = Unresolved
jira.description_template = {{jirasummary}}
jira.add_tags = work
