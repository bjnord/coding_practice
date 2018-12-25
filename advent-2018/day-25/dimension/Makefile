BIN = ./dimension
FILES = config/config.exs lib/dimension/cli.ex lib/dimension.ex mix.exs test/test_helper.exs test/dimension_test.exs

.PHONY: test
test:
	mix test && mix run -e 'Dimension.main(["input/example1.txt"])'

run: $(BIN)
	$(BIN) input/input.txt

examples: $(BIN)
	$(BIN) input/example1.txt

clean:
	rm -rf _build $(BIN)

$(BIN): $(FILES)
	mix escript.build
