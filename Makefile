SHELL := /bin/sh
.PHONY: all gc macv libv libv-chs libv-cht fcitx5-chs fcitx5-cht debug install install-vchewing _remoteinstall-vchewing clean BuildDir clang-format lint

all: macv winv phone.cin

clang-format:
	swift-format format --in-place --configuration ./.clang-format-swift.json --recursive ./

lint:
	swift-format lint --configuration ./.clang-format-swift.json --recursive ./

clean:
	@rm -rf ./Build
	@rm -rf tsi-cht.src tsi-chs.src data-cht.txt data-chs.txt phone.cin phone.cin-CNS11643-complete.patch
		
install: install-vchewing clean

BuildDir:
	@mkdir -p ./Build

fcitx5-chs: macv
	@echo "\033[0;32m//$$(tput bold) Linux: 正在生成 FCITX5 版小麥注音專用的簡體中文威注音語料檔案……$$(tput sgr0)\033[0m"
	@> ./mcbopomofo-data.txt
	@echo "# format org.openvanilla.mcbopomofo.sorted" >> ./mcbopomofo-data.txt
	@env LC_COLLATE=C.UTF-8 cat ./data-chs.txt >> ./mcbopomofo-data.txt
	
fcitx5-cht: macv
	@echo "\033[0;32m//$$(tput bold) Linux: 正在生成 FCITX5 版小麥注音專用的繁體中文威注音語料檔案……$$(tput sgr0)\033[0m"
	@> ./mcbopomofo-data.txt
	@echo "# format org.openvanilla.mcbopomofo.sorted" >> ./mcbopomofo-data.txt
	@env LC_COLLATE=C.UTF-8 cat ./data-cht.txt >> ./mcbopomofo-data.txt

macv:
	@swift ./bin/cook_mac.swift

libv:
	swift ./bin/cook_libchewing.swift chs
	swift ./bin/cook_libchewing.swift cht

libv-chs:
	@swift ./bin/cook_libchewing.swift chs
	@diff -u "./Build/phone-chs.cin" "./Build/phone-chs-ex.cin" --label phone.cin --label phone-CNS11643-complete.cin > "./phone.cin-CNS11643-complete.patch" || true
	@cp -a ./Build/tsi-chs.src ./tsi.src
	@cp -a ./Build/phone-chs.cin ./phone.cin

libv-cht:
	@swift ./bin/cook_libchewing.swift cht
	@diff -u "./Build/phone-cht.cin" "./Build/phone-cht-ex.cin" --label phone.cin --label phone-CNS11643-complete.cin > "./phone.cin-CNS11643-complete.patch" || true
	@cp -a ./Build/tsi-cht.src ./tsi.src
	@cp -a ./Build/phone-cht.cin ./phone.cin

install-vchewing: macv
	@echo "\033[0;32m//$$(tput bold) macOS: 正在部署威注音核心語彙檔案……$$(tput sgr0)\033[0m"
	@cp -a data-chs.txt $(HOME)/Library/Input\ Methods/vChewing.app/Contents/Resources/
	@cp -a data-cht.txt $(HOME)/Library/Input\ Methods/vChewing.app/Contents/Resources/
	@cp -a ./components/common/data*.txt $(HOME)/Library/Input\ Methods/vChewing.app/Contents/Resources/
	@cp -a ./components/common/char-kanji-cns.txt $(HOME)/Library/Input\ Methods/vChewing.app/Contents/Resources/

	@pkill -HUP -f vChewing || echo "// vChewing is not running"
	@echo "\033[0;32m//$$(tput bold) macOS: 正在確保威注音不被 Gatekeeper 刁難……$$(tput sgr0)\033[0m"
	@/usr/bin/xattr -drs "com.apple.quarantine" $(HOME)/Library/Input\ Methods/vChewing.app
	@echo "\033[0;32m//$$(tput bold) macOS: 核心語彙檔案部署成功。$$(tput sgr0)\033[0m"

# FOR INTERNAL USE
debug:
	@rsync -avx ./phone.cin-CNS11643-complete.patch ./phone.cin ./tsi.src ~/Repos/libchewing/data/ || true
	@echo "\033[0;32m//$$(tput bold) libChewing: 開始偵錯測試。$$(tput sgr0)\033[0m"
	@make -f ~/Repos/libchewing/data/makefile  -C ~/Repos/libchewing/data/

_remoteinstall-vchewing: macv
	@rsync -avx data-chs.txt data-cht.txt $(RHOST):"Library/Input\ Methods/vChewing.app/Contents/Resources/"
	@rsync -avx ./components/common/data*.txt $(RHOST):"Library/Input\ Methods/vChewing.app/Contents/Resources/"
	@rsync -avx ./components/common/char-kanji-cns.txt.txt $(RHOST):"Library/Input\ Methods/vChewing.app/Contents/Resources/"
	@test "$(RHOST)" && ssh $(RHOST) "pkill -HUP -f vChewing || echo Remote vChewing is not running" || true

gc:
	git reflog expire --expire=now --all ; git gc --prune=now --aggressive
