#
# To get started, copy makeconfig.example.mk as makeconfig.mk and fill in the appropriate paths.
#
# build: Build all the zips and kwads
# install: Copy mod files into a local installation of Invisible Inc
# rar: Update the pre-built rar
#

include makeconfig.mk

.PHONY: build

build: out/scripts.zip out/gui.kwad out/moremissions_anims.kwad

install: build
	mkdir -p $(INSTALL_PATH)
	rm -f $(INSTALL_PATH)/*.kwad $(INSTALL_PATH)/*.zip
	cp modinfo.txt $(INSTALL_PATH)/
	cp out/scripts.zip $(INSTALL_PATH)/
	cp out/gui.kwad $(INSTALL_PATH)/
	cp out/moremissions_anims.kwad $(INSTALL_PATH)/
	cp scripts/pedler_oil.kwad $(INSTALL_PATH)/
ifneq ($(INSTALL_PATH2),)
	mkdir -p $(INSTALL_PATH2)
	rm -f $(INSTALL_PATH2)/*.kwad $(INSTALL_PATH2)/*.zip
	cp out/scripts.zip $(INSTALL_PATH2)/
	cp scripts/pedler_oil.kwad $(INSTALL_PATH2)/
	cp out/gui.kwad $(INSTALL_PATH2)/
	cp out/moremissions_anims.kwad $(INSTALL_PATH2)/
endif

rar: build
	mkdir -p out/MoreMissions
	cp modinfo.txt out/MoreMissions/
	cp out/scripts.zip out/MoreMissions/
	cp out/gui.kwad out/MoreMissions/
	cp out/moremissions_anims.kwad out/MoreMissions/
	cd out && rar a ../MoreMissions\ V.0.3.rar \
		MoreMissions/modinfo.txt \
		MoreMissions/scripts.zip \
		MoreMissions/gui.kwad \
		MoreMissions/moremissions_anims.kwad

#
# kwads and contained files
#

anims := $(patsubst %.anim.d,%.anim,$(shell find anims -type d -name "*.anim.d"))

$(anims): %.anim: $(wildcard %.anim.d/*.xml $.anim.d/*.png)
	cd $*.anim.d && zip ../$(notdir $@) *.xml *.png

out/gui.kwad out/moremissions_anims.kwad: $(anims)
	mkdir -p out
	$(KWAD_BUILDER) -i build.lua -o out

#
# scripts
#

out/scripts.zip: $(shell find scripts -type f -name "*.lua")
	mkdir -p out
	cd scripts && zip -r ../$@ . -i '*.lua'
