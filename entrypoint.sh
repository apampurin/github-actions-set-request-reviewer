#!/bin/sh -eu

ACTION=$(jq -r '.action' < "$GITHUB_EVENT_PATH")

if [ "$ACTION" != opened ]; then
  echo "This action was ignored. (ACTION: $ACTION)"
  exit 0
fi

get_reviewers() {
  _CANDIDARES="$1"
  _AUTHOR="$2"
  _REVIEWERS=()
  
  for _CANDIDARE in ${$_CANDIDARES[@]}; do
    if [ "$_CANDIDARE" != "$_AUTHOR" ]; then
        _REVIEWERS+=("$_CANDIDARE")
    fi
  done

  echo "$_REVIEWERS"
  unset _AUTHOR _REVIEWERS
}

AUTHOR=$(jq -r '.pull_request.user.login' < "$GITHUB_EVENT_PATH")
REVIEWERS=$(get_reviewers "$*" "$AUTHOR")

TOKEN="$GITHUB_TOKEN"

PULL_REQUEST_NUMBER=$(jq -r '.number' < "$GITHUB_EVENT_PATH")

ENDPOINT="https://api.github.com/repos/cam-inc/leahi-ios/pulls/$PULL_REQUEST_NUMBER/requested_reviewers"
CONTENTS="{\"reviewers\": $REVIEWERS, \"team_reviewers\": []}"
HEADER="Accept: application/vnd.github.inertia-preview+json"
curl -s -X POST -u "$GITHUB_ACTOR:$TOKEN" -H "$HEADER" -d "$CONTENTS" "$ENDPOINT"

