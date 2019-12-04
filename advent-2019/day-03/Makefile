SRC = src/main.js src/wire.js test/wire_intersect_test.js test/wire_test.js

main:
	node src/main.js

.PHONY: test
test:
	npm test

lint:
	eslint -c ../.eslintrc.js $(SRC)
