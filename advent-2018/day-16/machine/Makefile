BIN = ./machine
FILES = config/config.exs lib/machine/cli.ex lib/machine.ex mix.exs test/test_helper.exs test/machine_test.exs

.PHONY: test
test:
	mix test && mix run -e 'Machine.main(["input/example1.txt"])'

run: $(BIN)
	$(BIN) input/input.txt

examples: $(BIN)
	$(BIN) input/example1.txt

$(BIN): $(FILES)
	mix escript.build
