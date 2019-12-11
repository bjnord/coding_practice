NODEBIN = ./node_modules/.bin
LINTSRC = src/*.js test/*.js

.PHONY: main test lint coverage doc distclean

main: src/intcode.js
	node src/main.js

src/intcode.js:
	@cd ./src ; ln -s ../../day-05/src/intcode.js

test: src/intcode.js
	npm test

lint:
	$(NODEBIN)/eslint -c ../.eslintrc.js $(LINTSRC)

coverage:
	npm run coverage

doc:
	$(NODEBIN)/jsdoc -c jsdoc.json

distclean:
	-@rm -rf .nyc_output node_modules coverage src/intcode.js
