NODEBIN = ./node_modules/.bin
SRC = src/main.js src/orbiter.js src/orbit_map.js test/orbiter_test.js test/orbit_map_test.js

.PHONY: main test lint coverage distclean

main:
	node src/main.js

test:
	npm test

lint:
	$(NODEBIN)/eslint -c ../.eslintrc.js $(SRC)

coverage:
	npm run coverage

distclean:
	-@rm -rf .nyc_output node_modules coverage
