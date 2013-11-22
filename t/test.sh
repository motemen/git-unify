#!/bin/sh

# git unify init
# git unify clone
# git unify detach
# git unify submodule-add

set -e

cd $(dirname $0)/..
ROOT=$(pwd)

export GIT_UNIFIED_ROOT=$ROOT/t/.shared-git
rm -rf   $GIT_UNIFIED_ROOT
mkdir -p $GIT_UNIFIED_ROOT

rm -rf t/orig
rm -rf t/repo

counter=1

__git_commit_random () {
    echo file $counter >> "FILE_$counter"
    git add FILE_$counter
    git commit -q -m "commit #$counter"
    counter=$(( $counter + 1 ))
}

for repo in project-foo project-bar module-a; do
    mkdir -p t/orig/$repo

    ( cd t/orig/$repo
      git init -q
      __git_commit_random
      __git_commit_random )
done

( cd t/orig/project-foo
  git submodule add -q $ROOT/t/orig/module-a
  git commit -q -m 'added module-a' )

# done initializing

mkdir -p t/repo

echo '=== git unify clone (fresh)'

git unify clone $ROOT/t/orig/project-foo t/repo/project-foo

echo '=== git unify clone'

git unify clone $ROOT/t/orig/project-foo t/repo/project-foo-2

echo '=== git unify init (fresh)'

git clone $ROOT/t/orig/project-bar t/repo/project-bar

( cd t/repo/project-bar && git unify init )

echo '=== git unify init'

git clone $ROOT/t/orig/project-bar t/repo/project-bar-2

( cd t/repo/project-bar-2 && git unify init )
