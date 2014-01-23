all: test test-checkbashisms

test: submodule-update
	t/test.sh

test-checkbashisms:
	if type checkbashisms > /dev/null 2>&1; then \
	    checkbashisms git-unify && echo 'checkbashisms ok'; \
	    else echo '# checkbashisms required; skip'; fi

submodule-update:
	git submodule update --init

gh-pages: gh-pages-docs
	./util/push-gh-pages ./gh-pages

gh-pages-docs:
	mkdir -p gh-pages
	cat git-unify.txt | asciidoc - > gh-pages/git-unify.html

.PHONY: gh-pages
