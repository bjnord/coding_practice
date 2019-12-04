SRC = src/main.js src/module.js test/module_mass2fuel_test.js test/module_mass2fullfuel_test.js

.PHONY: main test lint coverage

main:
	node src/main.js

test:
	npm test

lint:
	eslint -c ../.eslintrc.js $(SRC)

coverage:
	npm run coverage
