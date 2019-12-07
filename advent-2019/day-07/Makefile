NODEBIN = ./node_modules/.bin
SRC = src/main.js src/amp_set.js src/intcode.js src/permutator.js \
	test/amp_set_test.js test/permutator_test.js

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
