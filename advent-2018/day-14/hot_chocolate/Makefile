BIN = ./hot_chocolate
FILES = config/config.exs lib/hot_chocolate/cli.ex lib/hot_chocolate/scoreboard.ex lib/hot_chocolate.ex mix.exs test/test_helper.exs test/hot_chocolate_test.exs test/hot_chocolate/scoreboard_test.exs

two:
	mix test && mix run -e 'HotChocolate.part1("input/example1.txt")' \
		&& mix run -e 'HotChocolate.part2("input/example2.txt")'

run: $(BIN)
	mix test && $(BIN) input/input.txt

# FIXME need command-line argument to say which part(s) to run
examples: $(BIN)
	mix test && $(BIN) input/example1.txt

$(BIN): $(FILES)
	mix escript.build
