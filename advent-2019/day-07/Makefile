NODEBIN = ./node_modules/.bin
SRC = src/main.js src/intcode.js test/intcode_run_test.js

.PHONY: main test lint coverage distclean

main: src/intcode.js
	node src/main.js

src/intcode.js:
	@cd ./src ; ln -s ../../day-05/src/intcode.js

test:
	npm test

lint:
	$(NODEBIN)/eslint -c ../.eslintrc.js $(SRC)

coverage:
	npm run coverage

distclean:
	-@rm -rf .nyc_output node_modules coverage
