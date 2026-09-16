---
name: committer
description: Group current unstaged and untracked changes into sensible commits and commit them. Use when the user wants their working tree committed cleanly.
---

Commit the current unstaged and untracked changes.

If anything is already staged, warn the user and stop immediately.

Inspect the diff, untracked files, recent history, and relevant repository instructions. Group changes into natural, logically complete commits. Do not over-split.

Use only these commit types:

* `feat`: behavior or functionality changes
* `fix`: fixes an existing functional problem
* `refact`: internal structure changes without behavior changes
* `style`: substantial visual or styling-system changes
* `chore`: everything else

Prefer `fix` over the other types when a commit fixes an existing functional problem.

Commit messages must use:

`<type>: <Korean title>`

Do not use scopes. Write commit bodies in Korean only when useful. If a body needs non-trivial explanation, use the `i-have-adhd` skill with only that commit's diff and inferred intent.

Treat implementation and its tests as the same change. Include related lockfiles or generated files when they are consequences of that change.

Do not commit changes that appear to be local experimentation, ambiguous untracked files, or secrets/credentials. Report them instead.

When committable and non-committable changes share a file, stage only the relevant hunks without modifying the working tree. If they cannot be safely separated, leave that commit blocked and continue with independent commits.

Never modify files. Do not run tests or linters. Do not rewrite history or push.

Commit without asking for confirmation.

If a commit or hook fails, stop, restore any staging created by this skill, and leave the working tree untouched.

At the end, briefly report created commits and anything left uncommitted or blocked. Never print secret values.
