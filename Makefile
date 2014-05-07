BRANCH=`git rev-parse --abbrev-ref HEAD`
CHANGE=`git rev-list HEAD --count`
# Automatically update and install if fast-forward merge is possible
install_latest: pull install

install:
	./install.sh
pull:
	git fetch origin $(BRANCH)
	git merge --ff-only FETCH_HEAD
clean:
	git clean -dxf

provision:
	sudo provision/auto.sh

all: pull provision install

# livecd stuff
livecd: ubuntu-14.04-desktop-amd64.iso
	sudo ./build-livecd.sh ubuntu-14.04-desktop-amd64.iso darkbuntu-$(CHANGE)-$(BRANCH).iso
	rm darkbuntu-$(BRANCH).iso || true
	ln -s darkbuntu-$(CHANGE)-$(BRANCH).iso darkbuntu-$(BRANCH).iso

livecd_incremental:
	test -e darkbuntu-$(BRANCH).iso
	sudo ./build-livecd.sh darkbuntu-$(BRANCH).iso darkbuntu-$(BRANCH).iso
	rm darkbuntu-$(BRANCH).iso || true
	ln -s darkbuntu-$(CHANGE)-$(BRANCH).iso darkbuntu-$(BRANCH).iso

ubuntu-14.04-desktop-amd64.iso:
	wget 'http://releases.ubuntu.com/14.04/ubuntu-14.04-desktop-amd64.iso' \
		-O ubuntu-14.04-desktop-amd64.iso


