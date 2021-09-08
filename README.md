# GitHub Actions for set request reviewer

Automatically add a reviewers when you create pull request.

```
        uses: apampurin/github-actions-set-request-reviewer@master
        with:
          REVIEWERS: "list of users"
          NUMBER_OF: 2
          GITHUB_TOKEN: "GIT TOKEN"
          FINAL_REVIEW: "username" #optional
```
If you need additional reviewer after prevous approved add FINAL_REVIEW: "username"
It will check NUMBER OF approves and add final approver.