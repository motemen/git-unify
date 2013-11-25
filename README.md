git-unify
=========

Concentrate `.git` directories under ~/.shared-git to speed-up cloning

## `git unify init`

Share current repository's `.git` directory under `~/.shared-git`.

If shared `.git` directory is already set up and two repositories' head refs does not meet,
(eg. one repository has a new branch)
this command fails. If so, you should sync these manually.

Typically fixing goes like below:

```
% git fetch --update-head-ok "$(git unify shared-dir)" refs/heads/*:refs/heads/* # will fail on some branches
% git checkout the-branch-conflicting
% git pull "$(git unify shared-dir)" the-branch-conflicting
% git push "$(git unify shared-dir)" the-branch-conflicting
```

## `git unify deinit`

Reverts `git unify init`. Files under `.git` directory are no longer shared.

## `git unify submodule-update <submodule>`

Does `git submodule update --init` with shared `.git` directory set up.

## `git unify submodule-add <submodule>`

Does `git submodule add` with shared `.git` directory set up.

## `git unify clone <url>`

Does `git clone` with shared `.git` directory set up.
