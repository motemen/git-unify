#!/bin/sh

set -e

test_description='git-unify tests'

t=$(dirname $0)
export PATH=$(cd $t/..; pwd):$PATH

. $t/sharness/sharness.sh

export GIT_UNIFIED_ROOT=$SHARNESS_TRASH_DIRECTORY/.shared-git
rm -rf   $GIT_UNIFIED_ROOT
mkdir -p $GIT_UNIFIED_ROOT

counter=1

__git_commit_random () {
    echo file $counter >> "FILE_$counter"
    git add FILE_$counter
    git commit -q -m "commit #$counter"
    counter=$(( $counter + 1 ))
}

for repo in project-foo project-bar module-a; do
    mkdir -p orig/$repo

    ( cd orig/$repo
      git init -q
      __git_commit_random )
done

( cd orig/project-foo
  git submodule add -q ../module-a
  git commit -q -m 'added module-a' )

# done initializing

test_expect_success 'git-unify clone - fresh' \
    "git unify clone orig/project-foo repo/project-foo"

test_expect_success 'git-unify clone - already unified' \
    "git unify clone orig/project-foo repo/project-foo-2"

test_expect_success 'add some branch' \
    '( cd repo/project-foo &&
       git checkout -b feature-1 &&
       __git_commit_random &&
       git checkout master )'

test_expect_success 'another worktree has the same branch' \
    '( cd repo/project-foo && git rev-parse feature-1 ) >expected &&
     ( cd repo/project-foo-2 && git rev-parse feature-1 ) >actual &&
     test_cmp expected actual'

test_expect_success 'git clone' \
    "git clone orig/project-bar repo/project-bar &&
     git clone orig/project-bar repo/project-bar-2"

test_expect_success 'git unify init (fresh)' \
    "( cd repo/project-bar &&
       git unify init )"

test_expect_success 'git unify init' \
    "( cd repo/project-bar-2 &&
       git unify init )"

test_expect_success 'git unify init again fails' \
    "( cd repo/project-bar-2 &&
       test_must_fail git unify init )"

test_expect_success 'git unify submodule-update (fresh)' \
    "( cd repo/project-foo
       git unify submodule-update module-a )"

test_expect_success 'git unify submodule-update' \
    "( cd repo/project-foo-2
       git unify submodule-update module-a )"

export SHARNESS_TEST_FILE=${SHARNESS_TEST_FILE#*/}

test_done
