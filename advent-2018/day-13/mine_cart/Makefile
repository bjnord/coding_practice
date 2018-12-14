BIN = ./mine_cart
FILES = config/config.exs lib/mine_cart/input_parser.ex lib/mine_cart/cli.ex lib/mine_cart.ex mix.exs test/test_helper.exs test/mine_cart/input_parser_test.exs test/mine_cart_test.exs

.PHONY: test
test:
	mix test && mix run -e 'MineCart.part1("input/example1.txt")' \
		&& mix run -e 'MineCart.part2("input/example2.txt")'

run: $(BIN)
	$(BIN) input/input.txt

examples: $(BIN)
	$(BIN) --parts 1 input/example1.txt \
		&& $(BIN) --parts 12 input/example2.txt

$(BIN): $(FILES)
	mix escript.build
