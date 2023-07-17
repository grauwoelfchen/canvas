# TODO: install packages from crates.io
# @cargo install nib-cli --version 0.0.3
# @cargo install nib-server --version 0.0.2
setup:
	cargo install --git https://gitlab.com/grauwoelfchen/nib.git nib-cli
	cargo install --git https://gitlab.com/grauwoelfchen/nib.git nib-server
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
