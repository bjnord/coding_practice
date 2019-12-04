SRC = src/main.js src/module.js test/module_mass2fuel_test.js test/module_mass2fullfuel_test.js

main:
	node src/main.js

.PHONY: test lint
test:
	npm test

lint:
	eslint -c ../.eslintrc.js $(SRC)
