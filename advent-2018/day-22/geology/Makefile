BIN = ./geology
FILES = config/config.exs mix.exs test/test_helper.exs \
	lib/geology.ex test/geology_test.exs lib/geology/cli.ex \
	lib/cave.ex test/cave_test.exs

.PHONY: test
test:
	mix test && mix run -e 'Geology.main(["input/example1.txt"])'

run: $(BIN)
	$(BIN) --margin-x=50 --margin-y=5 input/input.txt

examples: $(BIN)
	$(BIN) --margin-x=5 --margin-y=5 input/example1.txt

maps:
	mix run -e 'Geology.cave_map(["input/example1.txt"])'

clean:
	rm -rf _build $(BIN)

$(BIN): $(FILES)
	mix escript.build
