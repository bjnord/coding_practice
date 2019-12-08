NODEBIN = ./node_modules/.bin
SRC = src/main.js src/space_image.js test/space_image_test.js

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
