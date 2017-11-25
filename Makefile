setup:
	pip install Nikola -c constraints.txt
.PHONY: setup

build:
	cd site && nikola build
.PHONY: build

serve:
	cd site && nikola serve
.PHONY: serve

clean:
	cd site && rm -fr ./output
.PHONY: clean
