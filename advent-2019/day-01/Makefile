NODEBIN = ./node_modules/.bin
SRC = src/main.js src/module.js test/module_mass2fuel_test.js test/module_mass2fullfuel_test.js

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
