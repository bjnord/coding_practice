NODEBIN = ./node_modules/.bin
LINTSRC = src/*.js test/*.js

.PHONY: main test lint coverage doc distclean

main:
	node src/main.js

test:
	npm test

lint:
	$(NODEBIN)/eslint -c ../.eslintrc.js $(LINTSRC)

coverage:
	npm run coverage

doc:
	$(NODEBIN)/jsdoc -c jsdoc.json

distclean:
	-@rm -rf .nyc_output coverage doc node_modules
