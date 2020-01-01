NODEBIN = ./node_modules/.bin
LINTSRC = src/*.js

.PHONY: main test lint coverage doc distclean

main:
	node src/main.js

test:
	exit 0

lint:
	$(NODEBIN)/eslint -c ../.eslintrc.js $(LINTSRC)

coverage:
	exit 0

doc:
	$(NODEBIN)/jsdoc -c jsdoc.json

distclean:
	-@rm -rf node_modules
