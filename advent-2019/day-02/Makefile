NODEBIN = ./node_modules/.bin
SRC = src/main.js

.PHONY: main lint distclean

main: src/intcode.js
	node src/main.js

src/intcode.js:
	@cd ./src ; ln -s ../../day-05/src/intcode.js

lint:
	$(NODEBIN)/eslint -c ../.eslintrc.js $(SRC)

distclean:
	-@rm -rf node_modules src/intcode.js
