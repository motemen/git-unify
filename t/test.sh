#!/bin/sh

# git unify init
# git unify clone
# git unify detach
# git unify submodule-add

set -e

cd $(dirname $0)/..
root=$(pwd)

export GIT_UNIFIED_ROOT=$root/t/.shared-git
rm -rf   $GIT_UNIFIED_ROOT
mkdir -p $GIT_UNIFIED_ROOT

git_unify=$root/git-unify

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
  git submodule add -q $root/t/orig/module-a
  git commit -q -m 'added module-a' )

# done initializing

mkdir -p t/repo

echo '=== git unify clone (fresh)'

$git_unify clone $root/t/orig/project-foo t/repo/project-foo

echo '=== git unify clone'

$git_unify clone $root/t/orig/project-foo t/repo/project-foo-2

echo '=== refs shared'

( cd t/repo/project-foo
  git checkout -b feature-1
  __git_commit_random
  git checkout master )

test $( cd t/repo/project-foo && git rev-parse feature-1 ) == $( cd t/repo/project-foo-2 && git rev-parse feature-1 )

echo '=== git unify init (fresh)'

git clone $root/t/orig/project-bar t/repo/project-bar

( cd t/repo/project-bar
  $git_unify init )

echo '=== git unify init'

git clone $root/t/orig/project-bar t/repo/project-bar-2

( cd t/repo/project-bar-2
  $git_unify init )

echo '=== git unify submodule-update (fresh)'

( cd t/repo/project-foo
  $git_unify submodule-update module-a )

echo '=== git unify submodule-update'

( cd t/repo/project-foo-2
  $git_unify submodule-update module-a )
