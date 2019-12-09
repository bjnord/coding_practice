NODEBIN = ./node_modules/.bin
SRC = src/main.js src/intcode.js src/manual_tests.js test/intcode_decode_test.js test/intcode_run_test.js

.PHONY: main test lint coverage doc distclean

main:
	node src/main.js

test:
	npm test

lint:
	$(NODEBIN)/eslint -c ../.eslintrc.js $(SRC)

coverage:
	npm run coverage

doc:
	$(NODEBIN)/jsdoc -c jsdoc.json src

distclean:
	-@rm -rf .nyc_output node_modules coverage
