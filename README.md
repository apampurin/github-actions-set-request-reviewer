# GitHub Actions for set request reviewer

Automatically add a reviewers when you create pull request.

## Usage
Add the following settings to .github/main.workflow in your repository.

```
workflow "pull requests" {
  on = "pull_request"
  resolves = ["add a pull_request to reviewers"]
}

action "add a pull_request to reviewers" {
  uses = "docker://usayuki/github-actions-set-request-reviewer"
  secrets = ["GITHUB_TOKEN"]
  args = ["usayuki"]
}
```
