BRANCH=`git rev-parse --abbrev-ref HEAD`
# Automatically update and install if fast-forward merge is possible
update: pull install

install:
	./install.sh
pull:
	git fetch origin $(BRANCH)
	git merge --ff-only FETCH_HEAD

livecd: ubuntu-14.04-desktop-amd64.iso
	./build-livecd.sh

clean:
	git clean -xfd # --dry-run

ubuntu-14.04-desktop-amd64.iso:
	wget 'http://releases.ubuntu.com/14.04/ubuntu-14.04-desktop-amd64.iso' -O ubuntu-14.04-desktop-amd64.iso
