NODEBIN = ./node_modules/.bin
SRC = src/main.js

.PHONY: main lint distclean

main:
	node src/main.js

lint:
	$(NODEBIN)/eslint -c ../.eslintrc.js $(SRC)

distclean:
	-@rm -rf node_modules
