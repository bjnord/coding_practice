BIN = ./whale
FILES = mix.exs test/test_helper.exs \
	lib/whale.ex test/whale_test.exs \
	lib/whale/parser.ex test/whale/parser_test.exs

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
