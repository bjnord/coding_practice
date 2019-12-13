NODEBIN = ./node_modules/.bin
LINTSRC = src/*.js test/*.js

.PHONY: main test lint coverage distclean

main:
	node src/main.js

test:
	npm test

lint:
	$(NODEBIN)/eslint -c ../.eslintrc.js $(LINTSRC)

coverage:
	npm run coverage

distclean:
	-@rm -rf .nyc_output node_modules coverage
