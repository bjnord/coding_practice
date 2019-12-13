NODEBIN = ./node_modules/.bin
LINTSRC = src/*.js

.PHONY: main lint distclean

main:
	node src/main.js

lint:
	$(NODEBIN)/eslint -c ../.eslintrc.js $(LINTSRC)

distclean:
	-@rm -rf node_modules
