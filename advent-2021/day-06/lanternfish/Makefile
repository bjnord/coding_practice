BIN = ./lanternfish
FILES = mix.exs test/test_helper.exs \
	lib/lanternfish.ex test/lanternfish_test.exs \
	lib/lanternfish/parser.ex test/lanternfish/parser_test.exs

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
