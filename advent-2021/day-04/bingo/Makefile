BIN = ./bingo
FILES = mix.exs test/test_helper.exs \
	lib/bingo.ex test/bingo_test.exs \
	lib/bingo/cli.ex test/bingo/cli_test.exs

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
