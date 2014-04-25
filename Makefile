BRANCH=`git rev-parse --abbrev-ref HEAD`
# Automatically update and install if fast-forward merge is possible
update: pull install
install:
	./install.sh
pull:
	git fetch origin $(BRANCH)
	git merge --ff-only FETCH_HEAD
livecd:
	./build-livecd.sh

clean:
	git clean -xfd # --dry-run
