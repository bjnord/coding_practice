SRC = src/intcode.js src/main.js test/intcode_run_test.js

main:
	node src/main.js

.PHONY: test
test:
	npm test

lint:
	eslint -c ../.eslintrc.js $(SRC)
