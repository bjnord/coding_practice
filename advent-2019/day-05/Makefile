NODEBIN = ./node_modules/.bin
SRC = src/main.js src/intcode.js src/manual_tests.js test/intcode_decode_test.js test/intcode_run_test.js

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
