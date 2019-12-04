SRC = src/main.js src/wire.js test/wire_intersect_test.js test/wire_test.js

.PHONY: main test lint coverage

main:
	node src/main.js

test:
	npm test

lint:
	eslint -c ../.eslintrc.js $(SRC)

coverage:
	npm run coverage
