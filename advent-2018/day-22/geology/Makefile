BIN = ./geology
FILES = config/config.exs mix.exs test/test_helper.exs \
	lib/geology.ex test/geology_test.exs lib/geology/cli.ex \
	lib/cave.ex test/cave_test.exs

.PHONY: test
test:
	mix test && mix run -e 'Geology.main(["input/example1.txt"])'

run: $(BIN)
	$(BIN) input/input.txt

examples: $(BIN)
	$(BIN) input/example1.txt

clean:
	rm -rf _build $(BIN)

$(BIN): $(FILES)
	mix escript.build
