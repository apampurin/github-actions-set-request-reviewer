#!/bin/bash

ACTION=$(jq -r '.action' < "$GITHUB_EVENT_PATH")

addInitialReviewers(){
  AUTHOR=$(jq -r '.pull_request.user.login' < "$GITHUB_EVENT_PATH")
  REVIEWERS=$(set_reviewers "$INPUT_REVIEWERS" "$AUTHOR" "$INPUT_NUMBER_OF")
  PULL_REQUEST_NUMBER=$(jq -r '.number' < "$GITHUB_EVENT_PATH")

  ENDPOINT="https://api.github.com/repos/$GITHUB_REPOSITORY/pulls/$PULL_REQUEST_NUMBER/requested_reviewers"
  CONTENTS="{\"reviewers\": $REVIEWERS, \"team_reviewers\": []}"
  HEADER="Accept: application/vnd.github.inertia-preview+json"
  curl -s -X POST -H "Authorization:token $INPUT_GITHUB_TOKEN" -H "$HEADER" -d "$CONTENTS" "$ENDPOINT"
}

addFinalBOSS(){
  BOSS=$INPUT_FINAL_REVIEW
  PULL_REQUEST_NUMBER=$(jq -r '.number' < "$GITHUB_EVENT_PATH")
  CURRENT_REVIEWERS=$(curl -H "Authorization:token $INPUT_GITHUB_TOKEN" https://api.github.com/repos/$GITHUB_REPOSITORY/pulls/$PULL_REQUEST_NUMBER/requested_reviewers | jq -r '.users | .[].login')
  REVIEWERS="$CURRENT_REVIEWERS"
  REVIEWERS+=("$BOSS")
  ENDPOINT="https://api.github.com/repos/$GITHUB_REPOSITORY/pulls/$PULL_REQUEST_NUMBER/requested_reviewers"
  CONTENTS="{\"reviewers\": $REVIEWERS, \"team_reviewers\": []}"
  HEADER="Accept: application/vnd.github.inertia-preview+json"
  curl -s -X POST -H "Authorization:token $INPUT_GITHUB_TOKEN" -H "$HEADER" -d "$CONTENTS" "$ENDPOINT"
}

set_reviewers() {
  _CANDIDARES="$1"
  _AUTHOR="$2"
  _NUMBER="$3"
  _REVIEWERS=()
  
  echo $_AUTHOR
  i=0
  for _CANDIDARE in ${_CANDIDARES[@]}; do
    if [ "$_CANDIDARE" != "$_AUTHOR" ]; then
        _REVIEWERS+=("$_CANDIDARE")
    fi
    i=$((i++))
    if [[ $i == 2 ]]; then
      break
    fi
  done

  echo "$_REVIEWERS"
  unset _AUTHOR _REVIEWERS
}

if [ "$ACTION" == opened ]; then
  addInitialReviewers
fi
if [ -n $INPUT_FINAL_REVIEW ]; then
    addFinalBOSS
fi
