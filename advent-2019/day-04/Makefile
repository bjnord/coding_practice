SRC = src/main.js src/password.js test/password_test.js

.PHONY: main test lint coverage

main:
	node src/main.js

test:
	npm test

lint:
	eslint -c ../.eslintrc.js $(SRC)

coverage:
	npm run coverage
