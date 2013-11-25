#!/bin/sh

set -e

test_description='git-unify tests'

t=$(dirname $0)
export PATH=$(cd $t/..; pwd):$PATH

. $t/sharness/sharness.sh

export GIT_UNIFIED_ROOT="$SHARNESS_TRASH_DIRECTORY/.shared-git"
rm -rf   "$GIT_UNIFIED_ROOT"
mkdir -p "$GIT_UNIFIED_ROOT"

counter_file="$SHARNESS_TRASH_DIRECTORY/counter"
echo 1 > "$counter_file"

__git_commit () {
    counter=$(cat "$counter_file")
    echo file $counter >> "FILE_$counter"
    git add FILE_$counter
    git commit -m "commit #$counter at $(basename "$(pwd)")"
    echo $(( $counter + 1 )) > "$counter_file"
}

git config --global user.name  'tester'
git config --global user.email 'test@example.com'

for repo in project-foo project-bar module-a module-b; do
    mkdir -p orig/$repo

    ( cd orig/$repo
      git init --bare
    ) >&3 2>&4

    ( git clone orig/$repo tmp/$repo
      cd tmp/$repo
      __git_commit
      git push origin master ) >&3 2>&4
done

( cd tmp/project-foo
  git submodule add ../../orig/module-a
  git commit -m 'added module-a'
  git push origin master ) >&3 2>&4

# done initializing

test_expect_success 'git-unify clone - fresh' '
    git unify clone orig/project-foo repo/project-foo
'

test_expect_success 'git-unify clone - already unified' '
    git unify clone orig/project-foo repo/project-foo-2
'

test_expect_success 'add some branch' '
    ( cd repo/project-foo &&
      git checkout -b feature-1 &&
      __git_commit &&
      git checkout master )
'

test_expect_success 'another worktree has the same branch' '
    ( cd repo/project-foo && git rev-parse feature-1 ) >expected &&
    ( cd repo/project-foo-2 && git rev-parse feature-1 ) >actual &&
    test_cmp expected actual
'

test_expect_success 'git clone' '
    git clone orig/project-bar repo/project-bar &&
    git clone orig/project-bar repo/project-bar-2
'

test_expect_success 'git unify init - fresh' '
    ( cd repo/project-bar &&
      git unify init )
'

test_expect_success 'git unify init' '
    ( cd repo/project-bar-2 &&
      git unify init )
'

test_expect_success 'git unify init again fails' '
    ( cd repo/project-bar-2 &&
      test_must_fail git unify init )
'

test_expect_success 'git unify submodule-update - fresh' '
    ( cd repo/project-foo &&
      git unify submodule-update module-a )
'

test_expect_success 'git unify submodule-update' '
    ( cd repo/project-foo-2 &&
      git unify submodule-update module-a )
'

test_expect_success 'git unify submodule-add - fresh' '
    ( cd repo/project-foo &&
      git checkout -b with-module-b &&
      git unify submodule-add ../../orig/module-b &&
      git commit -m "added module-b" &&
      git push origin with-module-b )
'

test_expect_success 'git unify submodule-add' '
    ( cd repo/project-bar &&
      git checkout -b with-module-b &&
      git unify submodule-add ../../orig/module-b &&
      git commit -m "added module-b" &&
      git push origin with-module-b )
'

test_expect_success 'setting up conflicting branches' '
    ( cd repo/project-foo-2 &&
      git checkout -b branch-conflicting &&
      git push origin branch-conflicting ) &&
    ( git clone orig/project-foo repo/project-foo-3 &&
      cd repo/project-foo-3 &&
      git checkout branch-conflicting &&
      __git_commit ) &&
    ( cd repo/project-foo-2 &&
      git checkout branch-conflicting &&
      __git_commit &&
      git push origin branch-conflicting )
'

### Branch conflicting

test_expect_success 'git unify init with branches conflicted must fail' '
    ( cd repo/project-foo-3 &&
      test_must_fail git unify init )
'

test_expect_success 'manually fix it (fetch; fails)' '
    ( cd repo/project-foo-3 &&
      test_must_fail git fetch --update-head-ok "$(git unify shared-dir)" refs/heads/*:refs/heads/* | tee fetch-result)
'

test_expect_success 'manually fix it (merge conflicting branch)' '
    ( cd repo/project-foo-3 &&
      git checkout branch-conflicting &&
      git pull --rebase "$(git unify shared-dir)" branch-conflicting &&
      git push "$(git unify shared-dir)" branch-conflicting &&
      git checkout master )
'

test_expect_success 'then git unify init succeeds' '
    ( cd repo/project-foo-3 &&
      git unify init )
'

# enabling `./t/setup.sh`
export SHARNESS_TEST_FILE=${SHARNESS_TEST_FILE#*/}

test_done
