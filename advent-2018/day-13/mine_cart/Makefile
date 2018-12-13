BIN = ./mine_cart
FILES = config/config.exs lib/mine_cart/input_parser.ex lib/mine_cart/cli.ex lib/mine_cart.ex mix.exs test/test_helper.exs test/mine_cart/input_parser_test.exs test/mine_cart_test.exs

one:
	mix test && mix run -e 'MineCart.part1("input/example1.txt")'

run: $(BIN)
	mix test && $(BIN) input/input.txt

examples: $(BIN)
	mix test && $(BIN) input/example1.txt

$(BIN): $(FILES)
	mix escript.build
