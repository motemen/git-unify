all: test test-checkbashisms

test: submodule-update
	t/test.sh

test-checkbashisms:
	if type checkbashisms > /dev/null 2>&1; then \
	    checkbashisms git-unify && echo 'checkbashisms ok'; \
	    else echo '# checkbashisms required; skip'; fi

submodule-update:
	git submodule update --init
