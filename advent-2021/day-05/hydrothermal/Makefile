BIN = ./hydrothermal
FILES = mix.exs test/test_helper.exs \
	lib/hydrothermal.ex test/hydrothermal_test.exs \
	lib/hydrothermal/parser.ex test/hydrothermal/parser_test.exs

.PHONY: run test clean

run: $(BIN)
	$(BIN) input/input.txt

test:
	@rm -f _build/propcheck.ctex
	mix test

clean:
	rm -rf _build $(BIN) log/*.log

$(BIN): $(FILES)
	mix escript.build
