NODEBIN = ./node_modules/.bin
LINTSRC = src/*.js test/*.js

.PHONY: main test lint coverage doc distclean pack

main:
	node src/main.js

test:
	npm test

lint:
	$(NODEBIN)/eslint -c ../.eslintrc.js $(LINTSRC)

coverage:
	npm run coverage

doc:
	$(NODEBIN)/jsdoc -c jsdoc.json

distclean:
	-@rm -rf .nyc_output coverage doc node_modules dist

dist/index.html: websrc/index.html
	install -m 755 -d dist
	install -m 644 websrc/index.html dist

pack: dist/index.html
	npm run build
	@chmod -R a+rX dist
