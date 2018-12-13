BIN = ./mine_cart

one:
	mix test && mix run -e 'MineCart.part1("input/example1.txt")'

run: $(BIN)
	mix test && $(BIN) input/input.txt

examples: $(BIN)
	mix test && $(BIN) input/example1.txt

$(BIN):
	mix escript.build
