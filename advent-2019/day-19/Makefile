NODEBIN = ./node_modules/.bin
LINTSRC = src/*.js# test/*.js

.PHONY: main test intcode lint coverage doc distclean

main:
	node src/main.js

test:
	npm test

intcode:
	node src/example_intcode.js

lint:
	$(NODEBIN)/eslint -c ../.eslintrc.js $(LINTSRC)

coverage:
	npm run coverage

doc:
	$(NODEBIN)/jsdoc -c jsdoc.json

distclean:
	-@rm -rf .nyc_output node_modules coverage
