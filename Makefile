build:
	lazbuild --build-all --build-mode=Release BioRythm.lpr

dbgBuild:
	lazbuild --build-all --build-mode=Debug BioRythm.lpr	

# README.md: README.mds
#	mdpreproc < README.mds > README.md

install: build # README.md
	cp -v BioRythm ~/bin/
