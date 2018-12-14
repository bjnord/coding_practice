BIN = ./tree
FILES = config/config.exs lib/tree/cli.ex lib/tree.ex mix.exs test/test_helper.exs test/tree_test.exs

.PHONY: test
test:
	mix test && mix run -e 'Tree.part1("input/example1.txt")' \
		&& mix run -e 'Tree.part2("input/example1.txt")'

run: $(BIN)
	$(BIN) input/input.txt

examples: $(BIN)
	$(BIN) input/example1.txt

$(BIN): $(FILES)
	mix escript.build
