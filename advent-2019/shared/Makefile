NODEBIN = ./node_modules/.bin
LINTSRC = src/*.js test/*.js

.PHONY: test lint coverage doc distclean

test:
	npm test

lint:
	$(NODEBIN)/eslint -c ../.eslintrc.js $(LINTSRC)

coverage:
	npm run coverage

doc:
	$(NODEBIN)/jsdoc -c jsdoc.json

distclean:
	-@rm -rf .nyc_output node_modules coverage doc
