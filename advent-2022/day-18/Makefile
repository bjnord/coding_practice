NODEBIN = ./node_modules/.bin
LINTSRC = src/*.js test/*.js

.PHONY: main dump test lint coverage doc distclean

main:
	node src/main.js

dump:
	node src/main.js --dump

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
