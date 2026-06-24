default: build serve

IP := $(shell hostname -I | tr ' ' '\n' | grep '^192\.168\.' | head -1)

.PHONY: serve build clean

BUILD_DATE := $(shell git log -1 --format=%aI)

serve:
	@bash scripts/generate-commits-json.sh
	sed -i "s|{{BUILD_DATE}}|$(BUILD_DATE)|" config/_default/params.toml
	hugo server --bind 0.0.0.0 --baseURL http://$(IP):1313/ --port 1313

build:
	@bash scripts/generate-commits-json.sh
	sed -i "s|{{BUILD_DATE}}|$(BUILD_DATE)|" config/_default/params.toml
	hugo && hugo --minify

clean:
	sed -i "s|{{BUILD_DATE}}|{{BUILD_DATE}}|" config/_default/params.toml
