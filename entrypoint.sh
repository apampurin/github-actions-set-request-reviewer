#!/bin/bash
echo $INPUT_REVIEWERS
ACTION=$(jq -r '.action' < "$GITHUB_EVENT_PATH")

addInitialReviewers(){
  echo "setting up endpoints for initial request"
  AUTHOR=$(jq -r '.pull_request.user.login' < "$GITHUB_EVENT_PATH")
  REVIEWERS=$(set_reviewers "$INPUT_REVIEWERS" "$AUTHOR" "$INPUT_NUMBER_OF")
  echo "prepared reviewers array: $REVIEWERS"
  PULL_REQUEST_NUMBER=$(jq -r '.number' < "$GITHUB_EVENT_PATH")
  ENDPOINT="https://api.github.com/repos/$GITHUB_REPOSITORY/pulls/$PULL_REQUEST_NUMBER/requested_reviewers" 
  
  echo "preparing request content"
  CONTENTS="{\"reviewers\": $REVIEWERS}"
  HEADER="Accept: application/vnd.github.v3+json"
  echo $ENDPOINT
  echo $CONTENTS
  echo "New reviesers:"
  curl -X POST -H "Authorization:token $INPUT_GITHUB_TOKEN" -H "$HEADER" "$ENDPOINT" -d "$CONTENTS" | jq '.requested_reviewers  | .[].login'
  echo "end!"
}

addFinalBOSS(){
  echo "setting up endpoints for final request"
  BOSS=$INPUT_FINAL_REVIEW
  PULL_REQUEST_API_URL=$(jq -r '.pull_request._links.self.href' < "$GITHUB_EVENT_PATH")
  ENDPOINT="$PULL_REQUEST_API_URL/requested_reviewers"
  CONTENTS="{\"reviewers\": [\"$BOSS\"]}"

  HEADER="Accept: application/vnd.github.v3+json"
  echo "New reviesers:"
  curl -X POST -H "Authorization:token $INPUT_GITHUB_TOKEN" -H "$HEADER" "$ENDPOINT" -d "$CONTENTS" | jq '.requested_reviewers  | .[].login'
  echo "end!"
}

set_reviewers() {
  _CANDIDARES="$1"
  _AUTHOR="$2"
  _NUMBER="$3"
  _REVIEWERS="["
  i=1
  for _CANDIDARE in ${_CANDIDARES[@]}; do
    if [ "$_CANDIDARE" != "$_AUTHOR" ]; then
      if [ $i == $_NUMBER ]; then
        _REVIEWERS+="\"$_CANDIDARE\"]"
        break
      else
        _REVIEWERS+="\"$_CANDIDARE\","
      fi
    fi
    ((i++))
  done
  echo "$_REVIEWERS"
  unset _AUTHOR _REVIEWERS
}

echo "got action - $ACTION"
if [ "$ACTION" == opened  ] || [ "$ACTION" == synchronize ] || [ "$ACTION" == reopened ]; then
  echo "initiating first part of reviwers"
  addInitialReviewers
fi
if [ -n $INPUT_FINAL_REVIEW ]; then
  HEADER="Accept: application/vnd.github.v3+json"
  PULL_REQUEST_API_URL=$(jq -r '.pull_request._links.self.href' < "$GITHUB_EVENT_PATH")
  #cat $GITHUB_EVENT_PATH
  #echo "api url - $PULL_REQUEST_API_URL"
  curl -H "Accept: application/vnd.github.v3+json" -H "Authorization:token $INPUT_GITHUB_TOKEN" -H "$HEADER" "$PULL_REQUEST_API_URL/reviews"
  COUNT_APPROVES=$(curl -H "Accept: application/vnd.github.v3+json" -H "Authorization:token $INPUT_GITHUB_TOKEN" -H "$HEADER" "$PULL_REQUEST_API_URL/reviews" | jq -r '.[].state' | grep APPROVED | wc -l)
  echo "got $COUNT_APPROVES approves"
  if [ "$COUNT_APPROVES" >= "$INPUT_NUMBER_OF" ]; then
    addFinalBOSS
  fi
fi
