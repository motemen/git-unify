git-unify
=========

Concentrate `.git` directories under ~/.shared-git to speed-up cloning

## `git unify init`

Share current repository's `.git` directory under `~/.shared-git`.

## `git unify deinit`

Reverts `git unify init`. Files under `.git` directory are no longer shared.

## `git unify submodule <submodule>`

Does `git submodule update --init` with shared `.git` directory set up.

## `git unify clone <url>`

Does `git clone` with shared `.git` directory set up.
