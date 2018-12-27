BIN = ./immunity
FILES = config/config.exs mix.exs test/test_helper.exs \
	lib/immunity.ex test/immunity_test.exs lib/immunity/cli.ex \
	lib/immunity/combat.ex test/immunity/combat_test.exs \
	lib/immunity/group.ex test/immunity/group_test.exs \
	lib/immunity/input_parser.ex test/immunity/input_parser_test.exs \

.PHONY: test
test:
	mix test && mix run -e 'Immunity.main(["input/example1.txt"])'

run: $(BIN)
	$(BIN) input/input.txt

examples: $(BIN)
	$(BIN) input/example1.txt

clean:
	rm -rf _build $(BIN)

$(BIN): $(FILES)
	mix escript.build
