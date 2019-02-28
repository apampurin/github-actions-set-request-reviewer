FROM alpine:3.9

LABEL "com.github.actions.name"="Set request reviewer"
LABEL "com.github.actions.description"="pull request add to reviewer"
LABEL "com.github.actions.icon"="users"
LABEL "com.github.actions.color"="orange"

LABEL "repository"="https://github.com/usayuki/github-actions-set-request-reviewer"
LABEL "maintainer"="usayuki <masapp.01a@gmail.com>"

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
