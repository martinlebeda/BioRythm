TAG := $(shell date +%Y%m%d)

build:
	lazbuild --build-all --build-mode=Release BioRythm.lpr

dbgBuild:
	lazbuild --build-all --build-mode=Debug BioRythm.lpr	

# README.md: README.mds
#	mdpreproc < README.mds > README.md

install: build # README.md
	cp -v BioRythm ~/bin/

release: install
	git tag $(TAG)
	git push origin --tags
	cp -v -v BioRythm ~/Dropbox/Martin/Projects/BioRythm/BioRythm.Linux.x64.$(TAG)
