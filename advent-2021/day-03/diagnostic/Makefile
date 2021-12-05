BIN = ./diagnostic
FILES = mix.exs test/test_helper.exs \
	lib/diagnostic.ex test/diagnostic_test.exs \
	lib/diagnostic/parser.ex test/diagnostic/parser_test.exs

.PHONY: run test clean

run: $(BIN)
	$(BIN) input/input.txt

test:
	@rm -f _build/propcheck.ctex
	mix test

clean:
	rm -rf _build $(BIN)

$(BIN): $(FILES)
	mix escript.build
