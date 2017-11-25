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

distribute:
	if [ -d "site/public" ]; then mv site/output public; fi
	rm -f public/assets/css/baguetteBox.{css,min.css} \
	   public/assets/css/html4css1.css \
	   public/assets/css/ipython.min.css \
	   public/assets/css/nikola_{ipython.css,rst.css} \
	   public/assets/css/rst.css \
	   public/assets/css/theme.css \
	   public/assets/js/baguetteBox.{js,min.js} \
	   public/assets/js/fancydates.js \
	   public/assets/js/flowr.js \
	   public/assets/js/html5.js \
	   public/assets/js/html5shiv-printshiv.min.js \
	   public/assets/js/moment-with-locales.min.js
.PHONY: distribute
