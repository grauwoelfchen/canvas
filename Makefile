setup:
	@cargo install nib-cli nib-server
.PHONY: setup

build:
	@mkdir -p ./dst/img
	@cp -R blog/attachment dst/
	@cp -R blog/img dst/
	@nib
.PHONY: build

serve:
	@nib-server
.PHONY: serve

clean:
	@rm -fr ./dst
	@rm -fr ./public
.PHONY: clean

publish: build
	@if [ -d "public" ]; then rm -fr public/*; fi
	@mkdir public
	@if [ -d "dst" ]; then mv dst/* public; fi
.PHONY: publish
