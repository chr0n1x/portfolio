default: build serve

IP := $(shell hostname -I | tr ' ' '\n' | grep '^192\.168\.' | head -1)

.PHONY: serve build

serve:
	hugo server --bind 0.0.0.0 --baseURL http://$(IP):1313/ --port 1313

build:
	hugo && hugo --minify
