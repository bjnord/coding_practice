BIN = ./teleport
FILES = config/config.exs lib/teleport/cli.ex lib/teleport.ex mix.exs test/test_helper.exs test/teleport_test.exs

.PHONY: test
test:
	mix test && mix run -e 'Teleport.main(["input/example1.txt"])'

run: $(BIN)
	$(BIN) input/input.txt

examples: $(BIN)
	$(BIN) input/example1.txt

clean:
	rm -rf _build $(BIN)

$(BIN): $(FILES)
	mix escript.build
