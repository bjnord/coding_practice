BIN = ./tree

run: $(BIN)
	mix test && $(BIN) input/input.txt

examples: $(BIN)
	mix test && $(BIN) input/example1.txt

$(BIN):
	mix escript.build
